require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/persona/utils/client.lua"
require "/persona/utils/players.lua"
require "/persona/features/rotate.lua"
require "/persona/features/playerLog.lua"
require "/persona/features/stickymotes.lua"
require "/persona/utils/math.lua"
require "/persona/utils/localanimation.lua"
require "/persona/features/position.lua"
require "/persona/features/size.lua"

local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

local client = "unknown"
local selfId = 0
local playerRadarActive = false
local stickymotesActive = false
local stickToEntityActive = false

function init(...)
    client = persona_client.getClient()
    selfId = player.id()
    persona_feature_playerLog.init()
    _init(...)
end

function update(dt)
    local zoom = root.getConfigurationPath("zoomLevel") or 2

    if input.bindDown("persona", "rotateReset") then
        persona_feature_rotate.reset()
    end
    if input.bind("persona", "rotateAtCursor") then
        persona_feature_rotate.atCursor()
    end
    if input.bind("persona", "resizeReset") then
        persona_feature_size.reset()
    end
    if input.bind("persona", "resizeToCursor") then
        persona_feature_size.toCursor()
    end

    if input.bindDown("persona", "stickToEntity") then
        stickToEntityActive = not stickToEntityActive

        if not stickToEntityActive then
            persona_feature_position.reset()
        end
    end
    if input.bindDown("persona", "playerRadar") then
        playerRadarActive = not playerRadarActive
    end
    if input.bindDown("persona", "stickymotes") then
        persona_feature_stickymotes.reset()
        stickymotesActive = not stickymotesActive
    end

    if stickToEntityActive then
        persona_feature_position.stickToEntity()
    end

    if playerRadarActive then
        if os.__localAnimator then
            local playerIds = persona_players.getAll()
            os.__localAnimator.clearDrawables()

            persona_localanimation.displayImage({0, 0},
                "/celestial/system/gas_giant/shadows/0.png", 0.8 / zoom)
            persona_localanimation.displayText(vec2.add(mcontroller.position(), {0, 28 / zoom}),
                "^shadow;PlayerRadar^reset;" or "", 1.5 / zoom)
            for _, playerId in ipairs(playerIds) do
                persona_players.getPortrait(playerId, zoom)
            end
        end
    end

    if stickymotesActive then
        persona_feature_stickymotes.update()
    end

    if input.bind("persona", "playerInfo") then
        if os.__localAnimator then
            local selectedEntity = world.entityQuery(world.entityAimPosition(selfId), 100, {
                includedTypes = {"player"},
                order = "nearest"
            })[1] or selfId

            persona_players.getInfo(selectedEntity, zoom, client)
            persona_players.getPortrait(selectedEntity, zoom)
        end
    end

    persona_feature_size.update()

    persona_feature_playerLog.update()
    _update(dt)
end

function uninit(...)
    persona_feature_playerLog.uninit()
    _uninit(...)
end
