local LOCAL_PATH = "mods/penman/"
local orig_do_mod_appends = do_mod_appends
do_mod_appends = function( filename, ... ) --stolen from https://github.com/alex-3141/noita-parallax
    LOCAL_PATH = filename:match("(.+/)[^/]+")
    do_mod_appends = orig_do_mod_appends
    do_mod_appends( filename, ... )
end

-- jit.util.funcinfo(setfenv(1, getfenv())) --thanks to ImmortalDamned

dofile_once( LOCAL_PATH.."_penman.lua" )
pen.lib = pen.lib or {}; pen.LOCAL_PATH = LOCAL_PATH
for i,v in ipairs({ "nxml", "csv", "base64", "matrix", "complex", "EZWand" }) do
	pen.lib[ v ] = dofile_once( table.concat({ pen.LOCAL_PATH, "lib/", v, ".lua" }))
end
--dialog (modify to be more generalized + transition to penman)
--parallax

if( GameHasFlagRun( pen.FLAG_UPDATE_UTF )) then
	local the_concept_of_table_itself = dofile_once( "mods/penman/extra/lists/every_character.lua" )
	for i,the_concept_of_set_itself in ipairs( the_concept_of_table_itself ) do
		local the_concept_of_language_itself = string.gsub( string.gsub( pen.t2t( the_concept_of_set_itself ), "\n", "" ), "%s", "" )
		local the_concept_of_number_itself, the_concept_of_counter_itself = 0, 0
		for the_concept_of_character_itself in string.gmatch( the_concept_of_language_itself, "." ) do
			local the_concept_of_byte_itself = string.byte( the_concept_of_character_itself )
			if( the_concept_of_byte_itself == string.byte( "." )) then
				if( the_concept_of_number_itself > 0 and pen.BYTE_TO_ID[ the_concept_of_number_itself ] == nil ) then
					local the_concept_of_i_itself = 1
					for str in string.gmatch( the_concept_of_language_itself, pen.ptrn( "%." )) do
						if( the_concept_of_i_itself == the_concept_of_counter_itself ) then
							pen.BYTE_TO_ID[ the_concept_of_number_itself ] = pen.magic_byte( str )
							print( "["..the_concept_of_number_itself.."]="..pen.BYTE_TO_ID[ the_concept_of_number_itself ])
							break
						end
						the_concept_of_i_itself = the_concept_of_i_itself + 1
					end
				end
				the_concept_of_number_itself = 0
				the_concept_of_counter_itself = the_concept_of_counter_itself + 1
			else
				the_concept_of_number_itself = bit.lshift( the_concept_of_number_itself, 10 ) + the_concept_of_byte_itself
			end
		end
		print("\n")
	end
end

pen.I = {
	__mt = { --just steal the whole complex.lua
		__add = function( a, b )
			return pen.I.new( a.r + b.r, a.i + b.i )
		end,
		__sub = function( a, b )
			return pen.I.new( a.r - b.r, a.i - b.i )
		end,
		__mul = function( a, b )
			return pen.I.new( a.r*b.r - a.i*b.i, a.r*b.i + a.i*b.r )
		end,
		__tostring = function( a )
			return table.concat({ "[", a.r, ";", a.i, "]" })
		end,
	},
	new = function( r, i )
		return setmetatable({ r = r, i = i or 0 }, pen.I.__mt )
	end,
	expi = function( i )
		return pen.I.new( math.cos( i ), math.sin( i ))
	end,
}
pen.ANIM_INTERS.frir = function( t, delta, p ) --https://rosettacode.org/wiki/Fast_Fourier_transform#Lua
	local function fft( tbl ) --literal shit, write custom implementation
		local n = #tbl
		if( n <= 1 ) then return end

		local odd, even = {}, {}
		for i = 1,n,2 do
			table.insert( odd, tbl[i])
			table.insert( even, tbl[ i + 1 ])
		end
		fft( even ); fft( odd )

		for k = 1,n/2 do
			local t = even[k]*pen.I.expi( -2*math.pi*( k - 1 )/n )
			pen.c.fft_data[k], pen.c.fft_data[ k + n/2 ] = odd[k] + t, odd[k] - t
		end
		return pen.c.fft_data
	end
	
	--come up with a good default param set
	--check if it's looped properly and add buffer points (45 degree straight) if is not
	return pen.cache({ "fft_memo", pen.t.pack( p )}, function()
		pen.c.fft_data = {}
		for i,v in ipairs( p or {}) do pen.c.fft_data[i] = pen.I.new( v ) end
		local out = fft( pen.c.fft_data ); pen.c.fft_data = nil
		return pen.t.clone( out )
	end)
end

-- pen.magic_draw = pen.magic_draw or function( path, w, h ) --fucking bullshit
-- 	pen.init_pipeline( pen.INIT_THREADS.DRAWER, { path, string.sub( 10000 + w, -4, -1 )..string.sub( 10000 + h, -4, -1 )})
-- end
pen.magic_write = pen.magic_write or function( path, file )
	pen.init_pipeline( pen.INIT_THREADS.WRITER, { path, string.gsub( string.gsub( file, "\n", "\\n" ), "\t", "\\t" )})
