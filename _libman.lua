local LOCAL_PATH = "mods/penman/"
local orig_do_mod_appends = do_mod_appends
do_mod_appends = function( filename, ... ) --stolen from https://github.com/alex-3141/noita-parallax
    LOCAL_PATH = filename:match("(.+/)[^/]+")
    do_mod_appends = orig_do_mod_appends
    do_mod_appends( filename, ... )
end

-- jit.util.funcinfo(setfenv(1, getfenv())) --thanks to ImmortalDamned

dofile_once( LOCAL_PATH.."_penman.lua" )
pen.lib = pen.lib or {}; pen.LOCAL_PATH = LOCAL_PATH
for i,v in ipairs({ "nxml", "csv", "base64", "matrix", "complex", "EZWand" }) do
	pen.lib[ v ] = dofile_once( table.concat({ pen.LOCAL_PATH, "lib/", v, ".lua" }))
end
--dialog (modify to be more generalized + transition to penman)
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

pen.I = {
	__mt = { --just steal the whole complex.lua
		__add = function( a, b )
			return pen.I.new( a.r + b.r, a.i + b.i )
		end,
		__sub = function( a, b )
			return pen.I.new( a.r - b.r, a.i - b.i )
		end,
		__mul = function( a, b )
			return pen.I.new( a.r*b.r - a.i*b.i, a.r*b.i + a.i*b.r )
		end,
		__tostring = function( a )
			return table.concat({ "[", a.r, ";", a.i, "]" })
		end,
	},
	new = function( r, i )
		return setmetatable({ r = r, i = i or 0 }, pen.I.__mt )
	end,
	expi = function( i )
		return pen.I.new( math.cos( i ), math.sin( i ))
	end,
}
pen.ANIM_INTERS.frir = function( t, delta, p ) --https://rosettacode.org/wiki/Fast_Fourier_transform#Lua
	local function fft( tbl ) --literal shit, write custom implementation
		local n = #tbl
		if( n <= 1 ) then return end

		local odd, even = {}, {}
		for i = 1,n,2 do
			table.insert( odd, tbl[i])
			table.insert( even, tbl[ i + 1 ])
		end
		fft( even ); fft( odd )

		for k = 1,n/2 do
			local t = even[k]*pen.I.expi( -2*math.pi*( k - 1 )/n )
			pen.c.fft_data[k], pen.c.fft_data[ k + n/2 ] = odd[k] + t, odd[k] - t
		end
		return pen.c.fft_data
	end
	
	--come up with a good default param set
	--check if it's looped properly and add buffer points (45 degree straight) if is not
	return pen.cache({ "fft_memo", pen.t.pack( p )}, function()
		pen.c.fft_data = {}
		for i,v in ipairs( p or {}) do pen.c.fft_data[i] = pen.I.new( v ) end
		local out = fft( pen.c.fft_data ); pen.c.fft_data = nil
		return pen.t.clone( out )
	end)
end

-- pen.magic_draw = pen.magic_draw or function( path, w, h ) --fucking bullshit
-- 	pen.init_pipeline( pen.INIT_THREADS.DRAWER, { path, string.sub( 10000 + w, -4, -1 )..string.sub( 10000 + h, -4, -1 )})
-- end
pen.magic_write = pen.magic_write or function( path, file )
	pen.init_pipeline( pen.INIT_THREADS.WRITER, { path, string.gsub( string.gsub( file, "\n", "\\n" ), "\t", "\\t" )})
end
pen.t2f = pen.t2f or function( name, text )
	if( pen[ name ] == nil ) then
		local memo = table.concat({ "t2f_", name, "_memo" })
        if( pen[ memo ] ~= nil ) then
            pen[ name ] = dofile( pen[ memo ])
            pen[ memo ] = nil
        else
            local num = tonumber( GlobalsGetValue( pen.INDEX_T2F, "0" ))
            GlobalsSetValue( pen.INDEX_T2F, num + 1 )
            local path = table.concat({ pen.FILE.t2f, num, ".lua" })
            pen.magic_write( path, "return "..text )
            pen[ memo ] = path
        end
	end
    
	return pen[ name ]
end

