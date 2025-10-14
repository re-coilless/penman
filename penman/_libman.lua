-- third party lib based functionality

if( GameHasFlagRun( pen.FLAG_UPDATE_UTF )) then
	local the_concept_of_table_itself = dofile_once( "mods/penman/extra/lists/every_character.lua" )
	for i,the_concept_of_set_itself in ipairs( the_concept_of_table_itself ) do
		local the_concept_of_language_itself = string.gsub( string.gsub( pen.t2t( the_concept_of_set_itself ), "\n", "" ), "%s", "" )
		local the_concept_of_number_itself, the_concept_of_counter_itself = 0, 0
		for the_concept_of_character_itself in string.gmatch( the_concept_of_language_itself, "." ) do
			local the_concept_of_byte_itself = string.byte( the_concept_of_character_itself )
			if( the_concept_of_byte_itself == string.byte( "." )) then
				if( the_concept_of_number_itself > 0 and pen.BYTE2ID[ the_concept_of_number_itself ] == nil ) then
					local the_concept_of_i_itself = 1
					for str in string.gmatch( the_concept_of_language_itself, pen.ptrn( "%." )) do
						if( the_concept_of_i_itself == the_concept_of_counter_itself ) then
							pen.BYTE2ID[ the_concept_of_number_itself ] = pen.magic_byte( str )
							print( "["..the_concept_of_number_itself.."]="..pen.BYTE2ID[ the_concept_of_number_itself ])
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

pen.hew = pen.hew or {} -- hybrid gui library

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

pen.hew = pen.hew or {}

function pen.hew.transform( entity_id, x, y, s_x, s_y, r )
	local trans_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "InheritTransformComponent" )
	local _x, _y, _s_x, _s_y, _r = ComponentGetValue2( trans_comp, "Transform" )
	x, y, s_x, s_y, r = x or _x, y or _y, s_x or _s_x, s_y or _s_y, r or _r
	ComponentSetValue2( trans_comp, "Transform", x, y, s_x, s_y, r )
	return x, y, s_x, s_y, r
end

function pen.hew.builder( guid, init_func )
	guid = "hybrid_gui_"..( guid or "dft" )

	pen.c.hybrid_objects = pen.c.hybrid_objects or {}

	local gui_id = EntityGetWithName( guid ) or 0
	if( not( pen.vld( gui_id, true ) and EntityGetIsAlive( gui_id ))) then
		gui_id = EntityLoad( "mods/penman/extra/hybrid/controller.xml", 0, 0 )
		EntityAddChild( GameGetWorldStateEntity(), gui_id )
		EntitySetName( gui_id, guid )

		if( pen.vld( init_func )) then init_func( gui_id ) end
	end
	
	return gui_id
end