end
pen.t2f = pen.t2f or function( name, text )
	if( pen[ name ] == nil ) then
		local memo = table.concat({ "t2f_", name, "_memo" })
        if( pen[ memo ] ~= nil ) then
            pen[ name ] = dofile( pen[ memo ])
            pen[ memo ] = nil
        else
            local num = tonumber( GlobalsGetValue( pen.INDEX_T2F, "0" ))
            GlobalsSetValue( pen.INDEX_T2F, num + 1 )
            local path = table.concat({ pen.FILE.t2f, num, ".lua" })
            pen.magic_write( path, "return "..text )
            pen[ memo ] = path
        end
	end
    
	return pen[ name ]
end

function pen.lib.sprite_builder( path, print_me )
	-- https://colab.research.google.com/drive/1s1b7Kr97Q5aUpzJrom12YszZQyWGRgsi?usp=sharing

	local pos_x, pos_y = -1, -1
	local step, dims, l = 0, { 0, 0 }, 0
	local xml = pen.lib.nxml.parse( pen.magic_read( path ))
	pen.t.loop( xml:all_of( "RectAnimation" ), function( i,v )
		local is_child = v.attr.parent ~= nil
		if( xml.attr.default_animation == v.attr.name ) then
			pos_x = tonumber( v.attr.pos_x )
			pos_y = tonumber( v.attr.pos_y )
			l = tonumber( v.attr.frames_per_row )
			dims[1] = tonumber( v.attr.frame_width )
			dims[2] = tonumber( v.attr.frame_height )
		elseif( not( is_child ) and pos_x ~= -1 ) then
			if( step == 0 ) then step = v.attr.pos_y - pos_y end
			pos_y = pos_y + step
			v.attr.pos_x = pos_x
			v.attr.pos_y = pos_y
			v.attr.frames_per_row = l
			v.attr.frame_width = dims[1]
			v.attr.frame_height = dims[2]
		end

		if( not( is_child )) then return end
		local p = pen.t.loop( xml:all_of( "RectAnimation" ), function( e,p )
			if( p.attr.name == v.attr.parent ) then return p end
		end)

		v.children = p.children
		pen.t.loop( p.attr, function( k,a ) v.attr[k] = v.attr[k] or a end)
		v.attr.parent = nil
	end)
	if( print_me ) then print( tostring( xml )) end
	pen.magic_write( path, tostring( xml ))
end

function pen.lib.font_builder( font, chars, atlas, data ) --search the id at https://symbl.cc/
	chars, data = chars or {}, data or {}

	local xml = pen.lib.nxml.parse( ModDoesFileExist( font ) and pen.magic_read( font ) or pen.FILE_XML_FONT )
	if( data.pic ) then xml:first_of( "Texture" ).content = { data.pic } end
	if( data.height ) then xml:first_of( "LineHeight" ).content = { data.height } end
	if( data.char_padding ) then xml:first_of( "CharSpace" ).content = { data.char_padding } end
	if( data.word_padding ) then xml:first_of( "WordSpace" ).content = { data.word_padding } end
	local pic_id, pic = 0, xml:first_of( "Texture" ):text()
	local _, pic_w, pic_h = pen.magic_draw( pic, 0, 0 )
	-- pen.t.loop( xml:all_of( "QuadChar" ), function( i, c )
	-- 	local new_x = c.attr.rect_x + c.attr.rect_w + 2
	-- 	if( pic_w < new_x ) then pic_w = new_x end
	-- 	local new_y = c.attr.rect_y + c.attr.rect_h + 2
	-- 	if( pic_h < new_y ) then pic_h = new_y end
	-- end)

	local new_chars, x_memo = {}, pic_w + 1
	for i,c in pairs( chars ) do
		local got_some = pen.t.loop( xml:all_of( "QuadChar" ), function( i, c )
			if( c.attr.id == i ) then return true end
		end)
		if( not( got_some )) then
			chars[ i ].forced = true
			table.insert( xml.children, {
				name = "QuadChar",
				children = {},
				attr = {
					id = i, width = 0,
					offset_x = 0, offset_y = 0,
					rect_h = 0, rect_w = 0,
					rect_x = 0, rect_y = 0,
				},
			})
		end
	end
	pen.t.loop( xml:all_of( "QuadChar" ), function( i, c )
		if( chars[ c.attr.id ] == nil ) then return end
		if( not( chars[ c.attr.id ].forced )) then return end
		
		c.attr.rect_x = x_memo
		c.attr.rect_y = chars[ c.attr.id ].pos[2] or 0
		c.attr.width = chars[ c.attr.id ].pos[3]
		table.insert( new_chars, {
			chars[ c.attr.id ].pos[1],
			chars[ c.attr.id ].pos[2],
			chars[ c.attr.id ].pos[3],
			c.attr.rect_x, c.attr.rect_y,
		})
		c.attr.rect_w = chars[ c.attr.id ].rect_w
		c.attr.rect_h = chars[ c.attr.id ].rect_h
		c.attr.offset_x = chars[ c.attr.id ].offset_x or 0
		c.attr.offset_y = chars[ c.attr.id ].offset_y or 0
		x_memo = x_memo + c.attr.width + 1
	end)
	
	if( pen.vld( atlas )) then
		pic_id, pic = pen.pic_builder( pic, pic_w + ( pen.t.count( chars ) + 5 )*10, pic_h )
		if( not( pen.vld( pic_id ))) then return end
		xml:first_of( "Texture" ).content = { pic }
		pen.t.loop( new_chars, function( i, v )
			pen.pic_paster( pic_id, pen.magic_draw( atlas, 0, 0 ), { v[3], pic_h }, { v[4], v[5]}, { v[1], v[2]})
		end)
	end
	
	pen.magic_write( font, tostring( xml ))
