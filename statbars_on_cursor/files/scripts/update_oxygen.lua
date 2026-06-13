dofile("data/scripts/lib/utilities.lua")

local entity = GetUpdatedEntityID()
local name   = EntityGetName(entity)
local player = EntityGetWithTag("player_unit")[1]

if soc_oxy_fade_timer == nil then soc_oxy_fade_timer = 0 end
local FADE_DELAY = 60

local function hide()
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible = 0
    end)
end

if player == nil then hide() return end

local dm = EntityGetFirstComponent(player, "DamageModelComponent")
if dm == nil then hide() return end

local total   = ComponentGetValueFloat(dm, "air_in_lungs_max")
local current = ComponentGetValueFloat(dm, "air_in_lungs")
if total == 0 then hide() return end
local perc = math.max(0, math.min(current / total, 1))

if perc >= 1 then
    if soc_oxy_fade_timer == 0 then hide() return end
    soc_oxy_fade_timer = soc_oxy_fade_timer - 1
else
    soc_oxy_fade_timer = FADE_DELAY
end

local mx, my = DEBUG_GetMouseWorld()

-- Oxygen: vertical, right-outer. x+7, y-3. scale_x=0.35, scale_y=0.3
-- Image 2x20. Rendered: 2*0.35=0.7 wide, 20*0.3=6 tall. half=3.
-- Shows remaining air: full=full, depletes upward. BOTTOM edge fixed.
-- meter_y = frame_y + (1-perc)*half
local frame_x = mx + 4
local frame_y = my - 3
local half    = 20 * 0.3 / 2  -- = 3

if name == "soc_oxygen_frame" then
    EntitySetTransform(entity, frame_x, frame_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.35
        vars.special_scale_y = 0.3
    end)
elseif name == "soc_oxygen_meter" then
    local meter_y = frame_y + (1 - perc) * half
    EntitySetTransform(entity, frame_x, meter_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.35
        vars.special_scale_y = perc * 0.3
    end)
end
