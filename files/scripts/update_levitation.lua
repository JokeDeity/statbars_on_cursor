dofile("data/scripts/lib/utilities.lua")

local entity = GetUpdatedEntityID()
local name   = EntityGetName(entity)
local player = EntityGetWithTag("player_unit")[1]

if soc_lev_fade_timer == nil then soc_lev_fade_timer = 0 end
local FADE_DELAY = 60

local function hide()
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible = 0
    end)
end

if player == nil then hide() return end

local cd = EntityGetFirstComponent(player, "CharacterDataComponent")
if cd == nil then hide() return end

local total   = 2 ^ GameGetGameEffectCount(player, "HOVER_BOOST") * 3
local current = ComponentGetValueFloat(cd, "mFlyingTimeLeft")
if total == 0 then hide() return end
local perc = math.max(0, math.min(current / total, 1))

if perc >= 1 then
    if soc_lev_fade_timer == 0 then hide() return end
    soc_lev_fade_timer = soc_lev_fade_timer - 1
else
    soc_lev_fade_timer = FADE_DELAY
end

local mx, my = DEBUG_GetMouseWorld()

-- Levitation: vertical, right-inner. x+6, y-3. scale_x=0.35, scale_y=0.3
-- Image 2x20. Rendered: 2*0.35=0.7 wide, 20*0.3=6 tall. half=3.
-- Shows remaining levitation: full=full, depletes upward. BOTTOM edge fixed.
-- meter_y = frame_y + (1-perc)*half
local frame_x = mx + 3
local frame_y = my - 3
local half    = 20 * 0.3 / 2  -- = 3

if name == "soc_levitation_frame" then
    EntitySetTransform(entity, frame_x, frame_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.35
        vars.special_scale_y = 0.3
    end)
elseif name == "soc_levitation_meter" then
    local meter_y = frame_y + (1 - perc) * half
    EntitySetTransform(entity, frame_x, meter_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.35
        vars.special_scale_y = perc * 0.3
    end)
end