end

-- Exposure Types: contact, wetting, breathing, effect
-- Default Damage Types: heal, burn, curse, poison, piercing, radiation, corrosion
-- Extra Damage Types: heat, cold, magic, light, pollution, dissolution, purification
-- damage values are total harm per frame per second for a fully submerged entity
function pen.lib.set_matter_damage( hooman, data )
	local dmg_tbl = pen.MATTER_EXPOSURES

	local dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
	if( not( pen.vld( dmg_comp, true ))) then return end
	local char_comp = EntityGetFirstComponentIncludingDisabled( hooman, "CharacterDataComponent" )
	if( not( pen.vld( char_comp, true ))) then return end

	data = data or {}
	data.matter_overrides = data.matter_overrides or {}
	data.body_matter = data.body_matter or ComponentGetValue2( dmg_comp, "ragdoll_material" )
	data.blood_matter = data.blood_matter or ComponentGetValue2( dmg_comp, "blood_material" )
	data.breathing_immune = data.breathing_immune or not( ComponentGetValue2( dmg_comp, "air_needed" ))
	data.no_burn = data.no_burn or ( ComponentGetValue2( dmg_comp, "fire_damage_amount" ) == 0 )

	--immune to own blood type and body_matter
	--check reactions with body_matter to apply damage

	local matters, old_matters = ComponentGetValue2( dmg_comp, "materials_that_damage" ), {}
	for value in string.gmatch( matters, pen.ptrn( "," )) do table.insert( old_matters, value ) end
	local damages, old_damages = ComponentGetValue2( dmg_comp, "materials_how_much_damage" ), {}
	for value in string.gmatch( damages, pen.ptrn( "," )) do table.insert( old_damages, tonumber( value )) end
	matters, damages = "", ""

	local c_min_x = ComponentGetValue2( char_comp, "collision_aabb_min_x" )
	local c_max_x = ComponentGetValue2( char_comp, "collision_aabb_max_x" )
	local c_min_y = ComponentGetValue2( char_comp, "collision_aabb_min_y" )
	local c_max_y = ComponentGetValue2( char_comp, "collision_aabb_max_y" )
	local k = 25*60*math.abs( c_max_x - c_min_x )*math.abs( c_max_y - c_min_y )

	--define custom damage types in xml
	local function damage_compiler( name, custom, data )
		custom = data.matter_overrides[ name ] or pen.t.unarray( pen.t.pack( custom ))
		if( not( pen.vld( custom ))) then custom = nil end
		local dmg_data = pen.get_hybrid_table( custom or dmg_tbl[ name ], true )
		if( not( pen.vld( dmg_data ))) then return 0 end

		local matter_mult = dmg_data[2] or 1
		dmg_data = dmg_tbl[ dmg_data[1]] or dmg_data

		local total, got_thresholded = 0, false
		local exposures = { "contact", "wetting", "breathing" }
		local default_types = { "heal", "burn", "curse", "poison", "piercing", "radiation", "corrosion" }
		local extra_types = { "heat", "cold", "magic", "light", "pollution", "dissolution", "purification" }
		pen.t.loop( exposures, function( i, exposure )
			if( not( data.effect_affected ) and dmg_data.effect ) then return true end
			if( data[ exposure.."_immune" ]) then return end
			local e_mult = dmg_data[ exposure ]
			if( e_mult == nil ) then return end

			pen.t.loop( default_types, function( e, dmg_type )
				local t_mult = dmg_data[ dmg_type ]
				if( t_mult == nil ) then return end
				local dmg = matter_mult*e_mult*t_mult*dmg_data.dmg

				local threshold = data[ "threshold_"..dmg_type ]
				got_thresholded, threshold = threshold ~= nil, threshold or 0
				if( threshold < dmg ) then total = total + ( dmg - threshold ) end
			end)

			pen.t.loop( extra_types, function( e, dmg_type )
				local t_mult = dmg_data[ dmg_type ]
				if( t_mult == nil ) then return end
				local dmg = matter_mult*e_mult*t_mult*dmg_data.dmg

				local threshold = data[ "threshold_"..dmg_type ]
				got_thresholded, threshold = threshold ~= nil, threshold or dmg
				if( threshold < dmg ) then total = total + ( dmg - threshold ) end
			end)
		end)

		local dmg = nil
		for i,v in ipairs( old_matters ) do
			if( v == name ) then old_dmg = old_damages[i]; break end
		end
		if( not( data.update_existing ) or got_thresholded ) then
			return total/k
		else return dmg or 0 end
	end

	local xml = pen.lib.nxml.parse( pen.magic_read( "data/materials.xml" ))
	pen.t.loop( xml.children, function( i,v )
		if( v.name ~= "CellData" and v.name ~= "CellDataChild" ) then return end
		local dmg = damage_compiler( v.attr.name, v.attr.dmg_tbl, data )
		EntitySetDamageFromMaterial( hooman, v.attr.name, dmg )
	end)
end

