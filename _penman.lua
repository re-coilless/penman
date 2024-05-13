pen = pen or {}

--mrshll
--19a
--Heres Ferrei
--Noita40K

--make proper edit comp function
--add sfxes, default translations
--try putting some of the stuff inside internal lua global tables
--make sure all the funcs reference the right stuff

--[MATH]
function pen.b2n( a )
	return a and 1 or 0
end

function pen.get_sign( a )
	if( a < 0 ) then
		return -1
	else
		return 1
	end
end

function pen.float_compare( a, b )
	local epsln = 0.0001
	return math.abs( a - b ) < epsln
end

function pen.limiter( value, limit, max_mode )
	max_mode = max_mode or false
	limit = math.abs( limit )
	
	if(( max_mode and math.abs( value ) < limit ) or ( not( max_mode ) and math.abs( value ) > limit )) then
		return pen.get_sign( value )*limit
	end
	
	return value
end

function pen.get_angular_delta( a, b, get_max )
	get_max = get_max or false

	local pi, pi4 = math.rad( 90 ), math.rad( 360 )
	local d360 = a - b
	local d180 = ( a + pi )%pi4 - ( b + pi )%pi4
	if( get_max ) then
		return ( math.abs( d360 ) > math.abs( d180 ) and d360 or d180 )
	else
		return ( math.abs( d360 ) < math.abs( d180 ) and d360 or d180 )
	end
end

function pen.angle_reset( angle )
	return math.atan2( math.sin( angle ), math.cos( angle ))
end

function pen.rotate_offset( x, y, angle )
	return x*math.cos( angle ) - y*math.sin( angle ), x*math.sin( angle ) + y*math.cos( angle )
end

function pen.world2gui( x, y, not_pos ) --thanks to ImmortalDamned for the fix
	not_pos = not_pos or false
	
	local gui = GuiCreate()
	GuiStartFrame( gui )
	local w, h = GuiGetScreenDimensions( gui )
	GuiDestroy( gui )
	
	local view_x = ( MagicNumbersGetValue( "VIRTUAL_RESOLUTION_X" ) + MagicNumbersGetValue( "VIRTUAL_RESOLUTION_OFFSET_X" ))
	local view_y = ( MagicNumbersGetValue( "VIRTUAL_RESOLUTION_Y" ) + MagicNumbersGetValue( "VIRTUAL_RESOLUTION_OFFSET_Y" ))
	local massive_balls_x, massive_balls_y = w/view_x, h/view_y

	local _,_, cancer_x, cancer_y = GameGetCameraBounds()
	if( cancer_x/cancer_y < 1.7 ) then
		massive_balls_x, massive_balls_y = massive_balls_x*massive_balls_y, massive_balls_x*massive_balls_y
	end

	if( not( not_pos )) then
		local cam_x, cam_y = GameGetCameraPos()
		x, y = ( x - ( cam_x - view_x/2 )), ( y - ( cam_y - view_y/2 ))
	end
	
	return massive_balls_x*x, massive_balls_y*y, {massive_balls_x,massive_balls_y}
end

function pen.get_mouse_pos()
	local m_x, m_y = DEBUG_GetMouseWorld()
	return pen.world2gui( m_x, m_y )
end

--[TECHNICAL]
function pen.catch( f, input, fallback )
	local is_good,stuff,oa,ob,oc,od,oe,of,og,oh = pcall(f, unpack( input or {}))
	if( not( is_good )) then
		print( stuff )
		return unpack( fallback or {false})
	else
		return stuff,oa,ob,oc,od,oe,of,og,oh
	end
end

function pen.get_hybrid_function( func, input )
	if( func == nil ) then return end
	if( type( func ) == "function" ) then
		return pen.catch( func, input )
	else
		return func
	end
end

function pen.magic_copy( orig, copies )
    copies = copies or {}
    local orig_type = type( orig )
    local copy = {}
    if( orig_type == "table" ) then
        if( copies[orig] ) then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[ pen.magic_copy( orig_key, copies )] = pen.magic_copy( orig_value, copies )
            end
            setmetatable( copy, pen.magic_copy( getmetatable( orig ), copies ))
        end
    else
        copy = orig
    end
    return copy
end

function pen.magic_sorter( tbl, func )
    local out_tbl = {}
    for n in pairs( tbl ) do
        table.insert( out_tbl, n )
    end
    table.sort( out_tbl, func )
	
    local i = 0
    local iter = function ()
        i = i + 1
        if( out_tbl[i] == nil ) then
            return nil
        else
            return out_tbl[i], tbl[out_tbl[i]]
        end
    end
    return iter
