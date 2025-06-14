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

function pen.lib.player_builder( hooman, func )
	local overrides = {
		CharacterDataComponent = {
			mass = 1,
			gravity = 0,
			ground_stickyness = 0,
			liquid_velocity_coeff = 0,

			collision_aabb_max_x = 1,
			collision_aabb_max_y = 1,
			collision_aabb_min_x = -1,
			collision_aabb_min_y = -1,
			buoyancy_check_offset_y = 0,

			climb_over_y = 5,
			check_collision_max_size_x = 5,
			check_collision_max_size_y = 5,
			
			effect_hit_ground = true,
			eff_hg_offset_y = 1.5,
			eff_hg_position_x = 0,
			eff_hg_position_y = 5,
			eff_hg_size_x = 5,
			eff_hg_size_y = 5,
			eff_hg_damage_max = 0,
			eff_hg_damage_min = 0,
			eff_hg_velocity_max_x = 20,
			eff_hg_velocity_max_y = -10,
			eff_hg_velocity_min_x = -20,
			eff_hg_velocity_min_y = -30,
			eff_hg_update_box2d = true,
			eff_hg_b2force_multiplier = 0.00001,

			flying_needs_recharge = true,
			fly_time_max = 5,
			fly_recharge_spd = 0.5,
			fly_recharge_spd_ground = 5,
			flying_in_air_wait_frames = 50,
			flying_recharge_removal_frames = 5,
		},

		CharacterPlatformingComponent = {
			accel_x = 0.15,
			accel_x_air = 0.05,
			run_velocity = 100,
			pixel_gravity = 500,
			jump_velocity_x = 50,
			jump_velocity_y = -100,

			velocity_max_x = 500,
			velocity_max_y = 500,
			velocity_min_x = -500,
			velocity_min_y = -500,

			run_animation_velocity_switching_enabled = false,
			run_animation_velocity_switching_threshold = 50,
			turn_animation_frames_between = 0,
			turning_buffer = 0,

			fly_smooth_y = false,
			fly_speed_change_spd = 0.2,
			fly_speed_max_down = 50,
			fly_speed_max_up = 100,
			fly_speed_mult = 20,
			fly_velocity_x = 50,

			swim_drag = 0.95,
			swim_extra_horizontal_drag = 0.9,
			swim_up_buoyancy_coeff = 1,
			swim_idle_buoyancy_coeff = 1.25,
			swim_down_buoyancy_coeff = 0.25,
		},

		DamageModelComponent = {
			hp = 1,
			max_hp = 1,
			ui_report_damage = false,
			ui_force_report_damage = false,
			minimum_knockback_force = 0,
			critical_damage_resistance = 0,
			
			falling_damages = false,
			falling_damage_damage_max = 0,
			falling_damage_damage_min = 0,
			falling_damage_height_max = 0,
			falling_damage_height_min = 0,

			fire_damage_amount = 0.2,
			fire_damage_ignited_amount = 0.0005,
			fire_how_much_fire_generates = 5,
			fire_probability_of_ignition = 0.5,

			materials_create_messages = false,
			materials_that_create_messages = "",
			wet_status_effect_damage = 0,
			materials_damage = true,
			materials_damage_proportional_to_maxhp = false,
			material_damage_min_cell_count = 5,
			materials_how_much_damage = "",
			materials_that_damage = "",
			
			air_needed = true,
			air_in_lungs_max = 10,
			air_lack_of_damage = 0.5,
			
			blood_material = blood_fading,
			blood_multiplier = 1,
			blood_spray_create_some_cosmetic = true,
			blood_spray_material = blood,
			blood_sprite_directional = "",
			blood_sprite_large = "",
			
			create_ragdoll = true,
			ragdoll_offset_x = 0,
			ragdoll_offset_y = 0,
			ragdoll_filenames_file = "",
			ragdoll_fx_forced = "NONE",
			ragdoll_material = "meat",
			ragdoll_blood_amount_absolute = -1,
			ragdollify_child_entity_sprites = true,
			ragdollify_disintegrate_nonroot = false,
			ragdollify_root_angular_damping = 0,

			drop_items_on_death = false,
			physics_objects_damage = false,
			wait_for_kill_flag_on_death = false,
			in_liquid_shooting_electrify_prob = 0,

			[{ "damage_multipliers", "curse" }] = 1,
			[{ "damage_multipliers", "drill" }] = 1,
			[{ "damage_multipliers", "electricity" }] = 1,
			[{ "damage_multipliers", "explosion" }] = 1,
			[{ "damage_multipliers", "fire" }] = 1,
			[{ "damage_multipliers", "healing" }] = 1,
			[{ "damage_multipliers", "ice" }] = 1,
			[{ "damage_multipliers", "melee" }] = 1,
			[{ "damage_multipliers", "overeating" }] = 1,
			[{ "damage_multipliers", "physics_hit" }] = 1,
			[{ "damage_multipliers", "poison" }] = 1,
			[{ "damage_multipliers", "projectile" }] = 1,
			[{ "damage_multipliers", "radioactive" }] = 1,
			[{ "damage_multipliers", "slice" }] = 1,
		},

		IngestionComponent = {
			ingestion_capacity = 5000,
			ingestion_cooldown_delay_frames = 500,
			ingestion_reduce_every_n_frame = 5,
			overingestion_damage = 0.001,
			blood_healing_speed = 0.0005,
		},
		
		ItemPickUpperComponent = {
			drop_items_on_death = false,
			is_immune_to_kicks = true,
			is_in_npc = false,
		},

		KickComponent = {
			can_kick = true,
			kick_damage = 0.05,
			kick_knockback = 1,
			kick_radius = 5,
			max_force = 1,
			player_kickforce = 1,
			telekinesis_throw_speed = 0,
		},

		LiquidDisplacerComponent = {
			radius = 5,
			velocity_x = 50,
			velocity_y = 50,
		},
		
		MaterialSuckerComponent = {
			suck_gold = true,
			suck_health = true,
			barrel_size = 100,
			num_cells_sucked_per_frame = 10,
		},

		PlatformShooterPlayerComponent = {
			move_camera_with_aim = true,
			center_camera_on_this_entity = true,
			camera_max_distance_from_character = 50,
			aiming_reticle_distance_from_character = 50,

			alcohol_drunken_speed = 0.1,
			blood_fungi_drunken_speed = 0.1,
			blood_worm_drunken_speed = 0.1,
			stoned_speed = 0.1,

			eating_area_max = { 0, 0 },
			eating_area_min = { 0, 0 },
			eating_cells_per_frame = 0,
			eating_delay_frames = 20,
			eating_probability = 0,
		},

		PlayerCollisionComponent = {
			getting_crushed_threshold = 5,
			moving_up_before_getting_crushed_threshold = 5,
		},

		LuaComponent = true,
		SpriteComponent = true,
		HotspotComponent = true,
		HitboxComponent = true,
		VariableStorageComponent = true,
		
		ParticleEmitterComponent = true,
		SpriteParticleEmitterComponent = true,
		PhysicsPickUpComponent = true,
		GameLogComponent = true,
		GameStatsComponent = true,
		LightComponent = true,
		WalletComponent = true,
	}
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

	data.dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
	data.sfx_comp = EntityGetFirstComponentIncludingDisabled( hooman, "AudioComponent" )
	data.pic_char = EntityAddComponent2( hooman, "SpriteComponent", {
		_tags = "character",
		rect_animation = "stand", z_index = 0.6,
		image_file = "mods/penman/extra/pics/player.xml" })
	data.pic_aim = EntityAddComponent2( hooman, "SpriteComponent", {
		_tags = "aiming_reticle",
		image_file = "data/ui_gfx/mouse_cursor.png",
		emissive = true, visible = false, has_special_scale = true,
		offset_x = -42.5, offset_y = -25, z_index = -10000 })
	if( pen.vld( func )) then func( hooman, data ) end
	
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
	data.char_comp = EntityGetFirstComponentIncludingDisabled( hooman, "CharacterDataComponent" )
	ComponentSetValue2( data.char_comp, "buoyancy_check_offset_y", tonumber( pic_xml.attr.center_y or 0 ))
	ComponentSetValue2( data.char_comp, "collision_aabb_max_x", collider.w + collider.x )
	ComponentSetValue2( data.char_comp, "collision_aabb_max_y", collider.h + collider.y )
	ComponentSetValue2( data.char_comp, "collision_aabb_min_x", collider.x )
	ComponentSetValue2( data.char_comp, "collision_aabb_min_y", collider.y )
	ComponentSetValue2( data.char_comp, "eff_hg_size_x", char_w/2 )
	local bubble_comp = EntityGetFirstComponentIncludingDisabled( hooman, "LiquidDisplacerComponent" )
	ComponentSetValue2( bubble_comp, "radius", char_w )

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
	
	-- procedurally write materials_that_damage
	
	return data
end

function pen.lib.nxml2entity()
end

function pen.lib.entity2nxml()
end

--[SAFE] ^^^^^^^^^^^^
if( io == nil ) then return end
--[UNSAFE] vvvvvvvvvv

--bitser
--patcher
--pollnet