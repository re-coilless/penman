dofile_once( "mods/penman/_libman.lua" )

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
        -- pen.c.testing_done = 1
        
        -- misc_tests()
        -- filing()
        -- raters()
        -- input()
        -- tipping()
        fonting()
        -- cloner()
        -- text2func()

        return
    end
end
pen.c.testing_done = true

local test_input = {
    "#$%& (45\n|{-}you_should_not_see_this{-}|{>wave>{\n\thmmmmm {-}balls{-}NOPQ {>quake>{{-}ass{-}6LM.,}<wave<}\n/_;;;;; NOPQ}<quake<} 6LM.,efghÃÄÅ{>e1>{ÇÈÉтуzab cфхцgaш”6LM.,}<e1<}g{>c2>{{>shadow>{efjjg}<shadow<}{>runic>{{>color>{{-}|255|0|0|{-}ghghㅃÃту}<color<}}<runic<}ф{>color>{хцчш}<color<}”„…∞{>rainbow>{でとどぬballlls}<rainbow<} {>crossed>{{>cancer>{;ass}<cancer<}}<crossed<} hmmmでとg}<c2<}g ㅁㅂㅃㅅ ㅆ匆册卯 犯外处 冬鸟务此 按键绑 定无法 被更 改！ dfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldf",
    "#$%& (45\n||\n\thmmmmm NOPQ 6LM.,\n/_;;;;; NOPQ 6LM.,efghÃÄÅÇÈÉтуzab cфхцgaш”6LM.,efjjgghghÃÉтуфхцчш”„…∞でとどぬballlls ;ass hmmmでとgg ㅁㅂㅃㅅ ㅆ匆册卯 犯外处 冬鸟务此 按键绑 定无法 被更 改！ dfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldf",
    "{>shadow>{000{>color>{{-}|PRSP|BLUE|{-}abc{-}|PRSP|RED|{-}de}<shadow<}fg}<color<}",
    "dfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldfdfjkghdfjglkfdjglkfdjglkf}<<}DjglkfdjglkfdjglkfdjglkfdjGakdjkldf"
}

-- *************************************************************************

function misc_tests()

print( pen.t.pack( pen.t.unarray({ ass = 1, balls = 2, hmmm = 3, [5] = 5, [18] = 20 })))
pen.t.print( pen.t.unarray( pen.t.pack( "|:ass:1:|:balls:2:|:hmmm:3:|:5:5:|:18:20:|" )))
print( pen.t.parse({ ass = 1, balls = 2, hmmm = 3, [5] = 5, [18] = 20 }))
pen.t.print( pen.t.parse( "{[0]=\"balls\",[\"2\"]=\"ass\",[3]=-0.5,[4]=false,[\"huh\"]={[0]=\"balls\",[\"2\"]=\"ass\",[3]=-0.5,[4]=false,[\"huh\"]={}},[5]=\"balls\",[\"6\"]=\"ass\",[7]=-0.5,[420]={[0]={[1]=\"balls\"},[\"2\"]={[1]=\"ass\"},[3]={},[4]={[1]=false},[\"huh\"]=5}}" ))

