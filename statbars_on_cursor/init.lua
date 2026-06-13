local function kill_existing(name)
    local e = EntityGetWithName(name)
    local guard = 0
    while e do
        guard = guard + 1
        if guard > 10 then break end
        EntityKill(e)
        e = EntityGetWithName(name)
    end
end

function OnPlayerSpawned(player_entity)
    local x, y = EntityGetTransform(player_entity)

    local names = {
        "soc_mana_frame", "soc_mana_meter",
        "soc_reload_frame", "soc_reload_meter",
        "soc_health_frame", "soc_health_meter",
        "soc_levitation_frame", "soc_levitation_meter",
        "soc_oxygen_frame", "soc_oxygen_meter",
    }
    for _, name in ipairs(names) do kill_existing(name) end

    EntityLoad("mods/statbars_on_cursor/files/entities/mana_frame.xml",       x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/mana_meter.xml",       x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/reload_frame.xml",     x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/reload_meter.xml",     x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/health_frame.xml",     x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/health_meter.xml",     x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/levitation_frame.xml", x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/levitation_meter.xml", x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/oxygen_frame.xml",     x, y)
    EntityLoad("mods/statbars_on_cursor/files/entities/oxygen_meter.xml",     x, y)
end
