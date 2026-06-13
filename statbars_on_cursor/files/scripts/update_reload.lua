dofile("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")

local entity = GetUpdatedEntityID()
local name   = EntityGetName(entity)
local player = EntityGetWithTag("player_unit")[1]

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

local frames_left = ComponentGetValue2(ab, "mReloadNextFrameUsable") - GameGetFrameNum()
local total       = ComponentGetValue2(ab, "reload_time_frames")

if frames_left <= 0 or total == 0 then hide() return end

-- perc = how much of the reload is DONE (0=just started, 1=finished)
-- Clamp strictly so no out-of-range values cause the meter to escape the frame
local perc = math.max(0, math.min((total - frames_left) / total, 1))

local mx, my = DEBUG_GetMouseWorld()

-- Reload bar: horizontal, above cursor. x-3, y-6. scale_x=0.3, scale_y=0.35
-- Image 20x2. Rendered: 20*0.3=6 wide. half=3.
-- Progress bar: fills right-to-left (right edge fixed, left grows inward).
-- This matches how mana works (right-fixed) so the formula is the same.
-- meter_x = frame_x + (1-perc)*half
local frame_x = mx - 3
local frame_y = my - 4
local half    = 20 * 0.3 / 2  -- = 3

if name == "soc_reload_frame" then
    EntitySetTransform(entity, frame_x, frame_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.3
        vars.special_scale_y = 0.35
    end)
elseif name == "soc_reload_meter" then
    local meter_x = frame_x + (1 - perc) * half
    EntitySetTransform(entity, meter_x, frame_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = perc * 0.3
        vars.special_scale_y = 0.35
    end)
end
