function shot( proj_id ) --special thanks to ImmortalDamned for providing this fix!
    dofile_once( "mods/penman/_penman.lua" )
    
    if( not( pen.vld( proj_id, true ))) then return end

    local arm_id = GetUpdatedEntityID()
    local hooman = EntityGetRootEntity( arm_id )
    local proj_comp = EntityGetFirstComponentIncludingDisabled( proj_id, "ProjectileComponent" )
    
    if( not( pen.vld( proj_comp, true ))) then return end
    if( ComponentGetValue2( proj_comp, "mWhoShot" ) ~= arm_id ) then return end
    ComponentSetValue2( proj_comp, "mWhoShot", hooman )
end