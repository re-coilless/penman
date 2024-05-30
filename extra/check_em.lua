dofile_once( "mods/penman/_libman.lua" )

dummy = EntityGetWithName( "penman_dummy" ) or 0
if( dummy == 0 ) then
    dummy = EntityCreateNew( "penman_dummy" )
    EntitySetTransform( dummy, 100, -100 )
    GamePrint( "have some: "..dummy )
end

hooman = pen.get_hooman()
if( hooman == 0 or pen.testing_done ) then
    if( pen.testing_done == 1 ) then
        return
    else
        -- misc_tests()
        entity_cloner()
        -- text2func()
        
        pen.testing_done = 1
        return
    end
end
pen.testing_done = true

-- *************************************************************************

function misc_tests()

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

pen.print_table({
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
pen.magic_comp( hooman, { "DamageModelComponent", "balls" }, function( comp_id, is_enabled )
    print( ComponentGetValue2( comp_id, "max_hp" ))
end)

end

-- *************************************************************************

function entity_cloner()

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

	--[ProjectileComponent] mDamagedEntities
	--[GenomeDataComponent] friend_firemage, friend_thundermage
	--[BiomeTrackerComponent] current_biome
	--[CellEaterComponent] materials
	--[MagicConvertMaterialComponent] mFromMaterialArray, mToMaterialArray
	--[VerletPhysicsComponent] links, sprite, colors, materials

    if( skipped[ comp_name ] ~= nil ) then
        return EntityAddComponent2( entity_id, comp_name, vals )
    end
end

local counter = 1
for comp in pen.magic_sorter( literally_every_comp ) do
    if( counter > 170 ) then break end
    counter = counter + 1

    local patch = comp_patches[ comp ] or {}
    if( patch[ "_enabled" ] == nil ) then
        patch[ "_enabled" ] = true
    end

    add_comp( dummy, comp, patch )
end
GamePrint( pen.get_table_count( EntityGetAllComponents( dummy )).."/"..pen.get_table_count( literally_every_comp ))

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
}), "ExplosionComponent", function( comp_id, is_enabled )
    local a, b = pen.magic_comp( comp_id, {"config_explosion","delay"})
    print( tostring( a ).."|"..tostring( b ))

    a,b = pen.catch_comp( "ExplosionComponent", "config_explosiondelay", 1, ComponentObjectGetValue2, {comp_id,"config_explosion","delay"}, true )
    print( tostring( a ).."|"..tostring( b ))
end)

pen.magic_comp( dummy, "MaterialInventoryComponent", function( comp_id, is_enabled )
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
			pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, is_enabled )
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
            
			pen.chrono( pen.magic_comp, { hooman, "DamageModelComponent", function( comp_id, is_enabled )
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