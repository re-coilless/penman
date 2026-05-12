dofile_once( "mods/penman/_penman.lua" )

dummy = EntityGetWithName( "penman_dummy" ) or 0
if( dummy == 0 ) then
    dummy = EntityCreateNew( "penman_dummy" )
    EntitySetTransform( dummy, 100, -100 )
    GamePrint( "have some: "..dummy )
end

hooman = pen.get_hooman()
if( pen.c.testing_done ) then
    if( pen.c.testing_done == 1 ) then
        return
    else
        -- misc_tests()
        -- buttons()
        -- coloring()
        -- world2gui()
        -- filing()
        -- raters()
        -- input()
        -- scrolling()
        -- tipping()
        -- texting()
        -- fonting()
        -- cloner()
        -- text2func()
        -- vector()
        ost()

        pen.c.testing_done = 1--0
        return
    end
end
pen.c.testing_done = true

local test_input = {
    "#$%& (45\n|{-}you_should_not_see_this{-}|{>wave>{\n\thmmmmm {-}balls{-}NOPQ {>quake>{{-}ass{-}6LM.,}<wave<}\n/_;;;;; NOPQ}<quake<} 6LM.,efghÃÄÅ{>e1>{ÇÈÉтуzab cфхцgaш”6LM.,}<e1<}g{>c2>{{>shadow>{efjjg}<shadow<}{>runic>{{>color>{{-}|255|0|0|{-}ghghㅃÃту}<color<}}<runic<}ф{>color>{хцчш}<color<}”„…∞{>rainbow>{でとどぬballlls}<rainbow<} {>crossed>{{>cancer>{;ass}<cancer<}}<crossed<} hmmmでとg}<c2<}g ㅁㅂㅃㅅ ㅆ匆册卯 犯外处 冬鸟务此 按键绑 定无法 被更 改！ dfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldf",
    "#$%& (45\n||\n\thmmmmm NOPQ 6LM.,\n/_;;;;; NOPQ 6LM.,efghÃÄÅÇÈÉтуzab cфхцgaш”6LM.,efjjgghghÃÉтуфхцчш”„…∞でとどぬballlls ;ass hmmmでとgg ㅁㅂㅃㅅ ㅆ匆册卯 犯外处 冬鸟务此 按键绑 定无法 被更 改！ dfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldf",
    "{>underscore>{{>shadow>{{-}|HRMS|RED_2|FORCED|{-}000{>color>{{-}|PRSP|BLUE|{-}abc{-}|PRSP|RED|{-}de}<shadow<}fg}<color<}}<underscore<}",
    "dfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldf",
    "`~©∞ | /?âÂ | 1!ãÃ | 2ⓐąĄ | 3#ćĆ | 4$êÊ | 5%ęĘ | 6^îÎ | 7&ńŃ | 8*śŚ | 9(źŹ | 0)żŻ | -_«» | =+—¬ | \\|¡¿ | qQæÆ | wWåÅ | eEëË | rRýÝ | tTþÞ | yYÿŸ | uUüÜ | iIïÏ | oOöÖ | pPœŒ | \'\"ûÛ | aAäÄ | sSßẞ | dDđĐ | fFèÈ | gGéÉ | hHùÙ | jJúÚ | kKĳĲ | lLøØ | [{ôÔ | ]}łŁ | zZàÀ | xXáÁ | cCçÇ | vVìÌ | bBíÍ | nNñÑ | mMõÕ | ,<òÒ | .>óÓ | ;:°…"
}

-- *************************************************************************

function misc_tests()

