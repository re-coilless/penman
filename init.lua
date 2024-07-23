ModMagicNumbersFileAdd( "mods/penman/extra/magic_numbers.xml" )

function OnWorldPreUpdate()
	if( HasFlagPersistent( "one_shall_not_spawn" )) then
		RemoveFlagPersistent( "one_shall_not_spawn" )
	end
end

--logo is prospero themed book

penman_d = penman_d or ModImageMakeEditable
penman_r = penman_r or ModTextFileGetContent
penman_w = penman_w or ModTextFileSetContent
function OnWorldPostUpdate()
	dofile_once( "mods/penman/_libman.lua" )
	
	pen.init_pipeline()
	if( not( pen.c.matter_test_file )) then
		pen.c.matter_test_file = true
		pen.magic_write( pen.FILE_MATTER, pen.get_xy_matter_file())
	end
	if( not( pen.c.matter_color_file )) then
		pen.c.matter_color_file = true
		pen.magic_write( pen.FILE_MATTER_COLOR, pen.FILE_XML_MATTER_COLOR )
	end

	dofile( "mods/penman/extra/check_em.lua" )
end