dofile("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")

local entity = GetUpdatedEntityID()
local name   = EntityGetName(entity)
local player = EntityGetWithTag("player_unit")[1]

if soc_mana_fade_timer == nil then soc_mana_fade_timer = 0 end
local FADE_DELAY = 90

local function hide()
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible = 0
    end)
end

if player == nil then hide() return end

local wand = find_the_wand_held(player)
if wand == nil then hide() return end

local ab = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
if ab == nil then hide() return end

local mana    = ComponentGetValue2(ab, "mana")
local maxmana = ComponentGetValue2(ab, "mana_max")
if maxmana == 0 then hide() return end
local perc = math.max(0, math.min(mana / maxmana, 1))

if perc >= 1 then
    if soc_mana_fade_timer == 0 then hide() return end
    soc_mana_fade_timer = soc_mana_fade_timer - 1
else
    soc_mana_fade_timer = FADE_DELAY
end

local mx, my = DEBUG_GetMouseWorld()

-- Mana bar: horizontal, below cursor. x-3, y+6. scale_x=0.3, scale_y=0.35
-- Image 20x2. Rendered: 20*0.3=6 wide, 2*0.35=0.7 tall. half=3.
-- Mana shows how much you HAVE: full = full bar, RIGHT edge fixed, shrinks leftward.
-- meter_x = frame_x + (1-perc)*half
local frame_x = mx - 3
local frame_y = my + 3
local half    = 20 * 0.3 / 2  -- = 3

if name == "soc_mana_frame" then
    EntitySetTransform(entity, frame_x, frame_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.3
        vars.special_scale_y = 0.35
    end)
elseif name == "soc_mana_meter" then
    local meter_x = frame_x + (1 - perc) * half
    EntitySetTransform(entity, meter_x, frame_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = perc * 0.3
        vars.special_scale_y = 0.35
    end)
end