--[[
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
pen.t.print({ GameGetDateAndTimeUTC()})

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

pen.t.print({
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

gui = gui or GuiCreate()
GuiStartFrame( gui )

uid = pen.new_input( gui, 1, "balls", 100, 100, 5, {

})

end

-- *************************************************************************

function tipping()

gui = gui or GuiCreate()
GuiStartFrame( gui )

local uid, pic_x, pic_y, _, clicked, _, yep = pen.new_dragger( gui, 1, "balls", 300, 200, 100, 100 )
uid, _, _, yep = pen.new_image( gui, uid, pic_x, pic_y, 5, "data/ui_gfx/empty_white.png", { s_x = 50, s_y = 50, can_click = true })
-- uid = pen.new_tooltip( gui, uid, test_input[1], { is_active = yep, tid = "bs2", is_over = true })
uid = pen.new_tooltip( gui, uid, test_input[2], { tid = "bs1" })
-- uid = pen.new_tooltip( gui, uid, test_input[1], { is_active = yep, tid = "bs3", is_left = true })
-- uid = pen.new_tooltip( gui, uid, test_input[2], { is_active = yep, tid = "bs4", is_over = true, is_left = true })
uid = pen.new_tooltip( gui, uid, "{>e1>{{>rainbow>{The Best Item Ever}<rainbow<}}<e1<}\nIT can DO {>wave>{things}<wave<} AND {>quake>{stuff}<quake<} and even comes WITH {>cancer>{ass}<cancer<}!!!", {
    is_active = yep, pos = {390,200}, allow_hover = true, do_corrections = true, font_mods = {
        e1 = function( gui, uid, pic_x, pic_y, pic_z, char_data, color, indexes )
            return pen.FONT_MODS.tip( gui, uid, pic_x, pic_y, pic_z, char_data, color, indexes, "balls", "LESSS GOOOOOO" )
        end,
    }
})

pen.new_plot( 100, 200, pen.Z_LAYERS.tips, {
    func = pen.animate,
    input = function( x )
        return 1, 15*x, { ease_in = "sin10", frames = 15 }
    end,
    color = pen.PALETTE.PRSP.WHITE,
})
pen.new_plot( 100, 200, pen.Z_LAYERS.tips, {
    func = pen.animate,
    input = function( x )
        return 1, 15*x, { ease_out = "wav", frames = 15 }
    end,
    color = pen.PALETTE.PRSP.RED,
})
pen.new_plot( 100, 200, pen.Z_LAYERS.tips, {
    func = pen.animate,
    input = function( x )
        return 1, 15*x, { ease_out = {"exp","wav"}, frames = 15 }
    end,
    color = pen.PALETTE.PRSP.BLUE,
})
pen.new_plot( 100, 200, pen.Z_LAYERS.tips, {
    func = pen.animate,
    input = function( x )
        return 1, 15*x, { ease_out = "bnc50", frames = 15 }
    end,
    color = pen.PALETTE.PRSP.GREEN,
})
pen.new_plot( 100, 200, pen.Z_LAYERS.tips, {
    func = pen.animate,
    input = function( x )
        return 1, 15*x, { type = "spke", ease_out = "pow", frames = 15 }
    end,
    color = pen.PALETTE.PRSP.GREY,
})

end

-- *************************************************************************

function fonting()

-- GamePrint( "∞" )
-- GamePrint( pen.magic_byte( pen.BYTE_TO_ID[ 237117598 ]))
-- GamePrint( pen.magic_byte( pen.magic_byte( "∞" )))

gui = gui or GuiCreate()
GuiStartFrame( gui )

pen.new_text( gui, 0, 150, 50, 0, "123456789123456789123456789", { dims = {100,0}, is_centered_x = true })
pen.new_image( gui, 1, 98, 98, 5, pen.FILE_PIC_NUL, { s_x = 52, s_y = 52 })
pen.new_text( gui, 0, 100, 150, 0, test_input[1], {
    dims = {100, 100},
    -- scale = 2,
    -- font
    nil_val = "balls",
    color = {255,0,0,1},
    -- is_shadow = true,
    -- is_centered_x = true,
    is_centered_y = true,
    funcs = {
        c1 = function( gui, uid, pic_x, pic_y, pic_z, char_data, color, indexes )
            return uid, pic_x[1], pic_y[1], {0,255,0,0.5}
        end,
        c2 = function( gui, uid, pic_x, pic_y, pic_z, char_data, color, indexes )
            return uid, pic_x[1], pic_y[1], pen.PALETTE.PRSP.RED
        end,
        
        e1 = function( gui, uid, pic_x, pic_y, pic_z, char_data, color, indexes )
            return pen.FONT_MODS.hyperlink( gui, uid, pic_x, pic_y, pic_z, char_data, color, indexes, "balls" )
        end,
    },
})
if(( pen.cache({ "hyperlink_state", "balls" }) or -1 ) == GameGetFrameNum()) then
    EntityLoad( "data/entities/animals/scavenger_smg.xml", 0, -200 )
end

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