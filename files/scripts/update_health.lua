dofile("data/scripts/lib/utilities.lua")

local entity = GetUpdatedEntityID()
local name   = EntityGetName(entity)
local player = EntityGetWithTag("player_unit")[1]

if soc_health_prev_hp    == nil then soc_health_prev_hp    = nil end
if soc_health_show_timer == nil then soc_health_show_timer = 0  end

local SHOW_FRAMES      = 360
local LOW_HP_THRESHOLD = 0.30
local REGEN_THRESHOLD  = 0.03

local function hide()
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible = 0
    end)
end

if player == nil then hide() return end

local dm = EntityGetFirstComponent(player, "DamageModelComponent")
if dm == nil then hide() return end

local hp    = ComponentGetValueFloat(dm, "hp")
local maxhp = ComponentGetValueFloat(dm, "max_hp")
if maxhp == 0 then hide() return end
local perc = math.max(0, math.min(hp / maxhp, 1))

local should_show = false

if perc < LOW_HP_THRESHOLD then
    should_show = true
    soc_health_show_timer = SHOW_FRAMES
else
    if soc_health_prev_hp ~= nil then
        local delta      = hp - soc_health_prev_hp
        local delta_perc = math.abs(delta) / maxhp
        if delta < 0 or (delta > 0 and delta_perc > REGEN_THRESHOLD) then
            soc_health_show_timer = SHOW_FRAMES
        end
    end
    if soc_health_show_timer > 0 then
        soc_health_show_timer = soc_health_show_timer - 1
        should_show = true
    end
end

soc_health_prev_hp = hp

if not should_show then hide() return end

local mx, my = DEBUG_GetMouseWorld()

-- Health bar: vertical, left of cursor. x-6, y-3. scale_x=0.35, scale_y=0.3
-- Image 2x20. Rendered: 2*0.35=0.7 wide, 20*0.3=6 tall. half=3.
-- Depletes upward: BOTTOM edge fixed. bar shrinks from top down as HP drops.
-- meter_y = frame_y + (1-perc)*half
local frame_x = mx - 4
local frame_y = my - 3
local half    = 20 * 0.3 / 2  -- = 3

if name == "soc_health_frame" then
    EntitySetTransform(entity, frame_x, frame_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.35
        vars.special_scale_y = 0.3
    end)
elseif name == "soc_health_meter" then
    local meter_y = frame_y + (1 - perc) * half
    EntitySetTransform(entity, frame_x, meter_y)
    edit_component(entity, "SpriteComponent", function(comp, vars)
        vars.visible         = 1
        vars.special_scale_x = 0.35
        vars.special_scale_y = perc * 0.3
    end)
end