function pen.lib.sprite_builder( path )
	local xml = pen.lib.nxml.parse( pen.magic_read( path ))
	pen.t.loop( xml:all_of( "RectAnimation" ), function( i,v )
		if( v.attr.parent == nil ) then return end
		local p = pen.t.loop( xml:all_of( "RectAnimation" ), function( e,p )
			if( p.attr.name == v.attr.parent ) then return p end
		end)

		v.children = p.children
		pen.t.loop( p.attr, function( k,a ) v.attr[k] = v.attr[k] or a end)
		v.attr.parent = nil
	end)
	pen.magic_write( path, tostring( xml ))
end

function pen.lib.font_builder( font, chars, atlas, data ) --search the id at https://symbl.cc/
	chars, data = chars or {}, data or {}

	local xml = pen.lib.nxml.parse( ModDoesFileExist( font ) and pen.magic_read( font ) or pen.FILE_XML_FONT )
	if( data.pic ) then xml:first_of( "Texture" ).content = { data.pic } end
	if( data.height ) then xml:first_of( "LineHeight" ).content = { data.height } end
	if( data.char_padding ) then xml:first_of( "CharSpace" ).content = { data.char_padding } end
	if( data.word_padding ) then xml:first_of( "WordSpace" ).content = { data.word_padding } end
	local pic_id, pic = 0, xml:first_of( "Texture" ):text()
	local _, pic_w, pic_h = pen.magic_draw( pic, 0, 0 )
	-- pen.t.loop( xml:all_of( "QuadChar" ), function( i, c )
	-- 	local new_x = c.attr.rect_x + c.attr.rect_w + 2
	-- 	if( pic_w < new_x ) then pic_w = new_x end
	-- 	local new_y = c.attr.rect_y + c.attr.rect_h + 2
	-- 	if( pic_h < new_y ) then pic_h = new_y end
	-- end)

	local new_chars, x_memo = {}, pic_w + 1
	for i,c in pairs( chars ) do
		local got_some = pen.t.loop( xml:all_of( "QuadChar" ), function( i, c )
			if( c.attr.id == i ) then return true end
		end)
		if( not( got_some )) then
			chars[ i ].forced = true
			table.insert( xml.children, {
				name = "QuadChar",
				children = {},
				attr = {
					id = i, width = 0,
					offset_x = 0, offset_y = 0,
					rect_h = 0, rect_w = 0,
					rect_x = 0, rect_y = 0,
				},
			})
		end
	end
	pen.t.loop( xml:all_of( "QuadChar" ), function( i, c )
		if( chars[ c.attr.id ] == nil ) then return end
		if( not( chars[ c.attr.id ].forced )) then return end
		
		c.attr.rect_x = x_memo
		c.attr.rect_y = chars[ c.attr.id ].pos[2] or 0
		c.attr.width = chars[ c.attr.id ].pos[3]
		table.insert( new_chars, {
			chars[ c.attr.id ].pos[1],
			chars[ c.attr.id ].pos[2],
			chars[ c.attr.id ].pos[3],
			c.attr.rect_x, c.attr.rect_y,
		})
		c.attr.rect_w = chars[ c.attr.id ].rect_w
		c.attr.rect_h = chars[ c.attr.id ].rect_h
		c.attr.offset_x = chars[ c.attr.id ].offset_x or 0
		c.attr.offset_y = chars[ c.attr.id ].offset_y or 0
		x_memo = x_memo + c.attr.width + 1
	end)
	
	if( pen.vld( atlas )) then
		pic_id, pic = pen.pic_builder( pic, pic_w + ( pen.t.count( chars ) + 5 )*10, pic_h )
		if( not( pen.vld( pic_id ))) then return end
		xml:first_of( "Texture" ).content = { pic }
		pen.t.loop( new_chars, function( i, v )
			pen.pic_paster( pic_id, pen.magic_draw( atlas, 0, 0 ), { v[3], pic_h }, { v[4], v[5]}, { v[1], v[2]})
		end)
	end
	
	pen.magic_write( font, tostring( xml ))
end

function pen.lib.nxml2entity()
end

function pen.lib.entity2nxml()
end

--[SAFE] ^^^^^^^^^^^^
if( io == nil ) then return end
--[UNSAFE] vvvvvvvvvv

--bitser
--patcher
--pollnet