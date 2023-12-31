PENMAN_DIV_1 = "|"
PENMAN_DIV_2 = "@"

PENMAN_PTN_1 = "([^"..PENMAN_DIV_1.."]+)"
PENMAN_PTN_2 = "([^"..PENMAN_DIV_2.."]+)"

function get_storage( hooman, name )
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

function penman_clean( text )
	return tostring( string.gsub( string.gsub( text, "\n", "\\n" ), "\t", "\\t" ))
end
function penman_restore( text )
	return string.gsub( text, "\\([nt])", { n = "\n", t = "\t", })
end

function penman_dude( is_lad )
	is_lad = is_lad or false
	local name = is_lad and "lad" or "dude"
	
	local children = EntityGetAllChildren( GameGetWorldStateEntity()) or {}
	if( #children > 0 ) then
		for i,child in ipairs( children ) do
			if( EntityGetName( child ) == name ) then
				return child
			end
		end
	end
	
	return nil
end

function penman_extract( data_raw )
	if( data_raw == nil ) then
		return nil
	end
	
	local data = {}
	for subdata_raw in string.gmatch( data_raw, PENMAN_PTN_1 ) do
		local subdata = {}
		for value in string.gmatch( subdata_raw, PENMAN_PTN_2 ) do
			table.insert( subdata, value )
		end
		table.insert( data, subdata )
	end
	
	return data
end

function penman_add( data )
	local packed = PENMAN_DIV_2
	for i,value in ipairs( data ) do
		packed = packed..value..PENMAN_DIV_2
	end
	packed = packed..PENMAN_DIV_1
	
	local storage_request = get_storage( GameGetWorldStateEntity(), "penman_request" )
	local request = ComponentGetValue2( storage_request, "value_string" )
	ComponentSetValue2( storage_request, "value_string", ( request == "" and PENMAN_DIV_1 or request )..packed )
end

function penman_id()
	local id = GlobalsGetValue( "PENMAN_REQUEST_ID", "0" ) + 1
	GlobalsSetValue( "PENMAN_REQUEST_ID", tostring( id ))
	return id
end

function penman_t2f_id()
	local storage_t2f = get_storage( GameGetWorldStateEntity(), "penman_t2f_count" )
	local count = ComponentGetValue2( storage_t2f, "value_int" )
	ComponentSetValue2( storage_t2f, "value_int", count + 1 )
	return count
end

function penman_bank( entity_id, name, value )
	local storage = EntityGetFirstComponentIncludingDisabled( entity_id, "VariableStorageComponent", "free" )
	if( storage == nil ) then
		storage = EntityAddComponent( entity_id, "VariableStorageComponent", 
		{
			_tags = "free",
			name = "free",
			value_string = "",
		})
	end
	
	if( name ~= nil ) then
		ComponentSetValue2( storage, "name", name )
		ComponentSetValue2( storage, "value_string", value )
	end
	ComponentRemoveTag( storage, "free" )
	
	return storage
end
function penman_steal( entity_id, name )
	local storage = get_storage( entity_id, name )
	if( storage ~= nil ) then
		local value = ComponentGetValue2( storage, "value_string" )
		
		ComponentSetValue2( storage, "name", "free" )
		ComponentSetValue2( storage, "value_string", "" )
		ComponentAddTag( storage, "free" )
		
		return value
	end
end

function penman_write( path, text )
	local id = penman_id()
	penman_add({ id, path, "wrt" })
	penman_bank( penman_dude( true ), "penman_in_"..id, penman_clean( text ))
end

function penman_read( path )
	local id = penman_id()
	penman_add({ id, path, })
	return id
end
function penman_return( id )
	local value = penman_steal( penman_dude(), "penman_out_"..id )
	if( value ~= nil ) then
		return penman_clean( value )
	end
end

function penman_t2f( id, text )
	if( id ~= nil ) then
		return dofile( "mods/penman/"..id.."_virt.lua" )
	else
		id = penman_t2f_id()
		penman_write( "mods/penman/"..id.."_virt.lua", text )
		return id
	end
end