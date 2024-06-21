local LOCAL_PATH = "mods/penman/"
local orig_do_mod_appends = do_mod_appends
do_mod_appends = function( filename, ... ) --stolen from https://github.com/alex-3141/noita-parallax
    LOCAL_PATH = filename:match("(.+/)[^/]+")
    do_mod_appends = orig_do_mod_appends
    do_mod_appends( filename, ... )
end

dofile_once( LOCAL_PATH.."_penman.lua" )
pen.lib = pen.lib or {}
pen.LOCAL_PATH = LOCAL_PATH

local load_list = { "nxml", "csv", "bitser", "base64", "matrix", "complex", "EZWand" }
for i,v in ipairs( load_list ) do
	pen.lib[ v ] = dofile_once( table.concat({ pen.LOCAL_PATH, v, ".lua" })
end
--dialog
--gusgui
--parallax

if( GameHasFlagRun( pen.FLAG_UPDATE_UTF )) then
	local the_concept_of_table_itself = dofile_once( "mods/penman/extra/lists/every_character.lua" )
	for i,the_concept_of_set_itself in ipairs( the_concept_of_table_itself ) do
		local the_concept_of_language_itself = string.gsub( string.gsub( pen.t2t( the_concept_of_set_itself ), "\n", "" ), "%s", "" )
		local the_concept_of_number_itself, the_concept_of_counter_itself = 0, 0
		for the_concept_of_character_itself in string.gmatch( the_concept_of_language_itself, "." ) do
			local the_concept_of_byte_itself = string.byte( the_concept_of_character_itself )
			if( the_concept_of_byte_itself == string.byte( "." )) then
				if( the_concept_of_number_itself > 0 and pen.BYTE_TO_ID[ the_concept_of_number_itself ] == nil ) then
					local the_concept_of_i_itself = 1
					for str in string.gmatch( the_concept_of_language_itself, pen.ptrn( "%." )) do
						if( the_concept_of_i_itself == the_concept_of_counter_itself ) then
							pen.BYTE_TO_ID[ the_concept_of_number_itself ] = pen.magic_byte( str )
							print( "["..the_concept_of_number_itself.."]="..pen.BYTE_TO_ID[ the_concept_of_number_itself ])
							break
						end
						the_concept_of_i_itself = the_concept_of_i_itself + 1
					end
				end
				the_concept_of_number_itself = 0
				the_concept_of_counter_itself = the_concept_of_counter_itself + 1
			else
				the_concept_of_number_itself = bit.lshift( the_concept_of_number_itself, 10 ) + the_concept_of_byte_itself
			end
		end
		print("\n")
	end
end

function pen.lib.magic_write( path, file )
	local id = tonumber( GlobalsGetValue( "PENMAN_WRITE_INDEX", "0" ))
    GlobalsSetValue( "PENMAN_WRITE_INDEX", id + 1 )

    local ctrl_body = pen.get_child( GameGetWorldStateEntity(), "pen_ctrl" )
    local storage_request = pen.get_storage( ctrl_body, "request" )
	local request = ComponentGetValue2( storage_request, "value_string" )
	ComponentSetValue2( storage_request, "value_string", table.concat({ request, pen.DIV_2, path, pen.DIV_2, "file", id, pen.DIV_2, pen.DIV_1 }))

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

function pen.lib.t2f( name, text )
	if( pen[ name ] == nil ) then
		local memo = table.concat({ "t2f_", name, "_memo" })
        if( pen[ memo ] ~= nil ) then
            pen[ name ] = dofile( pen[ memo ])
            pen[ memo ] = nil
        else
            local num = tonumber( GlobalsGetValue( "PENMAN_VIRTUAL_INDEX", "0" ))
            GlobalsSetValue( "PENMAN_VIRTUAL_INDEX", num + 1 )
            local path = table.concat({ pen.FILE.t2f, num, ".lua" })
            pen.lib.magic_write( path, "return "..text )
            pen[ memo ] = path
        end
	end
    
	return pen[ name ]
end

function pen.lib.nxml2entity()
end

function pen.lib.entity2nxml()
end

--[SAFE] ^^^^^^^^^^^^
if( io == nil ) then return end
--[UNSAFE] vvvvvvvvvv

--patcher
--pollnet