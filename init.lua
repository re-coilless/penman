ModMagicNumbersFileAdd( "mods/penman/extra/magic_numbers.xml" )

function OnPlayerSpawned( hooman )
	GlobalsSetValue( "PROSPERO_IS_REAL", "1" )
	
	local world_id = GameGetWorldStateEntity()
	EntityAddChild( world_id, EntityLoad( "mods/penman/extra/ctrl_body.xml" ))
	
	--logo is prospero themed book
end

penman_w = penman_w or ModTextFileSetContent
function OnWorldPreUpdate()
	if( HasFlagPersistent( "one_shall_not_spawn" )) then
		RemoveFlagPersistent( "one_shall_not_spawn" )
	end
	
	if( not( matter_test_file or false )) then
		matter_test_file = true
		
		local full_list = ""
		local full_matters = {
			CellFactory_GetAllLiquids(),
			CellFactory_GetAllSands(),
			CellFactory_GetAllGases(),
			CellFactory_GetAllFires(),
			CellFactory_GetAllSolids(),
		}
		for	i,list in ipairs( full_matters ) do
			for e,mtr in ipairs( list ) do
				full_list = full_list..mtr..","
			end
		end
		local matter_test = "mods/index_core/files/misc/matter_test.xml"
		penman_w( matter_test, string.gsub( ModTextFileGetContent( matter_test ), "_MATTERLISTHERE_", string.sub( full_list, 1, -2 )))
	end
end

function OnWorldPostUpdate()
	dofile_once( "mods/penman/_libman.lua" )

	local world_id = GameGetWorldStateEntity() or 0
	local ctrl_body = pen.get_hooman_child( world_id, "pen_ctrl" )
	local storage_request = pen.get_storage( ctrl_body, "request" )
	if( not( pen.vld( storage_request, true ))) then
		return
	end

	local request = ComponentGetValue2( storage_request, "value_string" )
	if( request ~= pen.DIV_1 ) then
		local stuff = pen.magic_parse( request )
		for i,v in ipairs( stuff ) do
			local storage_file = pen.get_storage( ctrl_body, v[2])
			penman_w( v[1], string.gsub( ComponentGetValue2( storage_file, "value_string" ), "\\([nt])", { n = "\n", t = "\t", }))
			ComponentSetValue2( storage_file, "name", "free" )
			ComponentSetValue2( storage_file, "value_string", "" )
		end
		ComponentSetValue2( storage_request, "value_string", pen.DIV_1 )
	end
	
	dofile( "mods/penman/extra/check_em.lua" )
end