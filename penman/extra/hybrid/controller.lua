dofile_once( "mods/white_room/files/lib/generic_lib.lua" )
dofile_once( "mods/white_room/files/lib/gui_lib.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local is_going = ComponentGetValue2( get_storage( entity_id, "is_going" ), "value_bool" )
local storage_state = get_storage( entity_id, "anim_state" )
local anim_state = ComponentGetValue2( storage_state, "value_int" )

local extra_radius = ComponentGetValue2( get_storage( entity_id, "extra_radius" ), "value_int" )
local anim_frames = ComponentGetValue2( get_storage( entity_id, "anim_count" ), "value_int" )
local content_frames = 10

local uid = 0

local shell_id = get_hooman_child( entity_id, "shell" )
local content_id = get_hooman_child( entity_id, "contents" )

gui = gui or {}
ctrl_data = ctrl_data or {}
ctrl_data[entity_id] = ctrl_data[entity_id] or {}
ctrl_data[entity_id].tooltip_data = ctrl_data[entity_id].tooltip_data or {}

local function segment_toggler( entity_id, mode, d_alpha )
	local ignore_kids = ( string.find( EntityGetName( entity_id ), "childfree", 1, true ) ~= nil ) and is_going
	child_play( entity_id, function( parent, child )
		if( ignore_kids and not( EntityHasTag( child, "main_structure" ))) then
			return
		end
		
		local pics = EntityGetComponentIncludingDisabled( child, "SpriteComponent" ) or {}
		if( #pics > 0 ) then
			for k,pic in ipairs( pics ) do
				if( d_alpha ~= nil ) then
					ComponentSetValue2( pic, "alpha", d_alpha*ComponentGetValue2( pic, "alpha" ))
				end
				if( mode ~= nil ) then
					ComponentSetValue2( pic, "visible", mode )
				end
				EntityRefreshSprite( child, pic )
			end
		end
		
		segment_toggler( child, mode, d_alpha )
	end)
end

local gonna_update = false
if( is_going ) then
	if( anim_state < anim_frames + content_frames ) then
		gonna_update = true
		anim_state = anim_state + 1
	end
elseif( anim_state > 0 ) then
	gonna_update = true
	anim_state = anim_state - 1
end

local function do_ctrl( dude_id )
	child_play( dude_id, function( parent, child )
		local storage_ctrl = get_storage( child, "controller" )
		if( storage_ctrl ~= nil ) then
			shared_block = {
				main_id = entity_id,
				this_id = child,
				is_active = is_going,
				is_done = not( gonna_update ),
				state = anim_state + ( is_going and 0 or 1 ),
				final_state = anim_frames,
				gui_id = gui[entity_id],
				gui_uid = uid,
			}
			dofile( ComponentGetValue2( storage_ctrl, "value_string" ))
			uid = shared_block.gui_uid
			shared_block = nil
		end
		
		do_ctrl( child )
	end)
end
do_ctrl( entity_id )

if( gonna_update ) then
	ComponentSetValue2( storage_state, "value_int", anim_state )
	
	local alpha_drift = ( content_frames^( 1/content_frames ))^( is_going and 1 or -1 )
	if( anim_state > anim_frames ) then
		segment_toggler( content_id, nil, alpha_drift )
	else
		local function anim_handler( dude_id )
			child_play( dude_id, function( parent, child )
				local storage_anim = get_storage( child, "action_anim" )
				if( storage_anim ~= nil ) then
					shared_block = {
						main_id = entity_id,
						this_id = child,
						is_active = is_going,
						is_done = not( gonna_update ),
						state = anim_state + ( is_going and 0 or 1 ),
						final_state = anim_frames,
					}
					dofile( ComponentGetValue2( storage_anim, "value_string" ))
					shared_block = nil
				end
				
				anim_handler( child )
			end)
		end
		anim_handler( shell_id )
	end
	
	if( anim_state == 0 and not( is_going )) then
		if( not( EntityHasTag( entity_id, "immortal" ))) then
			ctrl_data[entity_id] = nil
			EntityKill( entity_id )
			return
		end
	elseif( anim_state == 1 and is_going ) then
		segment_toggler( shell_id, true )
		segment_toggler( content_id, false )
	end
	
	if( anim_state == anim_frames - 1 and not( is_going )) then
		segment_toggler( content_id, false )
	elseif( anim_state > anim_frames and is_going ) then
		local storage_alphaed = get_storage( content_id, "is_alphaed" )
		local alphaless = not( ComponentGetValue2( storage_alphaed, "value_bool" ))
		segment_toggler( content_id, true, alphaless and 0.1 or nil )
		if( alphaless ) then
			ComponentSetValue2( storage_alphaed, "value_bool", true )
		end
	end
end

local fuck_gui = true
if( anim_state >= anim_frames and not( EntityHasTag( entity_id, "no_gui" ))) then
	local hoomans = EntityGetInRadiusWithTag( x, y, MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" ) + extra_radius, "player_unit" ) or {}
	if( #hoomans > 0 ) then --and not( GameIsInventoryOpen())) then
		local buttons = {}
		local function collect_buttons( dude_id )
			child_play( dude_id, function( parent, child )
				if( get_storage( child, "trigger_state" ) ~= nil ) then
					local _, _, _, s_x, s_y = EntityGetTransform( child )
					local pic_comp = EntityGetFirstComponentIncludingDisabled( child, "SpriteComponent" )
					if( ComponentGetValue2( pic_comp, "visible" ) and s_x ~= 0 and s_y ~= 0 ) then
						local storage_z = get_storage( child, "z_override" )
						table.insert( buttons, { child, pic_comp, storage_z == nil and ComponentGetValue2( pic_comp, "z_index" ) or ComponentGetValue2( storage_z, "value_float" )})
					end
				end
				
				collect_buttons( child )
			end)
		end
		collect_buttons( entity_id )
		
		if( #buttons > 0 ) then
			if( gui[entity_id] == nil ) then
				gui[entity_id] = GuiCreate()
			end
			local this_gui = gui[entity_id]
			GuiStartFrame( this_gui )
			
			local mouse_x, mouse_y = DEBUG_GetMouseWorld()
			local true_v_x, true_v_y = ComponentGetValue2( get_storage( entity_id, "true_v_x" ), "value_float" ), ComponentGetValue2( get_storage( entity_id, "true_v_y" ), "value_float" )
			
			local pic_z = 0
			
			table.sort( buttons, function( a, b )
				return a[3] > b[3]
			end)
			for i,button in ipairs( buttons ) do
				fuck_gui = false
				
				local is_debugged = EntityHasTag( entity_id, "debugging" ) or EntityHasTag( button[1], "debugging" )
				local clicked, r_clicked, hovered = false, false, false
				
				--add option for buttons to be triggered by the manual screen area of the click check (same as with dragger) with rotation support
				local width, height = get_pic_dim( ComponentGetValue2( button[2], "image_file" ))
				local real_x, real_y, rotation, s_x, s_y = EntityGetTransform( button[1])
				local off_x, off_y = ComponentGetValue2( button[2], "offset_x" ), ComponentGetValue2( button[2], "offset_y" )
				local pic_x, pic_y = real_x + true_v_x, real_y + true_v_y
				
				if( ComponentGetValue2( button[2], "has_special_scale" )) then
					s_x, s_y = ComponentGetValue2( button[2], "special_scale_x" ), ComponentGetValue2( button[2], "special_scale_y" )
				end
				width, height = width*s_x, height*s_y
				off_x, off_y = off_x*s_x - ( s_x < 0 and width or 0 ), off_y*s_y - ( s_y < 0 and height or 0 )
				
				width, height = world2gui( width, height, true )
				pic_x, pic_y = world2gui( pic_x - off_x + 1, pic_y - off_y )
				pic_z = -9999 - button[3]
				
				local storage_drgr = get_storage( button[1], "drgr_center_x" )
				if( storage_drgr ~= nil ) then
					real_x, real_y = real_x + s_x*ComponentGetValue2( storage_drgr, "value_float" ), real_y + s_y*ComponentGetValue2( get_storage( button[1], "drgr_center_y" ), "value_float" )
					local drift_x, drift_y = math.abs( real_x - mouse_x ), math.abs( real_y - mouse_y )
					local dim_a, dim_b = ComponentGetValue2( get_storage( button[1], "drgr_dim_a" ), "value_float" )*math.abs( s_x ), ComponentGetValue2( get_storage( button[1], "drgr_dim_b" ), "value_float" )*math.abs( s_y )
					
					local new_x, new_y, stopped, is_drgg = 0, 0, true, ( ctrl_data[entity_id].is_dragging or button[1] ) == button[1]
					if(( drift_x <= dim_a and drift_y <= dim_b ) or ( ctrl_data[entity_id][button[1]] or false )) then
						if( is_drgg ) then
							new_x, new_y, stopped, clicked, r_clicked, hovered = new_dragger( this_gui, 1023, new_x, new_y, pic_z, "mods/white_room/files/pics/debug_null_fullhd.png" )
							
							storage_drgr = get_storage( button[1], "drgr_last_x" )
							if( storage_drgr ~= nil ) then
								local last_x, last_y = ComponentGetValue2( storage_drgr, "value_float" ), ComponentGetValue2( get_storage( button[1], "drgr_last_y" ), "value_float" )
								ComponentSetValue2( get_storage( button[1], "drgr_last_x" ), "value_float", new_x )
								ComponentSetValue2( get_storage( button[1], "drgr_last_y" ), "value_float", new_y )
								if( not( stopped )) then
									new_x, new_y = new_x - last_x, new_y - last_y
								end
							end
							ctrl_data[entity_id][button[1]] = hovered and not( stopped )
						end
					elseif( is_drgg ) then
						ctrl_data[entity_id].is_dragging = nil
					end
					ComponentSetValue2( get_storage( button[1], "drgr_drift_x" ), "value_float", new_x )
					ComponentSetValue2( get_storage( button[1], "drgr_drift_y" ), "value_float", new_y )
					ComponentSetValue2( get_storage( button[1], "drgr_is_active" ), "value_bool", not( stopped ))
					if( not( stopped )) then
						ctrl_data[entity_id].is_dragging = button[1]
					end
				else
					uid, clicked, r_clicked, hovered = new_hybrid_interface( this_gui, uid, pic_x, pic_y, pic_z, width, height, is_debugged )
					
					if( not( EntityHasTag( button[1], "fuck_hover" ))) then
						local hover_id = ctrl_data[entity_id].is_hovering or 0
						if( hover_id == 0 or hover_id == button[1] ) then
							ctrl_data[entity_id].is_hovering = hovered and button[1] or 0
						else
							hovered = false
						end
					end
				end
				
				shared_block = {
					main_id = entity_id,
					this_id = button[1],
					gui_id = this_gui,
					gui_uid = uid,
					is_lmb = l_clicked,
					is_rmb = r_clicked,
					is_hov = hovered,
				}
				
				if( clicked or r_clicked or hovered ) then
					if( clicked or r_clicked ) then
						local storage_action = get_storage( button[1], "action" )
						if( storage_action ~= nil ) then
							dofile( ComponentGetValue2( storage_action, "value_string" ))
						end
					end
					
					if( hovered ) then
						local storage_action = get_storage( button[1], "action_hover" )
						if( storage_action ~= nil ) then
							local do_tooltip = false
							if(( ctrl_data[entity_id].tooltip_data.id or 0 ) ~= button[1]) then
								ctrl_data[entity_id].tooltip_data = {}
								ctrl_data[entity_id].tooltip_data.id = button[1]
							elseif(( ctrl_data[entity_id].tooltip_data.delay or 0 ) < ComponentGetValue2( get_storage( button[1], "hover_delay" ), "value_int" )) then
								ctrl_data[entity_id].tooltip_data.delay = ( ctrl_data[entity_id].tooltip_data.delay or 0 ) + 1
							else
								do_tooltip = true
								if(( ctrl_data[entity_id].tooltip_data.anim or 0 ) < 10 ) then
									ctrl_data[entity_id].tooltip_data.anim = ( ctrl_data[entity_id].tooltip_data.anim or 0 ) + 1
								end
							end
							
							local value = ComponentGetValue2( storage_action, "value_string" )
							if( string.sub( value, -4 ) == ".lua" ) then
								shared_block.tooltipped = do_tooltip
								uid = dofile( value )
							elseif( do_tooltip ) then
								uid = new_tooltip( this_gui, uid, value, true, ctrl_data[entity_id].tooltip_data.anim )
							end
						end
					end
				elseif(( ctrl_data[entity_id].tooltip_data.id or 0 ) == button[1]) then
					ctrl_data[entity_id].tooltip_data = {}
				end
				
				local storage_macro = get_storage( button[1], "action_macro" )
				if( storage_macro ~= nil ) then
					dofile( ComponentGetValue2( storage_macro, "value_string" ))
				end
				shared_block = nil
				
				local trigger_state = clicked and 1 or ( r_clicked and -1 or 0 )
				local storage_hook = get_storage( button[1], "trigger_state" )
				if( ComponentGetValue2( storage_hook, "value_int" ) ~= trigger_state ) then
					ComponentSetValue2( storage_hook, "value_int", trigger_state )
				end
				storage_hook = get_storage( button[1], "is_hovered" )
				if( ComponentGetValue2( storage_hook, "value_bool" ) ~= hovered ) then
					ComponentSetValue2( storage_hook, "value_bool", hovered )
				end
			end
		end
	end
end
if( fuck_gui ) then
	gui[entity_id] = gui_killer( gui[entity_id])
end