function pen.lib.player_builder( hooman, func )
	local is_vectored = ModIsEnabled( "vector_core" )

	local overrides = pen.GENERIC_CHAR_SETUP
	pen.t.loop( overrides, function( name, values )
		local nuke_it = values == true
		pen.magic_comp( hooman, name, function( comp_id, v_tbl, is_enabled )
			if( nuke_it ) then EntityRemoveComponent( hooman, comp_id ); return end
			pen.t.loop( values, function( field, value ) pen.magic_comp( comp_id, field, value ) end)
		end)
	end)

	local data = { hooman = hooman }
	data.arm_id = pen.get_child( hooman, "arm_r" )
	local inh_comp = EntityGetFirstComponentIncludingDisabled( data.arm_id, "InheritTransformComponent" )
	ComponentSetValue2( inh_comp, "parent_hotspot_tag", "arm_r" )
	local hot_comp = EntityGetFirstComponentIncludingDisabled( data.arm_id, "HotspotComponent" )
	ComponentSetValue2( hot_comp, "sprite_hotspot_name", "" )
	ComponentSetValue2( hot_comp, "offset", 0, 0 )
	EntityRemoveComponent( data.arm_id, EntityGetFirstComponentIncludingDisabled( data.arm_id, "SpriteComponent" ))
	
	EntityKill( pen.get_child( hooman, "cape" ))
	EntityKill( pen.get_child( hooman, "no_heal_in_meat_biome" ))

	local player_path = EntityGetFilename( hooman )
	for i,v in ipairs({ "inventory_quick", "inventory_full" }) do
		pen.child_play( pen.get_child( hooman, v ), function( parent, child, k )
			if( EntityGetFilename( child ) == player_path ) then EntityKill( child ) end
		end)
	end

	data.sfx_comp = EntityGetFirstComponentIncludingDisabled( hooman, "AudioComponent" )
	data.char_comp = EntityGetFirstComponentIncludingDisabled( hooman, "CharacterDataComponent" )
	data.plat_comp = EntityGetFirstComponentIncludingDisabled( hooman, "CharacterPlatformingComponent" )
	data.dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
	data.ing_comp = EntityGetFirstComponentIncludingDisabled( hooman, "IngestionComponent" )
	data.pick_comp = EntityGetFirstComponentIncludingDisabled( hooman, "ItemPickUpperComponent" )
	data.kick_comp = EntityGetFirstComponentIncludingDisabled( hooman, "KickComponent" )
	data.bubl_comp = EntityGetFirstComponentIncludingDisabled( hooman, "LiquidDisplacerComponent" )
	data.suck_comp = EntityGetFirstComponentIncludingDisabled( hooman, "MaterialSuckerComponent" )
	data.shot_comp = EntityGetFirstComponentIncludingDisabled( hooman, "PlatformShooterPlayerComponent" )
	data.coll_comp = EntityGetFirstComponentIncludingDisabled( hooman, "PlayerCollisionComponent" )
	data.inv_comp = EntityGetFirstComponentIncludingDisabled( hooman, "Inventory2Component" )
	
	data.pic_char = EntityAddComponent2( hooman, "SpriteComponent", {
		_tags = "character",
		rect_animation = "stand", z_index = 0.6,
		image_file = "mods/penman/extra/pics/player.xml" })
	data.pic_aim = EntityAddComponent2( hooman, "SpriteComponent", {
		_tags = "aiming_reticle",
		image_file = "data/ui_gfx/mouse_cursor.png",
		emissive = true, visible = false, has_special_scale = true,
		offset_x = -42.5, offset_y = -25, z_index = -10000 })
	if( pen.vld( func )) then data = func( hooman, data ) or data end
	
	local pic_xml = pen.lib.nxml.parse( pen.magic_read( ComponentGetValue2( data.pic_char, "image_file" )))
	ComponentSetValue2( data.pic_char, "offset_x", tonumber( pic_xml.attr.offset_x or 0 ))
	ComponentSetValue2( data.pic_char, "offset_y", tonumber( pic_xml.attr.offset_y or 0 ))
	EntityRefreshSprite( hooman, data.pic_char )
	
	local is_player = pic_xml.attr.is_player ~= nil
	
	local char_w, char_h = 0, 0
	local frame_w, frame_h = 0, 0
	local collider, hitboxes = {}, {}
	pen.t.loop( pic_xml:all_of( "RectAnimation" ), function( i,v )
		if( pic_xml.attr.default_animation == v.attr.name ) then
			frame_w = tonumber( v.attr.frame_width or 0 )
			frame_h = tonumber( v.attr.frame_height or 0 )
		elseif( v.attr.name == "icon" ) then
			char_w = tonumber( v.attr.frame_width or 0 )
			char_h = tonumber( v.attr.frame_height or 0 )
		elseif( v.attr.name == "collider" ) then
			collider.w = tonumber( v.attr.frame_width or 0 )
			collider.h = tonumber( v.attr.frame_height or 0 ) + 0.1
			collider.x = tonumber( v.attr.offset_x or 0 )
			collider.y = tonumber( v.attr.offset_y or 0 ) - 1
		elseif( string.find( v.attr.name, "^hitbox" ) ~= nil ) then
			local tag = ""
			if( v.attr.name ~= "hitbox" ) then
				tag = string.gsub( v.attr.name, "^hitbox_", "" )
			end
			table.insert( hitboxes, {
				tag = tag,
				state = v.attr.state == "true",
				dmg = tonumber( v.attr.dmg or 1 ),
				w = tonumber( v.attr.frame_width or 0 ),
				h = tonumber( v.attr.frame_height or 0 ) + 0.1,
				x = tonumber( v.attr.offset_x or 0 ),
				y = tonumber( v.attr.offset_y or 0 ),
			})
		end
	end)
	
	ComponentSetValue2( data.dmg_comp, "ragdoll_offset_x", -frame_w/2 )
	ComponentSetValue2( data.dmg_comp, "ragdoll_offset_y", -frame_h/2 )
	ComponentSetValue2( data.char_comp, "buoyancy_check_offset_y", tonumber( pic_xml.attr.center_y or 0 ))
	ComponentSetValue2( data.char_comp, "collision_aabb_max_x", collider.w + collider.x )
	ComponentSetValue2( data.char_comp, "collision_aabb_max_y", collider.h + collider.y )
	ComponentSetValue2( data.char_comp, "collision_aabb_min_x", collider.x )
	ComponentSetValue2( data.char_comp, "collision_aabb_min_y", collider.y )
	ComponentSetValue2( data.char_comp, "climb_over_y", math.floor( char_h/5 ))
	ComponentSetValue2( data.char_comp, "eff_hg_size_x", char_w/2 )
	ComponentSetValue2( data.bubl_comp, "radius", char_w )

	pen.t.loop( hitboxes, function( i,v )
		EntityAddComponent2( hooman, "HitboxComponent", {
			_tags = v.tag,
			_enabled = v.state,

			is_item = false,
			is_player = is_player,
			is_enemy = not( is_player ),

			damage_multiplier = v.dmg,
			aabb_max_x = v.w + v.x, aabb_min_x = v.x,
			aabb_max_y = v.h + v.y, aabb_min_y = v.y,
		})
	end)

	pen.t.loop( pic_xml:all_of( "Hotspot" ), function( i,v )
		EntityAddComponent2( hooman, "HotspotComponent", {
			_tags = v.attr.name,
			sprite_hotspot_name = v.attr.name,
			transform_with_scale = true,
		})
	end)
	ComponentSetValue2( EntityAddComponent2( hooman, "HotspotComponent", {
		_tags = "kick_pos",
		transform_with_scale = true,
	}), "offset", char_w/2, collider.h + collider.y )
	ComponentSetValue2( EntityAddComponent2( hooman, "HotspotComponent", {
		_tags = "crouch_sensor",
		transform_with_scale = true,
	}), "offset", 0, -char_h + ( collider.h + collider.y ))
	
	return data
