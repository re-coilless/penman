ModMagicNumbersFileAdd( "mods/penman/extra/magic_numbers.xml" )

function OnModInit()
	dofile_once( "mods/penman/_libman.lua" )
end

function OnPlayerSpawned( hooman )
	GlobalsSetValue( "PROSPERO_IS_REAL", "1" )
	
	local world_id = GameGetWorldStateEntity()
	EntityAddChild( world_id, EntityLoad( "mods/penman/extra/ctrl_body.xml" ))
	
	--logo is prospero themed book
end

function OnWorldPreUpdate()
	if( HasFlagPersistent( "one_shall_not_spawn" )) then
		RemoveFlagPersistent( "one_shall_not_spawn" )
	end
end

penman_w = penman_w or ModTextFileSetContent
function OnWorldPostUpdate()
	dofile_once( "mods/penman/_libman.lua" )

	local world_id = GameGetWorldStateEntity() or 0
	local ctrl_body = pen.get_child( world_id, "pen_ctrl" )
	local storage_request = pen.get_storage( ctrl_body, "request" )
	if( not( pen.vld( storage_request, true ))) then
		return
	end
	
	local request = ComponentGetValue2( storage_request, "value_string" )
	if( request ~= pen.DIV_1 ) then
		local stuff = {}
		for f in string.gmatch( request, pen.ptrn(1)) do
			local file = {}
			for v in string.gmatch( f, pen.ptrn(2)) do
				table.insert( file, v )
			end
			if( pen.vld( file )) then
				table.insert( stuff, file )
			end
		end
		
		for i,v in ipairs( stuff ) do
			local storage_file = pen.get_storage( ctrl_body, v[2])
			penman_w( v[1], string.gsub( ComponentGetValue2( storage_file, "value_string" ), "\\([nt])", { n = "\n", t = "\t", }))
			ComponentSetValue2( storage_file, "name", "free" )
			ComponentSetValue2( storage_file, "value_string", "" )
		end
		ComponentSetValue2( storage_request, "value_string", pen.DIV_1 )
	end
	
	if( not( pen.matter_test_file )) then
		pen.matter_test_file = true
		pen.lib.magic_write( pen.FILE_MATTER, pen.get_xy_matter_file())
	end

	dofile( "mods/penman/extra/check_em.lua" )
end