--[[
pen.new.pixel( 50 - 0.5, 100 - 0.5, 4, {255,0,0})
pen.new.image( 50, 100, 5, pen.FILE_PIC_NUL, {
    alpha = 0.5, s_x = 10, s_y = 10, can_click = true, is_debugging = true, angle = math.rad( 0 )})
pen.new.pixel( 100 - 0.5, 100 - 0.5, 4, {255,0,0})
pen.new.image( 100, 100, 5, pen.FILE_PIC_NUL, {
    alpha = 0.5, s_x = 10, s_y = 10, can_click = true, is_debugging = true, angle = math.rad( -30 )})
pen.new.pixel( 100 - 0.5, 150 - 0.5, 4, {255,0,0})
pen.new.image( 100, 150, 5, "data/enemies_gfx/player.xml", { anim = "stand", auid = "huh",
    alpha = 1, s_x = 1, s_y = 1, can_click = true, is_debugging = true, angle = math.rad( 60 )})
pen.new.pixel( 100 - 0.5, 200 - 0.5, 4, {255,0,0})
pen.new.image( 100, 200, 5, pen.FILE_PIC_NUL, {
    alpha = 0.5, s_x = 10, s_y = 10, can_click = true, is_debugging = true, angle = math.rad( 5 )})

local gui = GuiCreate()
local balls = {}; balls[ gui ] = 1
print( balls[ gui ], tostring( gui ))

local m_x, m_y = DEBUG_GetMouseWorld()
if( InputIsKeyDown( 20 )) then --q
local result = pen.get_xy_matter( m_x, m_y, -10 )
if( pen.vld( result )) then print( tostring( CellFactory_GetName( result ))) end
end

print( tostring( pen.pic_builder( "data/debug/circle_16.png", 10, 15 ) or "" ))
pen.lib.font_builder( "data/fonts/font_pixel_noshadow.xml", {
    [55] = {
        forced = true,
        pos = { 140, 0, 6 },
        rect_w = 3, rect_h = 22,
    },
}, "data/fonts/font_pixel.png" )

print( pen.t.parse( "{[\"main\"]={[\",\"]=0x1.000000p+0,[\"right_alt\"]=0x1.000000p+0}}" ))

print( pen.t.pack( pen.t.unarray({ ass = 1, balls = 2, hmmm = 3, [5] = 5, [18] = 20 })))
print( pen.t.unarray( pen.t.pack( "|!ass!1!|!balls!2!|!hmmm!3!|!5!5!|!18!20!|" )))
print( pen.t.parse({ ass = 1, balls = 2, hmmm = 3, [5] = 5, [18] = 20 }))
print( pen.t.parse( "{[0]=\"balls\",[\"2\"]=\"ass\",[3]=-0.5,[4]=false,[\"huh\"]={[0]=\"balls\",[\"2\"]=\"ass\",[3]=-0.5,[4]=false,[\"huh\"]={}},[5]=\"balls\",[\"6\"]=\"ass\",[7]=-0.5,[420]={[0]={[1]=\"balls\"},[\"2\"]={[1]=\"ass\"},[3]={},[4]={[1]=false},[\"huh\"]=5}}" ))

pen.chrono( pen.setting_get, "19_abiding.SCORE_FILTERS" )
pen.chrono( function()
    for i = 1,1000 do
        ModSettingGet( "19_abiding.SCORE_FILTERS" )
        ModSettingGetNextValue( "19_abiding.SCORE_FILTERS" )
    end
end)
pen.chrono( function()
    for i = 1,1000 do
        pen.setting_get( "19_abiding.SCORE_FILTERS" )
    end
end)
pen.chrono( function()
    for i = 1,1000 do
        ModSettingGet( "19_abiding.SCORE_FILTERS" )
        ModSettingGetNextValue( "19_abiding.SCORE_FILTERS" )
    end
end)

print( tostring( pen.is_game_restarted()))
print({ GameGetDateAndTimeUTC()})

local dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
pen.magic_comp( dmg_comp, "materials_how_much_damage", { "acid", 69 })
local tbl = pen.magic_comp( dmg_comp, "materials_that_damage" )
print( tbl.acid )

local gene_comp = EntityGetFirstComponentIncludingDisabled( hooman, "GenomeDataComponent" )
pen.magic_comp( gene_comp, "friend_firemage", 0 )
print( tostring( pen.magic_comp( gene_comp, "friend_firemage" )))

pen.matter_fabricator( 0, -100, {
    matter = "sand",
    size = {10,15},
    count = {1,5},
    delay = {1,5},
    time = {5,20},
    is_real = true,
    is_real2 = true,
    is_fake = true,
    is_grid = true,
    frames = -1,
})

local herd = pen.magic_herder( "mods/penman/extra/test.csv", function( herd, h1, h2 )
    local dft = {
        balls = 0,
        hmmmm = 100,

        also = {
            balls = 100,
            hmmmm = 0,
        },
    }

    local out = 100
    if( dft[h1] ~= nil ) then
        out = dft[h1]
    elseif( dft.also[h2] ~= nil ) then
        out = dft.also[h2]
    end
    return out
end, {"orcs"})
print( herd.orcs.crawler )
print( herd.crawler.orcs )
print( herd.fire.orcs )
print( tostring( herd.balls.balls ))
print( tostring( herd.trap.hmmmm ))
print( tostring( herd.balls.trap ))
print( tostring( herd.hmmmm.healer ))

print({
    1,
    2,
    7,
    {
        hmm = {"a","b"},
        huh = {"c","d"},
    },
})

local dmg_comp = EntityGetFirstComponentIncludingDisabled( hooman, "DamageModelComponent" )
pen.clone_comp( hooman, dmg_comp, {
    _tags = "balls",
    max_hp = 50,
})
EntityRemoveComponent( hooman, dmg_comp )
pen.magic_comp( hooman, { "DamageModelComponent", "balls" }, function( comp_id, v, is_enabled )
    print( ComponentGetValue2( comp_id, "max_hp" ))
    v.hp = 0.01
end)

]]end

