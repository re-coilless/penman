dofile_once( "mods/penman/_penman.lua" )

local gui_id = GetUpdatedEntityID()
local gui_x, gui_y = EntityGetTransform( gui_id )

local no_gui = pen.magic_storage( gui_id, "no_gui", "value_bool" )
local is_going = pen.magic_storage( gui_id, "is_going", "value_bool" )
local will_unload = pen.magic_storage( gui_id, "will_unload", "value_bool" )
local is_debugging = pen.magic_storage( gui_id, "is_debugging", "value_bool" )

local root_id = pen.get_child( gui_id, "root" )
local data_id = pen.get_child( gui_id, "data" ) --turn this into a table

pen.c.hybrid_data = pen.c.hybrid_data or {}

--generic hybrid gui must be processed on worldperupdate, so remove lua comp from it
--check for anim state var and tick it up until equals
--when is_going is set to false, tick it back down and delete when is done
--if anim state is less than 0, don't delete when is done
--do unloading when player gets too far

pen.child_play_full( root_id, function( child )
	local x, y, r, s_x, s_y = EntityGetTransform( child )

	local is_triggered, is_touched = 0, false
	local is_gui = pen.magic_storage( child, "is_gui", "value_bool" )
	local on_ctrl = pen.magic_storage( child, "on_ctrl", "value_string" )
	local on_action = pen.magic_storage( child, "on_action", "value_string" )

	if( pen.vld( on_ctrl )) then on_ctrl() end
	if( is_gui ) then
		x, y = pen.gui2world(
			pen.magic_storage( child, "gui_x", "value_float" ),
			pen.magic_storage( child, "gui_y", "value_float" ))
		EntitySetTransform( child, x, y, r, s_x, s_y )
	end

	local pic_comp = EntityGetFirstComponentIncludingDisabled( child, "SpriteComponent" )
	if( pen.vld( pic_comp, true )) then ComponentSetValue2( pic_comp, "visible", true ) else return end
	
	if( not( no_gui ) and on_action ~= nil ) then
		local off_x = ComponentGetValue2( pic_comp, "offset_x" )
		local off_y = ComponentGetValue2( pic_comp, "offset_y" )
		local z = ComponentGetValue2( pic_comp, "z_index" )

		if( is_gui ) then
			x = pen.magic_storage( child, "gui_x", "value_float" )
			y = pen.magic_storage( child, "gui_y", "value_float" )
			off_x, off_y = pen.world2gui( off_x, off_y, true, true )
			x, y = x - off_x, y - off_y
		else x, y = pen.world2gui( x - off_x, y - off_y ) end

		if( ComponentGetValue2( pic_comp, "has_special_scale" )) then
			s_x = ComponentGetValue2( pic_comp, "special_scale_x" )
			s_y = ComponentGetValue2( pic_comp, "special_scale_y" )
		end

		s_x, s_y = pen.world2gui( s_x, s_y, true, true )
		local clicked, r_clicked, is_hovered = pen.new.interface(
			x, y, s_x, s_y, z, { angle = r, is_debugging = is_debugging })
		if( pen.vld( on_action ) and ( clicked or r_clicked or is_hovered )) then on_action() end
	end
end)

--update data structure

pen.new.builder( true )

--[[
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
					if(( drift_x <= dim_a and drift_y <= dim_b ) or ( ctrl_data[entity_id][button[1] ] or false )) then
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
							ctrl_data[entity_id][button[1] ] = hovered and not( stopped )
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
]]