end

function pen.lib.nxml2entity()
end

function pen.lib.entity2nxml()
end

pen.hybrid = pen.hybrid or {}

-- function pen.hybrid.gui_builder( init_func )
-- 	if( EntityGetIsAlive( gui or 0 )) then
-- 		local storage_going = get_storage( gui, "is_going" )
-- 		if( not( ComponentGetValue2( storage_going, "value_bool" ))) then
-- 			ComponentSetValue2( storage_going, "value_bool", true )
-- 		end
-- 	else
-- 		--attach to world entity as child

-- 		gui = EntityLoad( "mods/white_room/files/props/_base_hybrid_gui.xml", x, y )
-- 		if( extra_action ~= nil ) then
-- 			extra_action( gui )
-- 		end
-- 	end
	
-- 	return gui
-- end

-- function pen.new_hybrid_pic( core_id, uid, pic_info, pos_info, interaction, extra_action )
-- 	uid = "pic_"..uid
-- 	pic_info = pic_info or {}
-- 	pos_info = pos_info or {}
	
-- 	local x, y = EntityGetTransform( core_id )
	
-- 	local pic_id = get_hooman_child( core_id, uid ) or 0
-- 	if( pic_id ~= 0 ) then
-- 		return
-- 	end
	
-- 	pic_id = EntityLoad( "mods/white_room/files/props/_base_hybrid_gui_object.xml", x, y + 500 )
-- 	EntitySetName( pic_id, uid )
	
-- 	local pic_comp = edit_component_ultimate( pic_id, "SpriteComponent", function(comp,vars)
-- 		ComponentSetValue2( comp, "image_file", pic_info.pic )
-- 		ComponentSetValue2( comp, "offset_x", pic_info.x or 0 )
-- 		ComponentSetValue2( comp, "offset_y", pic_info.y or 0 )
-- 		ComponentSetValue2( comp, "alpha", pic_info.alpha or 1 )
-- 		ComponentSetValue2( comp, "emissive", pic_info.emissive or false )
-- 		ComponentSetValue2( comp, "fog_of_war_hole", pic_info.fog_hole or false )
-- 		ComponentSetValue2( comp, "additive", pic_info.additive or false )
-- 		ComponentSetValue2( comp, "smooth_filtering", pic_info.smooth or false )
-- 		ComponentSetValue2( comp, "visible", pic_info.visible or false )
		
-- 		ComponentSetValue2( comp, "z_index", pos_info.z or -100 )
		
-- 		if( pic_info.s_x ~= nil or pic_info.s_y ~= nil ) then
-- 			ComponentSetValue2( comp, "has_special_scale", true )
-- 			ComponentSetValue2( comp, "special_scale_x", pic_info.s_x or 1 )
-- 			ComponentSetValue2( comp, "special_scale_y", pic_info.s_y or 1 )
-- 		end
		
-- 		EntityRefreshSprite( pic_id, comp )
-- 	end)
-- 	if( pic_info.is_fogless or false ) then
-- 		clone_comp( pic_id, pic_comp, { fog_of_war_hole = true, smooth_filtering = true, })
-- 	end
-- 	set_transform( pic_id, pos_info.x, pos_info.y, pos_info.s_x, pos_info.s_y, pos_info.r ~= nil and math.rad( pos_info.r ) or nil )
	