-- *************************************************************************

function buttons()

pen.new.pixel( 50, 50, -99, pen.P.VNL.RED )

pen.new.button( 50, 50, 0,
    pen.FILE_PIC_NUL, {
    auid = "testing_bruh",
    tip = "{>e1>{{>rainbow>{The Best Item Ever}<rainbow<}}<e1<}\nIT can DO {>wave>{things}<wave<} AND {>quake>{stuff}<quake<} and even comes WITH {>cancer>{ass}<cancer<}!!!",
    no_anim = false, highlight = pen.P.HRMS.BLUE_3,
    s_x = 10, s_y = 10, angle = math.rad(45),
    is_centered = true, is_debugging = false,
    ignore_multihover = true,

    lmb_event = function( pic_x, pic_y, pic_z, pic, d )
        if( not( d.no_anim )) then pen.atm( d.auid.."l", nil, true ) end
        return pic_x, pic_y, pic_z, pic, d
    end,
    rmb_event = function( pic_x, pic_y, pic_z, pic, d )
        if( not( d.no_anim )) then pen.atm( d.auid.."r", nil, true ) end
        return pic_x, pic_y, pic_z, pic, d
    end,
    hov_event = function( pic_x, pic_y, pic_z, pic, d )
        if( pen.vld( d.tip )) then pen.new.tip( d.tip, { is_active = true }) end
        if( d.highlight ) then
            local off_x, off_y = -1, -1
            local s_x = ( d.s_x or 1 )*d.dims[1] + 2
            local s_y = ( d.s_y or 1 )*d.dims[2] + 2
            if( d.is_centered ) then off_x, off_y = -s_x/2, -s_y/2 end
            off_x, off_y = pen.rot( off_x, off_y, d.angle )
            pen.new.pixel( pic_x + off_x, pic_y + off_y, pic_z + 0.001, d.highlight, s_x, s_y, nil, d.angle )
        end

        return pic_x, pic_y, pic_z, pic, d
    end,
    pic_func = function( pic_x, pic_y, pic_z, pic, d )
        local a = ( d.no_anim or false ) and 1 or math.min(
            pen.animate( 1, d.auid.."l", { type = "sine", frames = d.frames, stillborn = true }),
            pen.animate( 1, d.auid.."r", { ease_out = "sin3", frames = d.frames, stillborn = true }))
        local s_anim = {( 1 - a )/d.dims[1], ( 1 - a )/d.dims[2]}
        
        if( not( d.is_centered )) then
			pic_x, pic_y = pic_x + d.dims[1]/2, pic_y + d.dims[2]/2 end
        return pen.new.image( pic_x, pic_y, pic_z, pic, { is_centered = true,
            s_x = ( d.s_x or 1 )*( 1 - s_anim[1]), s_y = ( d.s_y or 1 )*( 1 - s_anim[2]), angle = d.angle })
    end,
})

end

-- *************************************************************************

function coloring()

local function gradient_me( rgb, shift, type )
    local min_s, min_v = 1, 0.25
    local hsv = pen.magic_rgb( rgb, false, type )
    return pen.magic_rgb({ hsv[1], min_s + ( 1 - min_s )*shift, min_v + ( 1 - min_v )*shift }, true, type )
end
for e = 1,2 do
    for i = 1,100 do
        local frame_num = GameGetFrameNum() + i
        pen.new.pixel( 100 + i, 5 + ( e - 1 )*5, 5, gradient_me( pen.P.VNL.RED, pen.animate( 1, true, { frames = 100, frame_num = frame_num, type = "sine" }), e == 1 and "hsv" or "okhsv" ), 1, 5 )
    end
end

local rgb = { 123, 45, 6 }
print( "RGB: "..pen.t.parse( rgb, true ))
local hsv = pen.magic_rgb( rgb, false, "hsv" )
print( "HSV: "..( 360*hsv[1])..", "..( 100*hsv[2] )..", "..( 100*hsv[3])) --20, 95, 48
rgb = pen.magic_rgb( hsv, true, "hsv" )
print( "TO_RGB: "..pen.t.parse( rgb, true ))
local okl = pen.magic_rgb( rgb, false, "oklab" )
print( "OKL: "..pen.t.parse( okl, true ))
rgb = pen.magic_rgb( okl, true, "oklab" )
print( "TO_RGB: "..pen.t.parse( rgb, true ))
local okv = pen.magic_rgb( rgb, false, "okhsv" )
print( "OKV: "..( 360*okv[1])..", "..( 100*okv[2] )..", "..( 100*okv[3])) --42, 96, 49
rgb = pen.magic_rgb( okv, true, "okhsv" )
print( "TO_RGB: "..pen.t.parse( rgb, true ))
local okh = pen.magic_rgb( rgb, false, "oklch" )
print( "OKH: "..pen.t.parse( okh, true ))
rgb = pen.magic_rgb( okh, true, "oklch" )
print( "TO_RGB: "..pen.t.parse( rgb, true ))

