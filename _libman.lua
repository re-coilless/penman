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

function lib.t2f( name, text )
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

function lib.get_xy_matter( x, y, duration )
	pen.lib.get_xy_matter_memo = pen.lib.get_xy_matter_memo or {
		probe = EntityLoad( "mods/penman/extra/matter_test.xml", x, y ),
		frames = GameGetFrameNum() + ( duration or 5 ),
		mtr_list = {},
	}
	
    local data = pen.lib.get_xy_matter_memo
	if( data.frames > GameGetFrameNum()) then
		local jitter_mag = 0.5
        EntityApplyTransform( data.probe, x + jitter_mag*pen.get_sign( math.random(-1,0)), y + jitter_mag*pen.get_sign( math.random(-1,0)))
        
        local dmg_comp = EntityGetFirstComponentIncludingDisabled( data.probe, "DamageModelComponent" )
        local matter = ComponentGetValue2( dmg_comp, "mCollisionMessageMaterials" )
        local count = ComponentGetValue2( dmg_comp, "mCollisionMessageMaterialCountsThisFrame" )
        for i,v in ipairs( count ) do
            if( v > 0 ) then
                local id = matter[i]
                pen.lib.get_xy_matter_memo.mtr_list[id] = ( data.mtr_list[id] or 0 ) + v
            end
        end
	else
		local max_id = { 0, 0 }
        for id,cnt in pairs( data.mtr_list ) do
            if( max_id[2] < cnt ) then
                max_id[1] = id
                max_id[2] = cnt
            end
        end
		
		EntityKill( data.probe )
		pen.lib.get_xy_matter_memo = nil
		
		return max_id[1]
	end
end

--[SAFE] ^^^^^^^^^^^^
if( io == nil ) then pen.lib = pen.lib or lib; return end
--[UNSAFE] vvvvvvvvvv



pen.lib = pen.lib or lib