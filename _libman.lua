dofile_once( "mods/penman/_penman.lua" )

local lib = {}

function lib.magic_write( path, file )
	local id = tonumber( GlobalsGetValue( "PENMAN_WRITE_INDEX", "0" ))
    GlobalsSetValue( "PENMAN_WRITE_INDEX", id + 1 )

    local ctrl_body = pen.get_hooman_child( GameGetWorldStateEntity(), "pen_ctrl" )
    local storage_request = pen.get_storage( ctrl_body, "request" )
	local request = ComponentGetValue2( storage_request, "value_string" )
	ComponentSetValue2( storage_request, "value_string", request..pen.DIV_2..path..pen.DIV_2.."file"..id..pen.DIV_2..pen.DIV_1 )

    local storage_new = pen.get_storage( ctrl_body, "free" )
    if( not( pen.vld( storage_new ))) then
        storage_new = EntityAddComponent( ctrl_body, "VariableStorageComponent", 
		{
			name = "free",
			value_string = "",
		})
    end
    ComponentSetValue2( storage_new, "name", "file"..id )
    ComponentSetValue2( storage_new, "value_string", tostring( string.gsub( string.gsub( file, "\n", "\\n" ), "\t", "\\t" )))
end

function lib.text2func( name, text )
	if( pen[ name ] == nil ) then
        if( pen[ name.."_memo" ] ~= nil ) then
            pen[ name ] = dofile( pen[ name.."_memo" ])
            pen[ name.."_memo" ] = nil
        else
            local num = tonumber( GlobalsGetValue( "PENMAN_VIRTUAL_INDEX", "0" ))
            GlobalsSetValue( "PENMAN_VIRTUAL_INDEX", num + 1 )

            local path = "data/debug/vpn"..num..".lua"
            lib.magic_write( path, "return "..text )
            pen[ name.."_memo" ] = path
        end
	end
    
	return pen[ name ]
end

--make scripts to save(convert to nxml tbl) and load(via nxml tbl) entities

if( io == nil ) then
    pen.lib = pen.lib or lib
    return
end

--[UNSAFE]



pen.lib = pen.lib or lib