-- 	if( interaction or false ) then
-- 		EntityAddComponent( pic_id, "VariableStorageComponent", 
-- 		{
-- 			name = "trigger_state",
-- 			value_int = 0,
-- 		})
		
-- 		EntityAddComponent( pic_id, "VariableStorageComponent", 
-- 		{
-- 			name = "is_hovered",
-- 			value_bool = "0",
-- 		})
-- 		if( type( interaction ) == "string" ) then
-- 			EntityAddComponent( pic_id, "VariableStorageComponent", 
-- 			{
-- 				name = "action_hover",
-- 				value_string = interaction,
-- 			})
-- 			EntityAddComponent( pic_id, "VariableStorageComponent", 
-- 			{
-- 				name = "hover_delay",
-- 				value_int = 30,
-- 			})
-- 		end
-- 	end
	
-- 	EntityAddChild( core_id, pic_id )
	
-- 	if( extra_action ~= nil ) then
-- 		extra_action( pic_id )
-- 	end
	
-- 	return pic_id
-- end

-- function new_hybrid_button( core_id, uid, pic_info, pos_info, script_path, extra_action )
-- 	uid = "button_"..uid
-- 	script_path = script_path or ""
-- 	if( type( script_path ) ~= "table" ) then
-- 		script_path = { script_path }
-- 	end
	
-- 	local bttn_id = new_hybrid_pic( core_id, uid, pic_info, pos_info, script_path[2] or 1, extra_action )
-- 	if( bttn_id == nil ) then
-- 		return
-- 	end
	
-- 	if(( script_path[1] or "" ) ~= "" ) then
-- 		EntityAddComponent( bttn_id, "VariableStorageComponent", 
-- 		{
-- 			name = "action",
-- 			value_string = script_path[1],
-- 		})
-- 	end
	
-- 	return bttn_id
-- end

-- function new_hybrid_dragger( core_id, uid, sans_info, pic_info, pos_info, extra_action )
-- 	uid = "dragger_"..uid
-- 	sans_info = sans_info or {}
-- 	sans_info.center = sans_info.center or {}
-- 	sans_info.dims = sans_info.dims or {}
	
-- 	local dragger_id = new_hybrid_pic( core_id, uid, pic_info, pos_info, sans_info.tooltip or 1, extra_action )
-- 	if( dragger_id == nil ) then
-- 		return
-- 	end
	
-- 	EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 	{
-- 		name = "drgr_center_x",
-- 		value_float = sans_info.center[1] or 0,
-- 	})
-- 	EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 	{
-- 		name = "drgr_center_y",
-- 		value_float = sans_info.center[2] or 0,
-- 	})
	
-- 	EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 	{
-- 		name = "drgr_dim_a",
-- 		value_float = sans_info.dims[1] or 0,
-- 	})
-- 	EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 	{
-- 		name = "drgr_dim_b",
-- 		value_float = sans_info.dims[2] or 0,
-- 	})
	
-- 	EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 	{
-- 		name = "drgr_is_active",
-- 		value_bool = "0",
-- 	})
-- 	EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 	{
-- 		name = "drgr_drift_x",
-- 		value_float = 0,
-- 	})
-- 	EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 	{
-- 		name = "drgr_drift_y",
-- 		value_float = 0,
-- 	})
-- 	if( sans_info.is_local or false ) then
-- 		EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 		{
-- 			name = "drgr_last_x",
-- 			value_float = 0,
-- 		})
-- 		EntityAddComponent( dragger_id, "VariableStorageComponent", 
-- 		{
-- 			name = "drgr_last_y",
-- 			value_float = 0,
-- 		})
-- 	end
	
-- 	return dragger_id
-- end

-- function new_hybrid_focus( core_id, uid, pic_info, pos_info )
-- 	pic_info = pic_info or {}
-- 	pic_info.is_small = pic_info.is_small or false
-- 	local path = "mods/white_room/files/props/gui/advanced_window/button_focus_"..( pic_info.is_small and "small_" or "" )
-- 	pic_info.pic = path.."A.png"
	
-- 	return add_ctrl_script( new_hybrid_button( core_id, "focus_"..uid, pic_info, pos_info, { "mods/white_room/files/props/gui/advanced_window/actions/focus_action.lua", "[FOCUS]", }, function( new_button )
-- 		EntityAddComponent( new_button, "VariableStorageComponent", 
-- 		{
-- 			name = "is_going",
-- 			value_bool = 0,
-- 		})
-- 		EntityAddComponent( new_button, "VariableStorageComponent", 
-- 		{
-- 			name = "pic_path",
-- 			value_string = path,
-- 		})
-- 		EntityAddComponent( new_button, "VariableStorageComponent", 
-- 		{
-- 			name = "offset_x",
-- 			value_float = pic_info.drift_x or 0,
-- 		})
-- 		EntityAddComponent( new_button, "VariableStorageComponent", 
-- 		{
-- 			name = "offset_y",
-- 			value_float = pic_info.drift_y or 0,
-- 		})
-- 	end), "mods/white_room/files/props/gui/advanced_window/actions/focus_action.lua" )
-- end