end

-- *************************************************************************

function world2gui()

local player_x, player_y = EntityGetTransform( hooman )
local pic_x, pic_y = pen.world2gui( player_x, player_y )
local new_x, new_y = pen.gui2world( pic_x, pic_y )
print( player_x.."="..new_x.." | "..player_y.."="..new_y )
pen.new.text( pic_x, pic_y - 30, pen.Z.WORLD_UI, "monkey", { is_centered_x = true, color = pen.P.VNL.RUNIC })
pic_x, pic_y = pen.get_mouse_pos()
pen.new.text( pic_x, pic_y, pen.Z.WORLD_UI, "balls", { is_centered_x = true, color = pen.P.VNL.WARNING })

end

-- *************************************************************************

function filing()

local the_one = GetUpdatedEntityID()
if( hooman == the_one ) then
    local path = "mods/penman/extra/write_test.lua"
    pen.magic_write( path, "print(\"ass\")" )
    dofile( path )
else
    EntityAddComponent2( hooman, "LuaComponent", { script_source_file = "mods/penman/extra/check_em.lua" })
end

end

-- *************************************************************************

function raters()

pen.rate_creature( enemy_id, hooman, data )
pen.rate_wand( wand_id, data )
pen.rate_spell( spell_id, data )
pen.rate_projectile( projectile_id, hooman, data )

end

-- *************************************************************************

function input()
if( not( ModIsEnabled( "mnee" ))) then return end
dofile_once( "mods/mnee/lib.lua" )

local iid = "balls"
-- if( GameGetFrameNum() > 600 ) then iid = nil end
local unicode = "me when fuckign the cфх цg aÃÉтш\n冬鸟务此 按键绑"
local source = "Now that you have a feeling for the keyboard and typing easy words, you will move on to full sentences with capitalization.\nTake your time and focus on keeping your eyes off of your keyboard!"

pen.c.typing_test = pen.c.typing_test or {}
local state = pen.c.typing_test.state or 0

local out, is_real = mnee.new_input( iid, 100, 100, 5, 200, 37, "", {
    no_wrap = false, is_live = true, --ban_unicode = true, force_numerical = true,
    color = state ~= 0 and pen.P.VNL[ state > 0 and "RUNIC" or "WARNING" ] or nil,
})
if( is_real ) then
    pen.c.typing_test.timer = pen.c.typing_test.timer or GameGetRealWorldTimeSinceStarted()*1000

    local is_correct = 1
    pen.w2c( source, function( char_id, letter_id, start_id, end_id )
        local a = string.sub( out, start_id, end_id )
        local b = string.sub( source, start_id, end_id )
        if( a ~= b ) then is_correct = a == "" and 0 or -1; return true end
    end)

    if( is_correct == 1 ) then
        if( pen.c.typing_test.state ~= 1 ) then
            local t = GameGetRealWorldTimeSinceStarted()*1000 - pen.c.typing_test.timer
            GamePrintImportant( "Your WPM: "..pen.rnd( 60000*35/t ))
        end
        pen.c.typing_test.state = 1
    else pen.c.typing_test.state = is_correct end
end

mnee.new_input( "ballz", 100, 175, 5, 200, 55, test_input[5], { jpad = true })
-- if( is_real ) then
--     print(out)
--     local f = pen.t2f( "kys", out )
--     if( pen.vld( f )) then f() end
-- end

pen.new.builder( true )

end

-- *************************************************************************

function scrolling()

if( t_memo == nil ) then
    local t = test_input[1]..test_input[1]..test_input[1]
    t_memo = t..t..t..t..t..t..t..t..t..t..t..t..t..t..t
end

pen.new.pixel( 100, 100, 5, pen.P.WHITE, 55, 30 )
pen.new.scroller( "balls", 100, 100, -5, 55, 30, function( scroll_pos )
    local scroll_y, scroll_x = unpack( scroll_pos )
    local dims = pen.new.text( 0, scroll_y, 0, t_memo, { fully_featured = true, dims = {50,-1}, color = {255,0,0}})
    return { dims[2], 1 }
end)
pen.debug_print( pen.t.parse( pen.c.scroll_memo[ "balls" ], true ), 200, 90, true )