end

function pen.generic_random( a, b, macro_drift, bidirectional )
	bidirectional = bidirectional or false
	
	if( macro_drift == nil ) then
		macro_drift = GetUpdatedEntityID() or 0
		if( macro_drift > 0 ) then
			local drft_a, drft_b = EntityGetTransform( macro_drift )
			macro_drift = macro_drift + tonumber( macro_drift ) + ( drft_a*1000 + drft_b )
		else
			macro_drift = 1
		end
	elseif( type( macro_drift ) == "table" ) then
		macro_drift = macro_drift[1]*1000 + macro_drift[2]
	end
	macro_drift = math.floor( macro_drift + 0.5 )
	
	local tm = { GameGetDateAndTimeUTC() }
	SetRandomSeed( math.random( GameGetFrameNum(), macro_drift ), (((( tm[2]*30 + tm[3] )*24 + tm[4] )*60 + tm[5] )*60 + tm[6] )%macro_drift )
	Random( 1, 5 ); Random( 1, 5 ); Random( 1, 5 )
	return bidirectional and ( Random( a, b*2 ) - b ) or Random( a, b )
end

function pen.gui_killer( gui )
	if( gui ~= nil ) then
		GuiDestroy( gui )
	end
end

--[UTILS]
function pen.uint2color( color )
	return { bit.band( color, 0xff ), bit.band( bit.rshift( color, 8 ), 0xff ), bit.band( bit.rshift( color, 16 ), 0xff )}
end

function pen.debug_dot( x, y, frames )
	GameCreateSpriteForXFrames( "data/ui_gfx/debug_marker.png", x, y, true, 0, 0, frames or 1, true )
end

function pen.table_init( amount, value )
	local tbl = {}
	local temp = value
	for i = 1,amount do
		if( type( value ) == "table" ) then
			temp = {}
		end
		tbl[i] = temp
	end
	
	return tbl
end

