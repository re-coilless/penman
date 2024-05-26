function OnPlayerSpawned( hooman )
	GlobalsSetValue( "HERMES_IS_REAL", "1" )
	
	local world_id = GameGetWorldStateEntity()
	local ctrl_body = EntityLoad( "mods/penman/extra/ctrl_body.xml" )
	EntityAddComponent( ctrl_body, "VariableStorageComponent", 
	{
		name = "request",
		value_string = "&",
	})
	EntityAddChild( world_id, ctrl_body )

	--logo is pen in inkpot
end

penman_w = penman_w or ModTextFileSetContent
function OnWorldPostUpdate()
	dofile_once( "mods/penman/_libman.lua" )

	local world_id = GameGetWorldStateEntity() or 0
	local ctrl_body = pen.get_hooman_child( world_id, "pen_ctrl" )
	local storage_request = pen.get_storage( ctrl_body, "request" )
	if( storage_request == 0 ) then
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