pen.new.pixel( 100, 200, 5, pen.P.WHITE, 60, 15 )
pen.new.scroller( "ass", 100, 200, -5, 60, 15, function( scroll_pos )
    local scroll_y, scroll_x = unpack( scroll_pos )
    local dims = pen.new.text( scroll_x, scroll_y, 0, test_input[1], { fully_featured = true, color = {0,255,0}})
    return { dims[2], dims[1]}
end)
pen.debug_print( pen.t.parse( pen.c.scroll_memo[ "ass" ], true ), 200, 190, true )

if( true ) then return end

local item = "{>e1>{{>rainbow>{The Best Item Ever}<rainbow<}}<e1<}\nIT can DO {>wave>{things}<wave<} AND {>quake>{stuff}<quake<} and even comes WITH {>cancer>{ass}<cancer<}!!!"
pen.new.text_srcl( "hmm", 100, 170, 5, 30, item, { fully_featured = true })

pen.new.text_srcl( "hhmm", 200, 170, 5, { 30, 30 }, item, { fully_featured = true, font_mods = {
    e1 = function( data, pic_x, pic_y, pic_z, char_data, color, indexes )
        return pen.uncutter( function( cut_x, cut_y, cut_w, cut_h )
            pic_x.g, pic_y.g = pic_x.g + cut_x, pic_y.g + cut_y
            pic_x.l, pic_y.l = pic_x.l + cut_x, pic_y.l + cut_y
            return pen.FONT_MODS.tip( data, pic_x, pic_y, pic_z, char_data, color, indexes, "dfs", "LESSS GOOOOOO" )
        end)
    end,
}})

pen.new.text_srcl( "hmjm", 250, 170, 5, { 33, 33 }, "{>rainbow>{The Best Item EVER}<rainbow<}", { fully_featured = true })



-- gui = gui or GuiCreate(); GuiStartFrame( gui )
-- for i = 1,1000 do
--     GuiOptionsAddForNextWidget( gui, 47 ) --NoSound
-- 	GuiOptionsAddForNextWidget( gui, 50 ) --ScrollContainer_Smooth
--     GuiBeginScrollContainer( gui, 1, 200, 200, 50, 50, false, 0, 0)
--     -- pen.new.text( 0, 0, 0, test_input[1], { fully_featured = true, dims = {50,-1}, color = {0,255,0}})
--     GuiEndScrollContainer( gui )
-- end

end

-- *************************************************************************

function tipping()

local pic_x, pic_y, _, clicked, _, yep = pen.new.dragger( "balls", 400, 100, 100, 100 )
_, _, yep = pen.new.image( pic_x, pic_y, 5, pen.FILE_PIC_NUL, { s_x = 50, s_y = 50, can_click = true })
-- pen.new.tip( test_input[1], { is_active = yep, tid = "bs2", is_over = true })
pen.new.tip( test_input[3], { tid = "bs1" })
-- pen.new.tip( test_input[1], { is_active = yep, tid = "bs3", is_left = true })
-- pen.new.tip( test_input[2], { is_active = yep, tid = "bs4", is_over = true, is_left = true })
pen.new.tip( "{>e1>{{>rainbow>{The Best Item Ever}<rainbow<}}<e1<}\nIT can DO {>wave>{things}<wave<} AND {>quake>{stuff}<quake<} and even comes WITH {>cancer>{ass}<cancer<}!!!", {
    is_active = yep, pos = {390,199}, allow_hover = true, do_corrections = true, font_mods = {
        e1 = function( data, pic_x, pic_y, pic_z, char_data, color, indexes )
            return pen.FONT_MODS.tip( data, pic_x, pic_y, pic_z, char_data, color, indexes, "balls", "LESSS GOOOOOO" )
        end,
    }
})

-- pen.new.plot( 100, 200, pen.Z.TIPS, {
--     func = pen.animate,
--     input = function( x )
--         return 1, 15*x, { ease_int = "jump", ease_in = "sin", ease_out = "flr0", frames = 15 }
--     end,
--     color = pen.P.PRSP.WHITE,
-- })
pen.new.plot( 100, 200, pen.Z.TIPS, {
    range = { 0, 2.5 },
    func = pen.animate,
    input = function( x )
        return 1, 15*x, { type = "emap", frames = 15 }
    end,
    color = pen.P.PRSP.BLUE,
})
pen.new.plot( 100, 200, pen.Z.TIPS, {
    range = { 0, 2.5 },
    func = pen.animate,
    input = function( x )
        return 1, true, { ease_in = "log1.1", ease_out = "bck2", frames = 15 }
    end,
    color = pen.P.PRSP.RED,
})
pen.new.plot( 100, 200, pen.Z.TIPS, {
    func = pen.animate,
    input = function( x )
        return 1, 15*x, { ease_in = "sin3", ease_out = "wav1", frames = 15 }
    end,
    color = pen.P.PRSP.RED,
})
-- pen.new.plot( 100, 200, pen.Z.TIPS, {
--     func = pen.animate,
--     input = function( x )
--         return 1, 15*x, { ease_out = {"exp","wav"}, frames = 15 }
--     end,
--     color = pen.P.PRSP.BLUE,
-- })
-- pen.new.plot( 100, 200, pen.Z.TIPS, {
--     func = pen.animate,
--     input = function( x )
--         return 1, 15*x, { ease_out = "bnc50", frames = 15 }
--     end,
--     color = pen.P.PRSP.GREEN,
-- })
-- pen.new.plot( 100, 200, pen.Z.TIPS, {
--     func = pen.animate,
--     input = function( x )
--         return 1, 15*x, { type = "spke", ease_out = "pow", frames = 15 }
--     end,
--     color = pen.P.PRSP.GREY,
-- })