--check ui_is_parent
--pen.hew.button should have button.lua by default, setting can_click to true on image just makes it block inputs
function pen.hew.image( uid, pic_x, pic_y, pic_z, pic, data, init_func )
	if( not( pen.vld( pic ))) then return end

	uid = "pic_"..uid
	data = data or {}
	
	local gui_id = pen.hew.builder( data.guid )
	local x, y = EntityGetTransform( gui_id )
	
	pen.c.hybrid_objects.images = pen.c.hybrid_objects.images or {}

	local pic_id, is_new = pen.life_support(
		pen.c.hybrid_objects.images, uid, "mods/penman/extra/hybrid/image.xml" )
	if( not( is_new )) then return pic_id, false end
	EntityAddChild( pen.get_child( gui_id, "root" ), pic_id )
	EntitySetName( pic_id, uid )

	local pic_comp = 0
	local w, h, xml_offs = pen.get_pic_dims({ pic, data.anim }, data.update_xml )
	xml_offs = xml_offs or { 0, 0 }
	
	if( pen.vld( data.color )) then --thanks Copi
		pic_comp = EntityAddComponent2( pic_id, "SpriteParticleEmitterComponent", {
			sprite_file = pic,
			sprite_centered = data.is_centered,
			z_index = pic_z, delay = 0, lifetime = 0,
			render_back = not( data.emissive ) and z > 0,
			additive = data.additive or false,
			emissive = data.emissive or false,
			use_rotation_from_entity = true,
			camera_bound = true, camera_distance = 500,
			is_emitting = true, count_min = 1, count_max = 1,
			emission_interval_min_frames = 0,
			emission_interval_max_frames = 0,
		}) --set offset through randomize_position
		ComponentSetValue2( pic_comp, "color",
			data.color[1]/255, data.color[2]/255, data.color[3]/255, data.alpha or 1 )
		ComponentSetValue2( pic_comp, "scale", data.s_x or 1, data.s_y or 1 )
	else
		if( data.is_centered ) then data.off_x, data.off_y = w/2 - xml_offs[1], h/2 - xml_offs[1] end
		pic_comp = pen.magic_comp( pic_id, "SpriteComponent", function( comp_id, v, is_enabled )
			ComponentSetValue2( comp_id, "z_index", pic_z )
			
			ComponentSetValue2( comp_id, "image_file", pic )
			ComponentSetValue2( comp_id, "alpha", data.alpha or 1 )
			ComponentSetValue2( comp_id, "offset_x", data.off_x or 0 )
			ComponentSetValue2( comp_id, "offset_y", data.off_y or 0 )
			ComponentSetValue2( comp_id, "emissive", data.emissive or false )
			ComponentSetValue2( comp_id, "additive", data.additive or false )
			ComponentSetValue2( comp_id, "smooth_filtering", data.smooth or false )
			ComponentSetValue2( comp_id, "fog_of_war_hole", data.fog_hole or false )
			
			if( data.pic_s_x ~= nil or data.pic_s_y ~= nil ) then
				ComponentSetValue2( comp_id, "has_special_scale", true )
				ComponentSetValue2( comp_id, "special_scale_x", data.pic_s_x or 1 )
				ComponentSetValue2( comp_id, "special_scale_y", data.pic_s_y or 1 )
			end
	
			return true
		end)
		if( data.is_fogless ) then
			pen.clone_comp( pic_id, pic_comp, { fog_of_war_hole = true, smooth_filtering = true })
		end
	end
	
	if( data.guid == nil or data.in_gui ) then
		if( data.in_gui ) then
			pen.magic_storage( pic_id, "is_gui", "value_bool", true )
			pen.magic_storage( pic_id, "gui_x", "value_float", pic_x )
			pen.magic_storage( pic_id, "gui_y", "value_float", pic_y )
			pic_x, pic_y = pen.gui2world( pic_x, pic_y )
		end
		
		EntitySetTransform( pic_id, pic_x, pic_y, math.rad( data.r or 0 ), data.s_x or 1, data.s_y or 1 )
		local trans_comp = EntityGetFirstComponentIncludingDisabled( pic_id, "InheritTransformComponent" )
		EntityRemoveComponent( pic_id, trans_comp )
	else pen.hew.transform( pic_id, pic_x, pic_y, data.s_x, data.s_y, math.rad( data.r or 0 )) end
	
	if( data.can_click ) then
		local action = type( data.can_click ) == "string"
			and data.can_click or "mods/penman/extra/hybrid/button.lua"
		pen.magic_storage( pic_id, "is_triggered", "value_int", 0 )
		pen.magic_storage( pic_id, "is_touched", "value_bool", false )
		pen.magic_storage( pic_id, "on_action", "value_string", action )
	end
	if( pen.vld( data.ctrl_script )) then
		pen.magic_storage( pic_id, "on_ctrl", "value_string", data.ctrl_script )
	end
	
	if( pen.vld( init_func )) then init_func( pic_id, pic_comp ) end
	if( not( pen.vld( data.color ))) then EntityRefreshSprite( pic_id, pic_comp ) end

	return pic_id, true
end

function pen.hew.glow( uid, pic_x, pic_y, pic_z, s_x, s_y, color, alpha )
	return pen.hew.image( "glowing_"..uid, pic_x, pic_y, pic_z, "mods/penman/extra/pics/glow.png", {
		in_gui = true, is_centered = true, s_x = ( s_x or 1 )/256, s_y = ( s_y or 1 )/256, color = color,
		alpha = alpha, additive = true, smooth = true, emissive = true })
	-- do procedurally assembled rectangle is s_x or s_y is less than 0
end

-- function pen.hew.dragger( core_id, uid, sans_info, pic_info, pos_info, extra_action )
-- 	uid = "dragger_"..uid
-- 	sans_info = sans_info or {}
-- 	sans_info.center = sans_info.center or {}
-- 	sans_info.dims = sans_info.dims or {}
	
-- 	local dragger_id = new_hybrid_pic( core_id, uid, pic_info, pos_info, sans_info.tip or 1, extra_action )
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

-- function pen.hew.focus( core_id, uid, pic_info, pos_info )
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

-- function pen.hew.text( core_id, uid, text_info, pos_info, extra_action )
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

-- function pen.hew.scroller( core_id, uid, s_info, pos_info )	
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

--[SAFE] ^^^^^^^^^^^^
if( io == nil ) then return end
--[UNSAFE] vvvvvvvvvv

--bitser
--patcher
--pollnet