-- function new_hybrid_text( core_id, uid, text_info, pos_info, extra_action )
-- 	uid = "text_"..uid.."_"
-- 	text_info = text_info or {}
-- 	text_info.text = text_info.text or "[NIL]"
-- 	text_info.font = text_info.font or 5
-- 	pos_info = pos_info or {}
-- 	pos_info.z = pos_info.z or -100
	
-- 	if( type( text_info.text ) ~= "table" ) then
-- 		text_info.text = { text_info.text, }
-- 	end
	
-- 	local x, y = EntityGetTransform( core_id )
	
-- 	local core_uid = uid.."core"
-- 	local text_id = get_hooman_child( core_id, core_uid ) or 0
-- 	if( text_id ~= 0 ) then
-- 		return
-- 	end
	
-- 	text_id = EntityLoad( "mods/white_room/files/props/_base_hybrid_gui_text.xml", x, y + 500 )
-- 	EntitySetName( text_id, core_uid )
	
-- 	local colours = { "white", "black", "grey", "silver", "red", "gold", "green", }
-- 	edit_component_ultimate( text_id, "SpriteComponent", function(comp,vars)
-- 		if( type( text_info.font ) == "number" ) then
-- 			text_info.font = "mods/white_room/files/pics/fonts/_default_font_"..colours[text_info.font]..".xml"
-- 		end
		
-- 		ComponentSetValue2( comp, "text", text_info.text[1] )
-- 		ComponentSetValue2( comp, "image_file", text_info.font )
-- 		ComponentSetValue2( comp, "offset_x", text_info.x or 0 )
-- 		ComponentSetValue2( comp, "offset_y", text_info.y or 0 )
-- 		ComponentSetValue2( comp, "alpha", text_info.alpha or 1 )
-- 		ComponentSetValue2( comp, "emissive", text_info.emissive or false )
-- 		ComponentSetValue2( comp, "fog_of_war_hole", text_info.fog_hole or false )
-- 		ComponentSetValue2( comp, "additive", text_info.additive or false )
-- 		ComponentSetValue2( comp, "smooth_filtering", text_info.smooth or false )
-- 		ComponentSetValue2( comp, "visible", text_info.visible or false )
		
-- 		ComponentSetValue2( comp, "z_index", pos_info.z )
		
-- 		if( text_info.s_x ~= nil or text_info.s_y ~= nil ) then
-- 			ComponentSetValue2( comp, "has_special_scale", true )
-- 			ComponentSetValue2( comp, "special_scale_x", text_info.s_x or 1 )
-- 			ComponentSetValue2( comp, "special_scale_y", text_info.s_y or 1 )
-- 		end
		
-- 		EntityRefreshSprite( text_id, comp )
-- 	end)
-- 	set_transform( text_id, pos_info.x, pos_info.y, pos_info.s_x, pos_info.s_y, pos_info.r ~= nil and math.rad( pos_info.r ) or nil )
-- 	EntityAddChild( core_id, text_id )
	