end

-- *************************************************************************

function texting()

-- pen.new.text:
-- LUA: 0.014300000002549ms
-- LUA: 0.020199999999022ms
-- LUA: 0.0097000000023399ms
-- LUA: 0.010699999998906ms

-- print( "pen.new.text: " ) --0.046200000000645ms
-- pen.chrono( pen.new.text, {
--     0, 0, 0, "123456789123456789123456789", { fully_featured = false, dims = {10,0}}
-- })
-- local gui = GuiCreate()
-- GuiStartFrame( gui )
-- print( "GuiText: " ) --0.0020000000004075ms
-- pen.chrono( GuiText, {
--     gui, 0, 0, "123"
-- })

local n = 0
local screen_w, screen_h = pen.get_screen_data()
local step_x = screen_w/40
local step_y = 9
for i = 1,screen_w/step_x do
    for e = 1,screen_h/step_y do
        n = n + 1
        pen.new.text( step_x*( i - 1 ), step_y*( e - 1 ), 0, "123456789123456789123456789", { fully_featured = false, dims = {step_x,step_y}})
        -- GuiText( gui, step_x*( i - 1 ), step_y*( e - 1 ), "123" )   
    end
end
print( n )

end

-- *************************************************************************

function fonting()

-- GamePrint( "∞" )
-- GamePrint( pen.magic_byte( pen.BYTE2ID[ 237117598 ]))
-- GamePrint( pen.magic_byte( pen.magic_byte( "∞" )))

pen.new.text( 150, 50, 0, "123456789123456789123456789", { dims = {100,0}, is_centered_x = true })
-- pen.new.image( 98, 98, 5, pen.FILE_PIC_NUL, { s_x = 52, s_y = 52 })
pen.new.text( 100, 150, 0, test_input[1], {
    -- is_huge = false,
    fully_featured = true,
    dims = {100, 100},
    -- scale = 2,
    -- font
    nil_val = "balls",
    color = {255,0,0,1},
    has_shadow = true,
    -- is_centered_x = true,
    -- is_right_x = true,
    is_centered_y = true,
    font_mods = {
        c1 = function( data, pic_x, pic_y, pic_z, char_data, color, indexes )
            return pic_x.l, pic_y.l, {0,255,0,0.5}
        end,
        c2 = function( data, pic_x, pic_y, pic_z, char_data, color, indexes )
            return pic_x.l, pic_y.l, pen.P.PRSP.RED
        end,
        
        e1 = function( data, pic_x, pic_y, pic_z, char_data, color, indexes )
            return pen.FONT_MODS.hyperlink( data, pic_x, pic_y, pic_z, char_data, color, indexes, "balls" )
        end,
    },
})
if(( pen.cache({ "hyperlink_state", "balls" }) or -1 ) == GameGetFrameNum()) then
    EntityLoad( "data/entities/animals/scavenger_smg.xml", 0, -200 )
end

pen.new.image( 298, 98, 5, pen.FILE_PIC_NUL, { s_x = 52, s_y = 52 })
pen.new.text( 300, 150, 0, test_input[1], {
    is_huge = false,
    fully_featured = true,
    dims = {100, 100},
    color = {255,0,0,1},
    is_centered_y = true,
})

end

-- *************************************************************************

function cloner()

