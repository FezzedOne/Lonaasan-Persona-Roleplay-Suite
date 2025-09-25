require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/persona/utils/client.lua"
require "/persona/utils/players.lua"
require "/persona/features/rotate.lua"
require "/persona/features/playerLog.lua"
require "/persona/utils/math.lua"
require "/persona/utils/localanimation.lua"

local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

local client = "unknown"
local playerRadarActive = false

function init(...)
    client = persona_client.getClient()

    _init(...)
end

function update(dt)
    local zoom = root.getConfigurationPath("zoomLevel") or 2

    if input.bindDown("persona", "rotateReset") then persona_feature_rotate.reset() end
    if input.bind("persona", "rotateAtCursor") then persona_feature_rotate.atCursor() end
    if input.bindDown("persona", "playerRadar") then
        playerRadarActive = not playerRadarActive
    end

    if playerRadarActive then
        local playerIds = world.entityQuery(world.entityAimPosition(player.id()), 100, {
            includedTypes = {"player", "npc", "monster"},
            order = "nearest"
        }) --persona_players.getAll()
        for _, playerId in ipairs(playerIds) do
            -- Maybe add like a radial circle to make the playerradar more clean? I did it anyways, looks cool!
            -- persona_localanimation.displayPortrait(world.entityPosition(player.id()),"/celestial/system/gas_giant/shadows/0.png", 0.8/zoom, 0, "middle")
            os.__localAnimator.clearDrawables()
            --interface.bindcanvas("personaRadar", true) UI stuff?
            persona_localanimation.displayImage({0,0},"/celestial/system/gas_giant/shadows/0.png?scalenearest=" .. 0.8/zoom)
            persona_players.getPortrait(playerId, zoom)
        end
    end

    if input.bind("persona", "playerInfo") then
        if os.__localAnimator then
            local selectedEntity = world.entityQuery(world.entityAimPosition(player.id()), 100, {
            includedTypes = {"player", "npc", "monster"},
            order = "nearest"
        })[1] or player.id()

            persona_players.getInfo(selectedEntity, zoom, client)
            os.__localAnimator.clearDrawables()
            persona_players.getPortrait(selectedEntity, zoom)
        end
    end

    persona_feature_playerLog.update()
    _update(dt)
end

function uninit(...)

    _uninit(...)
end