function pen.add_table( a, b )
	if( #b > 0 ) then
		table.sort( b )
		if( #a > 0 ) then
			for m,new in ipairs( b ) do 
				if( binsearch( a, new ) == nil ) then
					table.insert( a, new )
				end
			end
			
			table.sort( a )
		else
			a = b
		end
	end
	
	return a
end

function pen.get_table_count( tbl, just_checking )
	tbl = tbl or 0
	if( type( tbl ) ~= "table" ) then
		return 0
	end
	
	local table_count = 0
	for i,element in pairs( tbl ) do
		table_count = table_count + 1
		if( just_checking ) then
			break
		end
	end
	return table_count
end

function pen.get_most_often( tbl )
	local count = {}
	for n,v in pairs( tbl ) do
		count[v] = ( count[v] or 0 ) + 1
	end
	local best = {0,0}
	for n,v in pairs( count ) do
		if( best[2] < v ) then
			best = {n,v}
		end
	end
	return unpack( best )
end

function pen.from_tbl_with_id( tbl, id, subtract, custom_key, default )
	local stuff = default or 0
	local tbl_id = nil
	
	local key = custom_key or "id"
	if( type( id ) == "table" ) then
		stuff = {}
		if( subtract ) then
			if( #id < #tbl ) then
				if( #id > 0 ) then
					for i = #tbl,1,-1 do
						for e,dud in ipairs( id ) do
							if( dud == ( tbl[i][key] or tbl[i][1] or tbl[i])) then
								table.remove( tbl, i )
								table.remove( id, e )
								break
							end
						end
					end
				end
				return tbl
			end
			return {}
		else
			for i,dud in ipairs( tbl ) do
				for e,bub in ipairs( id ) do
					if(( dud[key] or dud[1] or dud ) == bub ) then
						table.insert( stuff, dud )
						break
					end
				end
			end
		end
	else
		local gonna_stuff = default == nil
		for i,dud in ipairs( tbl ) do
			if( gonna_stuff and type( dud ) == "table" ) then
				stuff = {}
				gonna_stuff = false
			end
			if(( dud[key] or dud[1] or dud ) == id ) then
				stuff = dud
				tbl_id = i
				break
			end
		end
	end
	
	return stuff, tbl_id
end

function pen.closest_getter( x, y, stuff, check_sight, limits, extra_check )
	check_sight = check_sight or false
	limits = limits or { 0, 0, }
	if( #( stuff or {}) == 0 ) then
		return 0
	end
	
	local actual_thing = 0
	local min_dist = -1
	for i,raw_thing in ipairs( stuff ) do
		local thing = type( raw_thing ) == "table" and raw_thing[1] or raw_thing

		local t_x, t_y = EntityGetTransform( thing )
		if( not( check_sight ) or not( RaytracePlatforms( x, y, t_x, t_y ))) then
			local d_x, d_y = math.abs( t_x - x ), math.abs( t_y - y )
			if(( d_x < limits[1] or limits[1] == 0 ) and ( d_y < limits[2] or limits[2] == 0 )) then
				local dist = math.sqrt( d_x^2 + d_y^2 )
				if( min_dist == -1 or dist < min_dist ) then
					if( extra_check == nil or extra_check( raw_thing )) then
						min_dist = dist
						actual_thing = raw_thing
					end
				end
			end
		end
	end
	
	return actual_thing
end

function pen.get_child_num( inv_id, item_id )
	local children = EntityGetAllChildren( inv_id ) or {}
	if( #children > 0 ) then
		for i,child in ipairs( children ) do
			if( child == item_id ) then
				return i-1
			end
		end
	end

	return 0
end

function pen.child_play( entity_id, action, sorter )
	local children = EntityGetAllChildren( entity_id ) or {}
	if( #children > 0 ) then
		if( sorter ~= nil ) then table.sort( children, sorter ) end
		for i,child in ipairs( children ) do
			local value = action( entity_id, child, i ) or false
			if( value ) then
				return value
			end
		end
	end
end

function pen.child_play_full( dude_id, func, params )
	local ignore = func( dude_id, params ) or false
	return pen.child_play( dude_id, function( parent, child )
		if( ignore ) then
			return func( child, params )
		else
			return pen.child_play_full( child, func, params )
		end
	end)
end

function pen.t2w( str )
	local t = {}
	
	for word in string.gmatch( str, "([^%s]+)" ) do
		table.insert( t, word )
	end
	
	return t
end

function pen.get_translated_line( text )
	local out = ""
	local markers = pen.t2w( pen.get_hybrid_function( text ))
	for i,mark in ipairs( markers ) do
		out = out..( out == "" and out or " " )..GameTextGetTranslatedOrNot( mark )
	end
	return out
end

function pen.clean_append( to_file, from_file )
	local marker = "%-%-<{> MAGICAL APPEND MARKER <}>%-%-"
	local line_wrecker = "\n\n\n"
	
	local a = ModTextFileGetContent( to_file )
	local b = ModTextFileGetContent( from_file )
	ModTextFileSetContent( to_file, string.gsub( a, marker, b..line_wrecker..marker ))
end

function pen.set_translations( path )
	local file, main = ModTextFileGetContent( path ), "data/translations/common.csv"
	ModTextFileSetContent( main, ModTextFileGetContent( main )..string.gsub( file, "^[^\n]*\n", "" ))
end

function pen.liner( text, length, height, length_k, clean_mode, forced_reverse )
	local formated = {}
	if( text ~= nil and text ~= "" ) then
		local length_counter = 0
		if( height ~= nil ) then
			length_k = length_k or 6
			length = math.floor( length/length_k + 0.5 )
			height = math.floor( height/9 )
			local height_counter = 1
			
			local full_text = "@"..text.."@"
			for line in string.gmatch( full_text, "([^@]+)" ) do
				local rest = ""
				local buffer = ""
				local dont_touch = false
				
				length_counter = 0
				text = ""
				
				local words = pen.t2w( line )
				for i,word in ipairs( words ) do
					buffer = word
					local w_length = string.len( buffer ) + 1
					length_counter = length_counter + w_length
					dont_touch = false
					
					if( length_counter > length ) then
						if( w_length >= length ) then
							rest = string.sub( buffer, length - ( length_counter - w_length - 1 ), w_length )
							text = text..buffer.." "
						else
							length_counter = w_length
						end
						table.insert( formated, tostring( string.gsub( string.sub( text, 1, length ), "@ ", "" )))
						height_counter = height_counter + 1
						text = ""
						while( rest ~= "" ) do
							w_length = string.len( rest ) + 1
							length_counter = w_length
							buffer = rest
							if( length_counter > length ) then
								rest = string.sub( rest, length + 1, w_length )
								table.insert( formated, tostring( string.sub( buffer, 1, length )))
								dont_touch = true
								height_counter = height_counter + 1
							else
								rest = ""
								length_counter = w_length
							end
							
							if( height_counter > height ) then
								break
							end
						end
					end
					
					if( height_counter > height ) then
						break
					end
					
					text = text..buffer.." "
				end
				
				if( not( dont_touch )) then
					table.insert( formated, tostring( string.sub( text, 1, length )))
				end
			end
		else
			local gui = GuiCreate()
			GuiStartFrame( gui )
			
			local starter = math.floor( math.abs( length )/7 + 0.5 )
			local total_length = string.len( text )
			if( starter < total_length ) then
				if(( length > 0 ) and forced_reverse == nil ) then
					length = math.abs( length )
					formated = string.sub( text, 1, starter )
					for i = starter + 1,total_length do
						formated = formated..string.sub( text, i, i )
						length_counter = GuiGetTextDimensions( gui, formated, 1, 2 )
						if( length_counter > length ) then
							formated = string.sub( formated, 1, string.len( formated ) - 1 )
							break
						end
					end
				else
					length = math.abs( length )
					starter = total_length - starter
					formated = string.sub( text, starter, total_length )
					while starter > 0 do
						starter = starter - 1
						formated = string.sub( text, starter, starter )..formated
						length_counter = GuiGetTextDimensions( gui, formated, 1, 2 )
						if( length_counter > length ) then
							formated = string.sub( formated, 2, string.len( formated ))
							break
						end
					end
				end
			else
				formated = text
			end
			
			GuiDestroy( gui )
		end
	else
		if( clean_mode == nil ) then
			table.insert( formated, "[NIL]" )
		else
			formated = ""
		end
	end
	
	return formated
end

--[ECS]
function pen.get_storage( hooman, name )
	local comps = EntityGetComponentIncludingDisabled( hooman, "VariableStorageComponent" ) or {}
	if( #comps > 0 ) then
		for i,comp in ipairs( comps ) do
			if( ComponentGetValue2( comp, "name" ) == name ) then
				return comp
			end
		end
	end
	
	return nil
end

function pen.get_hooman_child( hooman, tag, ignore_id )
	if( hooman == nil ) then
		return -1
	end
	
	local children = EntityGetAllChildren( hooman ) or {}
	if( #children > 0 ) then
		for i,child in ipairs( children ) do
			if( child ~= ignore_id and ( EntityGetName( child ) == tag or EntityHasTag( child, tag ))) then
				return child
			end
		end
	end
	
	return nil
end

function pen.check_bounds( dot, pos, box )
	if( box == nil ) then
		return false
	end
	
	if( type( box ) ~= "table" ) then
		local off_x, off_y = ComponentGetValue2( box, "offset" )
		pos = { pos[1] + off_x, pos[2] + off_y }
		box = {
			ComponentGetValue2( box, "aabb_min_x" ),
			ComponentGetValue2( box, "aabb_max_x" ),
			ComponentGetValue2( box, "aabb_min_y" ),
			ComponentGetValue2( box, "aabb_max_y" ),
		}
	end
	return dot[1]>=(pos[1]+box[1]) and dot[2]>=(pos[2]+box[3]) and dot[1]<=(pos[1]+box[2]) and dot[2]<=(pos[2]+box[4])
end

function pen.get_creature_centre( hooman, x, y )
	local char_comp = EntityGetFirstComponentIncludingDisabled( hooman, "CharacterDataComponent" )
	if( char_comp ~= nil ) then
		y = y + ComponentGetValue2( char_comp, "buoyancy_check_offset_y" )
	end
	return x, y
end

function pen.get_creature_head( entity_id, x, y )
	local ai_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "AnimalAIComponent" )
	if( ai_comp ~= nil ) then
		y = y + ComponentGetValue2( ai_comp, "eye_offset_y" )
	else
		local crouch_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "HotspotComponent", "crouch_sensor" )
		if( crouch_comp ~= nil ) then
			local off_x, off_y = ComponentGetValue2( crouch_comp, "offset" )
			y = y + off_y + 3
		end
	end
	return x, y
end

function pen.lua_callback( entity_id, func_names, input )
	local got_some = false
	local comps = EntityGetComponentIncludingDisabled( entity_id, "LuaComponent" ) or {}
	if( #comps > 0 ) then
		local real_GetUpdatedEntityID = GetUpdatedEntityID
		local real_GetUpdatedComponentID = GetUpdatedComponentID
		GetUpdatedEntityID = function() return entity_id end

		local frame_num = GameGetFrameNum()
		for i,comp in ipairs( comps ) do
			local path = ComponentGetValue2( comp, func_names[1]) or ""
			if( path ~= "" ) then
				local max_count = ComponentGetValue2( comp, "execute_times" )
				local count = ComponentGetValue2( comp, "mTimesExecuted" )
				if( max_count < 1 or count < max_count ) then
					got_some = true
					
					GetUpdatedComponentID = function() return comp end
					dofile( path )
					_G[ func_names[2]]( unpack( input ))

					ComponentSetValue2( comp, "mLastExecutionFrame", frame_num )
					ComponentSetValue2( comp, "mTimesExecuted", count + 1 )
					if( ComponentGetValue2( comp, "remove_after_executed" )) then
						EntityRemoveComponent( entity_id, comp )
					end
				end
			end
		end
		
		GetUpdatedEntityID = real_GetUpdatedEntityID
		GetUpdatedComponentID = real_GetUpdatedComponentID
	end
	return got_some
end

function pen.get_phys_mass( entity_id )
	local mass = 0
	
	local shape_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "PhysicsImageShapeComponent" )
	if( shape_comp ~= nil ) then
		local x, y = EntityGetTransform( entity_id )
		local drift_x, drift_y = ComponentGetValue2( shape_comp, "offset_x" ), ComponentGetValue2( shape_comp, "offset_y" )
		x, y = x - drift_x, y - drift_y
		drift_x, drift_y = 1.5*drift_x, 1.5*drift_y
		
		local function calculate_force_for_body( entity, body_mass, body_x, body_y, body_vel_x, body_vel_y, body_vel_angular )
			if( math.abs( x - body_x ) < 0.001 and math.abs( y - body_y ) < 0.001 ) then
				mass = body_mass
			end
			return body_x, body_y, 0, 0, 0
		end
		PhysicsApplyForceOnArea( calculate_force_for_body, nil, x - drift_x, y - drift_y, x + drift_x, y + drift_y )
	end
	
	return mass
end

function pen.get_matters( matters )
	local mttrs = {}
	local got_some = 0
	if( #matters > 0 ) then
		for i,mttr in ipairs( matters ) do
			if( mttr > 0 ) then
				table.insert( mttrs, {i-1,mttr})
				got_some = got_some + mttr
			end
		end 
		table.sort( mttrs, function( a, b )
			return a[2] > b[2]
		end)
	end
	return got_some, mttrs
end

function pen.active_item_reset( hooman )
	local inv_comp = EntityGetFirstComponentIncludingDisabled( hooman or 0, "Inventory2Component" )
	if( inv_comp ~= nil ) then
		ComponentSetValue2( inv_comp, "mActiveItem", 0 )
		ComponentSetValue2( inv_comp, "mActualActiveItem", 0 )
		ComponentSetValue2( inv_comp, "mInitialized", false )
	end
	return inv_comp
end

function pen.get_active_item( hooman )
	local inv_comp = EntityGetFirstComponentIncludingDisabled( hooman, "Inventory2Component" )
	if( inv_comp ~= nil ) then
		return tonumber( ComponentGetValue2( inv_comp, "mActiveItem" ) or 0 )
	end
	
	return 0
end

function pen.get_item_owner( item_id, figure_it_out )
	if( item_id ~= nil ) then
		local root_man = EntityGetRootEntity( item_id )
		local parent = item_id
		while( parent ~= root_man ) do
			parent = EntityGetParent( parent )

			local item_check = pen.get_active_item( parent )
			if( figure_it_out or false ) then
				item_check = item_check > 0
			else
				item_check = item_check == item_id
			end

			if( item_check ) then
				return parent
			end
		end
	end
	
	return 0
end

function pen.is_wand_useless( wand_id )
	local children = EntityGetAllChildren( wand_id ) or {}
	if( #children > 0 ) then
		for i,child in ipairs( children ) do
			local itm_comp = EntityGetFirstComponentIncludingDisabled( child, "ItemComponent" )
			if( itm_comp ~= nil ) then
				if( ComponentGetValue2( itm_comp, "uses_remaining" ) ~= 0 ) then
					return false
				end
			end
		end
	end
	return true
end

function pen.get_tinker_state( hooman, x, y )
	for n = 1,2 do
		local v = GameGetGameEffectCount( hooman, n == 1 and "EDIT_WANDS_EVERYWHERE" or "NO_WAND_EDITING" ) > 0
		v = v and n or pen.child_play( hooman, function( parent, child )
			if( GameGetGameEffectCount( child, n == 1 and "EDIT_WANDS_EVERYWHERE" or "NO_WAND_EDITING" ) > 0 ) then
				return n
			end
		end)
		if( v ) then return v == 1 end
	end
	
	local workshops = EntityGetWithTag( "workshop" ) or {}
	if( #workshops > 0 ) then
		for i,workshop in ipairs( workshops ) do
			local w_x, w_y = EntityGetTransform( workshop )
			local box_comp = EntityGetFirstComponent( workshop, "HitboxComponent" )
			if( box_comp ~= nil and pen.check_bounds({x,y}, {w_x,w_y}, box_comp )) then
				return true
			end
		end
	end

	return false
end

--[FRONTEND]
function pen.colourer( gui, c_type )
	if( #c_type == 0 ) then return end
	local color = { r = 0, g = 0, b = 0 }
	if( type( c_type ) == "table" ) then
		color.r = c_type[1] or 255
		color.g = c_type[2] or 255
		color.b = c_type[3] or 255
	end
	GuiColorSetForNextWidget( gui, color.r/255, color.g/255, color.b/255, 1 )
end

function pen.new_text( gui, pic_x, pic_y, pic_z, text, colours )
	local out_str = {}
	if( text ~= nil ) then
		if( type( text ) == "table" ) then
			out_str = text
		else
			table.insert( out_str, text )
		end
	else
		table.insert( out_str, "[NIL]" )
	end
	
	for i,line in ipairs( out_str ) do
		pen.colourer( gui, colours or {})
		GuiZSetForNextWidget( gui, pic_z )
		GuiText( gui, pic_x, pic_y, line )
		pic_y = pic_y + 9
	end
end

function pen.new_image( gui, uid, pic_x, pic_y, pic_z, pic, s_x, s_y, alpha, interactive, angle )
	if( s_x == nil ) then
		s_x = 1
	end
	if( s_y == nil ) then
		s_y = 1
	end
	if( alpha == nil ) then
		alpha = 1
	end
	if( interactive == nil ) then
		interactive = false
	end
	
	if( not( interactive )) then
		GuiOptionsAddForNextWidget( gui, 2 ) --NonInteractive
	end
	GuiZSetForNextWidget( gui, pic_z )
	uid = uid + 1
	GuiIdPush( gui, uid )
	GuiImage( gui, uid, pic_x, pic_y, pic, alpha, s_x, s_y, angle )
	return uid
end

function pen.new_button( gui, uid, pic_x, pic_y, pic_z, pic )
	GuiZSetForNextWidget( gui, pic_z )
	uid = uid + 1
	GuiIdPush( gui, uid )
	GuiOptionsAddForNextWidget( gui, 6 ) --NoPositionTween
	GuiOptionsAddForNextWidget( gui, 4 ) --ClickCancelsDoubleClick
	GuiOptionsAddForNextWidget( gui, 21 ) --DrawNoHoverAnimation
	GuiOptionsAddForNextWidget( gui, 47 ) --NoSound
	local clicked, r_clicked = GuiImageButton( gui, uid, pic_x, pic_y, "", pic )
	return uid, clicked, r_clicked
end

function pen.new_anim( gui, uid, auid, pic_x, pic_y, pic_z, path, amount, delay, s_x, s_y, alpha, interactive )
	anims_state = anims_state or {}
	anims_state[auid] = anims_state[auid] or { 1, 0 }
	
	pen.new_image( gui, uid, pic_x, pic_y, pic_z, path..anims_state[auid][1]..".png", s_x, s_y, alpha, interactive )
	
	anims_state[auid][2] = anims_state[auid][2] + 1
	if( anims_state[auid][2] > delay ) then
		anims_state[auid][2] = 0
		anims_state[auid][1] = anims_state[auid][1] + 1
		if( anims_state[auid][1] > amount ) then
			anims_state[auid][1] = 1
		end
	end
	
	return uid
end

function pen.new_cutout( gui, uid, pic_x, pic_y, size_x, size_y, func, v )
	uid = uid + 1
	GuiIdPush( gui, uid )

	local margin = 0
	GuiAnimateBegin( gui )
	GuiAnimateAlphaFadeIn( gui, uid, 0, 0, true )
	GuiBeginAutoBox( gui )
	GuiBeginScrollContainer( gui, uid, pic_x - margin, pic_y - margin, size_x, size_y, false, margin, margin )
	GuiEndAutoBoxNinePiece( gui )
	GuiAnimateEnd( gui )
	uid = func( gui, uid, v )
	GuiEndScrollContainer( gui )

	return uid
end