local literally_every_comp = dofile_once( "mods/penman/extra/lists/every_comp.lua" )
local comp_patches = {
    DebugSpatialVisualizerComponent = { --deletes entity overtime
        _enabled = false,
    },
    GasBubbleComponent = { --dies outside water
        _enabled = false,
    },

    AltarComponent = {
        recognized_entity_tags = "balls",
        uses_remaining = -1,
    },
    PhysicsJointComponent = {
        breakable = false,
        body1_id = dummy,
        body2_id = dummy,
    },
    LoadEntitiesComponent = {
        kill_entity = false,
        timeout_frames = 9999999,
    },
    DamageModelComponent = {
        wait_for_kill_flag_on_death = true,
    },
    MagicConvertMaterialComponent = {
        kill_when_finished = false,
    },
    GhostComponent = {
        die_if_no_home = false,
    },
    ElectricityComponent = {
        splittings_min = 99999,
        splittings_max = 99999,
        mSplittingsLeft = -1,
    },
    UIInfoComponent = {
        name = "balls",
    },
    PhysicsImageShapeComponent = {
        is_root = true,
        material = CellFactory_GetType( "templebrick_box2d" ),
    },
    PhysicsBody2Component = {
        allow_sleep = false,
        auto_clean = false,
        kill_entity_if_body_destroyed = false,
        update_entity_transform = false,
        manual_init = true,
    },
    PhysicsBodyComponent = {
        auto_clean = false,
        kills_entity = false,
        update_entity_transform = false,
    },
    CharacterDataComponent = {
        platforming_type = 2,
    },
    VelocityComponent = {
        updates_velocity = false,
        displace_liquid = false,
    },
    ControlsComponent = {
        enabled = false,
    },
    CameraBoundComponent = {
        enabled = false,
    },
    CollisionTriggerComponent = {
        destroy_this_entity_when_triggered = false,
    },
    ProjectileComponent = {
        on_collision_die = false,
    },
    MaterialAreaCheckerComponent = {
        kill_after_message = false,
    },
    ElectricChargeComponent = {
        charge_time_frames = 9999999,
    },
    DieIfSpeedBelowComponent = {
        min_speed = 0,
    },
    AttachToEntityComponent = {
        destroy_component_when_target_is_gone = false,
    },
    ExplosionComponent = {
        kill_entity = false,
        trigger = "ON_DEATH",
    },

    MoveToSurfaceOnCreateComponent = {
        _enabled = false,
        type = "ENTITY",
    },
    SetStartVelocityComponent = {
        _enabled = false,
    },
}

local function add_comp( entity_id, comp_name, vals )
    local skipped = {
        MoveToSurfaceOnCreateComponent = 1, --always is selfremoved
        SetStartVelocityComponent = 1, --always is selfremoved

        ExplosionComponent = 1,
        DamageModelComponent = 1,
        MaterialInventoryComponent = 1,
        ProjectileComponent = 1,
        GenomeDataComponent = 1,
        BiomeTrackerComponent = 1,
        CellEaterComponent = 1,
        MagicConvertMaterialComponent = 1,
        VerletPhysicsComponent = 1,
    }
    
    if( skipped[ comp_name ] ~= nil ) then
        return EntityAddComponent2( entity_id, comp_name, vals )
    end
end

local counter = 1
for comp in pen.t.order( literally_every_comp ) do
    if( counter > 170 ) then break end
    counter = counter + 1

    local patch = comp_patches[ comp ] or {}
    if( patch[ "_enabled" ] == nil ) then
        patch[ "_enabled" ] = true
    end

    add_comp( dummy, comp, patch )
end
GamePrint( pen.t.count( EntityGetAllComponents( dummy )).."/"..pen.t.count( literally_every_comp ))

pen.magic_comp( dummy, "GenomeDataComponent", function( comp_id, v, is_enabled )
    pen.magic_comp( comp_id, {
        friend_firemage = 1,
        friend_thundermage = 1,
    })
end)

pen.clone_comp_debug = 1
pen.magic_comp( pen.clone_entity( dummy, 0, -100, {
    DamageModelComponent = {
        max_hp = 50,
        damage_multipliers = {
            curse = 5,
        },
    },
    InheritTransformComponent = {
        only_position = true,
        Transform = { 1, 1, 1, 1, 1 },
    },
    ExplosionComponent = {
        config_explosion = {
            damage = 50,
            delay = { 0, 9999 },
        },
    },
    MaterialInventoryComponent = {
        count_per_material_type = {
            blood = 50,
            water = 150,
        },
    },
    ProjectileComponent = {
        damage_critical = {
            mSucceeded = true,
            chance = 69,
        },
    },
}), "ExplosionComponent", function( comp_id, v, is_enabled )
    local a, b = pen.magic_comp( comp_id, {"config_explosion","delay"})
    print( tostring( a ).."|"..tostring( b ))

    a,b = pen.catch_comp( "ExplosionComponent", "config_explosiondelay", 1, ComponentObjectGetValue2, {comp_id,"config_explosion","delay"}, true )
    print( tostring( a ).."|"..tostring( b ))
end)

pen.magic_comp( dummy, "MaterialInventoryComponent", function( comp_id, v, is_enabled )
    pen.magic_comp( comp_id, "count_per_material_type", {
        blood = 69,
        water = 420,
    })
end)

end

-- *************************************************************************

function text2func()