-- 	local txt = magic_copy( text_info.text )
-- 	if( #txt > 1 ) then
-- 		local offset_y = 0
-- 		for k,line in ipairs( txt ) do
-- 			if( k > 1 ) then
-- 				text_info.text = { line, }
-- 				offset_y = offset_y + 9
-- 				new_hybrid_text( text_id, uid..k, text_info, { y = offset_y, z = pos_info.z, i = k, }, extra_action )
-- 			end
-- 		end
-- 	end
	
-- 	if( extra_action ~= nil ) then
-- 		extra_action( text_id, pos_info.i or 1 )
-- 	end
	
-- 	return text_id
-- end

-- function new_hybrid_interface( gui, uid, pic_x, pic_y, pic_z, s_x, s_y, debugged ) --fucking shit is being symmetrically scaled by x even though it appears to be proper
-- 	s_x = s_x or 1
-- 	s_y = s_y or 1
-- 	s_x, s_y = math.abs( s_x ), math.abs( s_y )
	
-- 	local is_vertical = s_x < s_y
-- 	local width = is_vertical and s_x or s_y
-- 	local clicked, r_clicked, hovered = false, false, false
	
-- 	local function do_interface( p_x, p_y )
-- 		uid = new_image( gui, uid, p_x, p_y, pic_z or 0, "mods/white_room/files/pics/debug_"..( debugged and "purple" or "null" )..".png", width, width, 1, true )
-- 		local c, r_c, h = GuiGetPreviousWidgetInfo( gui )
-- 		clicked, r_clicked, hovered = clicked or c, r_clicked or r_c, hovered or h
-- 	end
	
-- 	if( s_x ~= 0 and s_y ~= 0 ) then
-- 		local count = math.floor( is_vertical and s_y/s_x or s_x/s_y )
-- 		for i = 1,count do
-- 			do_interface( pic_x, pic_y )
-- 			if( is_vertical ) then
-- 				pic_y = pic_y + width
-- 			else
-- 				pic_x = pic_x + width
-- 			end
-- 		end
-- 		local leftover = ( is_vertical and s_y or s_x ) - count*width
-- 		if( leftover > 0 ) then
-- 			local drift = width - leftover
-- 			if( is_vertical ) then
-- 				pic_y = pic_y - drift
-- 			else
-- 				pic_x = pic_x - drift
-- 			end
-- 			do_interface( pic_x, pic_y )
-- 		end
-- 	end
	
-- 	return uid+1, clicked, r_clicked, hovered
-- end

-- function new_scroller( core_id, uid, s_info, pos_info )	
-- 	uid = "childfree_scrllr_"..uid.."_"
-- 	s_info = s_info or {}
-- 	s_info.edge = s_info.edge or { -5, 5, }
-- 	s_info.extra_drift = s_info.extra_drift or { 0, 0, }
-- 	pos_info = pos_info or {}
-- 	pos_info.z = pos_info.z or -100
	
-- 	local gui_core = s_info.pic or "mods/white_room/files/props/gui/scroller/"
	
-- 	core_id = new_hybrid_pic( core_id, uid.."rail_top", {
-- 		pic = gui_core.."rail_end.png",
-- 	}, {
-- 		x = pos_info.x,
-- 		y = pos_info.y,
-- 		r = pos_info.r,
-- 		s_x = pos_info.s_x,
-- 		s_y = pos_info.s_y,
-- 		z = pos_info.z,
-- 	})
	
-- 	if( core_id ~= nil ) then
-- 		local function marker( dude_id )
-- 			EntityAddTag( dude_id, "main_structure" )
-- 			return dude_id
-- 		end
	
-- 		marker( new_hybrid_pic( core_id, uid.."rail_body", {
-- 			pic = gui_core.."rail_body.png",
-- 		}, {
-- 			y = 0.5,
-- 			s_y = s_info.length + 1,
-- 			z = pos_info.z + 0.0001,
-- 		}))
-- 		marker( new_hybrid_pic( core_id, uid.."rail_bottom", {
-- 			pic = gui_core.."rail_end.png",
-- 		}, {
-- 			y = s_info.length + 1,
-- 			z = pos_info.z,
-- 		}))
		
-- 		EntitySetName( add_ctrl_script( marker( new_hybrid_dragger( core_id, "", {
-- 			center = { 0, 0, },
-- 			dims = { 4, 6, },
-- 			is_local = true,
-- 		}, {
-- 			pic = gui_core.."dragger_body.png",
-- 			x = 5,
-- 			y = 6.5,
-- 		}, {
-- 			x = 2,
-- 			y = 7.5,
-- 			z = pos_info.z - 0.00015,
-- 		}, function( dude_id )
-- 			EntityAddComponent( dude_id, "VariableStorageComponent", 
-- 			{
-- 				name = "scroller_offset",
-- 				value_float = 0,
-- 			})
-- 			EntityAddComponent( dude_id, "VariableStorageComponent", 
-- 			{
-- 				name = "scroller_ratio",
-- 				value_float = -1,
-- 			})
-- 			EntityAddComponent( dude_id, "VariableStorageComponent", 
-- 			{
-- 				name = "scroller_limit",
-- 				value_float = s_info.length,
-- 			})
-- 			EntityAddComponent( dude_id, "VariableStorageComponent", 
-- 			{
-- 				name = "scroller_extra_drift",
-- 				value_string = magic_packer( s_info.extra_drift ),
-- 			})
-- 			EntityAddComponent( dude_id, "VariableStorageComponent", 
-- 			{
-- 				name = "step",
-- 				value_float = s_info.step or 2,
-- 			})
-- 			EntityAddComponent( dude_id, "VariableStorageComponent", 
-- 			{
-- 				name = "edge_a",
-- 				value_float = s_info.edge[1],
-- 			})
-- 			EntityAddComponent( dude_id, "VariableStorageComponent", 
-- 			{
-- 				name = "edge_b",
-- 				value_float = s_info.edge[2],
-- 			})
-- 		end)), gui_core.."controller.lua" ), "dragger_entity" )
		
-- 		for i = 1,2 do
-- 			marker( new_hybrid_button( core_id, uid.."dragger_btn_"..i, {
-- 				pic = gui_core.."dragger_button.png",
-- 			}, {
-- 				x = -1,
-- 				y = ( i == 1 and 0 or s_info.length + 2 ),
-- 				z = pos_info.z - 0.0001,
-- 				s_y = ( i == 1 and 1 or -1 ),
-- 			}, gui_core.."button.lua" ))
-- 		end
-- 	end
	
-- 	return core_id
-- end

-- function pen.new_glowing( pic_x, pic_y, pic_z, s_x, s_y, color, alpha )
-- 	pen.new_image( pic_x, pic_y, pic_z, "mods/penman/extra/pics/glow.png", {
-- 		is_centered = true, s_x = ( s_x or 1 )/150, s_y = ( s_y or 1 )/150, color = color, alpha = alpha })
-- 	-- do procedurally assembled rectangle is s_x or s_y is less than 0
-- end

--[SAFE] ^^^^^^^^^^^^
if( io == nil ) then return end
--[UNSAFE] vvvvvvvvvv

--bitser
--patcher
--pollnet