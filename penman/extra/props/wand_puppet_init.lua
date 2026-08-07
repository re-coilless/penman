local puppet_id = 0
local item_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( item_id )
local arms = EntityGetInRadiusWithTag( x, y, 5, "polymorphable_NOT" ) or {}
for i,arm in ipairs( arms ) do
    if( EntityGetName( arm ) == "wand_puppet" ) then
        puppet_id = math.max( puppet_id, arm )
    end
end

if( puppet_id > 0 ) then
    EntitySetTransform( item_id, EntityGetTransform( puppet_id ))
end

local comp_id = GetUpdatedComponentID()
if( ComponentGetValue2( comp_id, "mTimesExecuted" ) > 2 ) then
    EntityKill( item_id )
end