if(( pen.balls or 0 ) == 0 ) then
	pen.lib.t2f( "balls", [[ function()
		dofile_once( "mods/penman/_penman.lua" )
        
		for i = 1,2 do
			pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, v, is_enabled )
				pen.magic_comp( comp_id, {"damage_multipliers","explosion"}, 5 )
				pen.magic_comp( comp_id, {
					hp = 5,
					max_hp = 50,
					mLastDamageFrame = function( old_val )
						print( old_val )
						return 5
					end,
				})
				print( pen.magic_comp( comp_id, "mLastDamageFrame" ))
			end})
            
			pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, v, is_enabled )
				ComponentObjectSetValue2( comp_id, "damage_multipliers", "explosion", 5 )
				ComponentSetValue2( comp_id, "hp", 5 )
				ComponentSetValue2( comp_id, "max_hp", 50 )
				print( ComponentGetValue2( comp_id, "mLastDamageFrame" ))
				ComponentSetValue2( comp_id, "mLastDamageFrame", 6 )
				print( ComponentGetValue2( comp_id, "mLastDamageFrame" ))
			end})
		end
	end ]])
	if( pen.balls ~= nil ) then
		pen.balls()
		pen.balls = 1
	end
end

end

-- *************************************************************************

function vector()
if( not( ModIsEnabled( "mnee" ))) then return end
if( not( ModIsEnabled( "vector_core" ))) then return end
dofile_once( "mods/mnee/lib.lua" )

pen.magic_write( "mods/vector_core/test.lua", [[
return function( guide )
    guide["test"] = {
        order_id = 5,
        name = "Main Test",
        is_active = true,
        steps = {
            {
                is_done = function() return true end,
                name = "Test",
                desc = "just checking idk, also lots of text and stuff",
                zone_xy = function( screen_x, screen_y ) return { 50, 100 } end,
                zone_wh = { 30, 15 },
            },
            {
                is_done = function() return true end,
                name = "Test2",
                desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                zone_xy = function( screen_x, screen_y ) return { screen_x/2 - 15, 2 } end,
                zone_wh = { 30, 15 },
                fog = 0.9,
            },
            {
                is_done = function() return true end,
                name = "Test3",
                desc = "Large-type.com lets you display & share text in a very large font directly from your browser. Whoa! That's handy whenever you need to read something on your screen from further away—for example, phone numbers and passwords. Nice! Even better, when you share text with large-type.com only the person with the link sees your text. Rendering happens locally on your browser and your text is not transmitted to any servers. How cool!",
                zone_xy = function( screen_x, screen_y ) return { 20, screen_y - 50 } end,
                zone_wh = { 300, 40 },
            },
            {
                is_done = function() return true end,
                name = "Test4",
                desc = "An eternal jungle ripped straight from a Death World and overran with Tyranid remnants. Its depths contain a violent space-time tear through which a mighty Chaos Citadel rears its horrific geometry.",
                zone_xy = function( screen_x, screen_y ) return { screen_x - 50, screen_y - 50 } end,
                zone_wh = { 40, 15 },
            },
            {
                is_done = true,
                zone_xy = { 200, 75 },
                zone_wh = { 100, 100 },

                func = function( pic_x, pic_y, zone_w, zone_h, screen_x, screen_y, alpha, fog, is_done, module, step )
                    fog( pic_x, pic_y, zone_w, zone_h, screen_x, screen_y, alpha )
                    return mnee.new_button( pic_x, pic_y + zone_h + 3, pen.Z.TUTORIAL_TIPS,
                        "mods/mnee/files/pics/key_right.png", { auid = "vector_tutorial_next", jpad = true })
                end,
            },
            {
                is_pause = true,
                is_checkpoint = true,
                is_done = function() return false end,
            },
        },
    }
    guide["checking"] = {
        order_id = 1,
        name = "Also Test",
        is_active = function() return false end,
    }
    return guide
end
]])

GlobalsSetValue( "VECTOR_TUTORIAL_LIST", GlobalsGetValue( "VECTOR_TUTORIAL_LIST", pen.DIV_1 ).."mods/vector_core/test.lua"..pen.DIV_1 )

end

-- *************************************************************************

function ost()
if( not( ModIsEnabled( "mrshll_core" ))) then return end

pen.magic_write( "mods/mrshll_core/test.lua", [[
return function( playlist )
    table.append( playlist, {
        is_active = true, --this is a func
        order_id = 5,
        name = "Test",
        energy = { 0, 1 },
        biome_name = "",
        biome_file = "", --this takes priority if is provided
        event = {
            "",
            "",
        },
    })
    return playlist
end
]])

GlobalsSetValue( "MRSHLL_OST_QUEUE", GlobalsGetValue( "MRSHLL_OST_QUEUE", pen.DIV_1 ).."mods/mrshll_core/test.lua"..pen.DIV_1 )

end