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
require "/persona/features/fastSelect.lua"
require "/persona/features/sit.lua"

local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

local client = "unknown"
local selfId = 0
local fastSelectActive = false
local lastFastSelectState = false
local playerRadarActive = false
local stickymotesActive = false
local stickToEntityActive = false
local flightActive = false
local emoteOptions = {"idle", "happy", "sad", "neutral", "laugh", "annoyed", "oh", "oooh", "wink", "sleep"}
local otherOptions = {"sit", "wave", "dance", "cheer", "point", "lay"}
local wheelOptions = {}
local optionTables = {emoteOptions, otherOptions} -- Add more tables here as needed
local currentTableIndex = 1
local lastShiftState = false

function init(...)
    client = persona_client.getClient()
    selfId = player.id()
    persona_feature_playerLog.init()
    _init(...)
end

function update(dt, ...)

    if os.__localAnimator then
        os.__localAnimator.clearDrawables()
    end
    local zoom = root.getConfigurationPath("zoomLevel") or 2
    local shift = input.key("RShift") or input.key("LShift")
    local alt = input.keyDown("RAlt") or input.keyDown("LAlt")

    if input.bindDown("persona", "rotateReset") then
        persona_feature_rotate.reset()
    end
    if input.bind("persona", "rotateAtCursor") then
        persona_feature_rotate.atCursor(zoom, shift)
    end
    if input.bind("persona", "resizeReset") then
        persona_feature_size.reset()
    end
    if input.bind("persona", "resizeToCursor") then
        persona_feature_size.toCursor(zoom, shift)
    end

    if input.bindDown("persona", "stickToEntity") then
        stickToEntityActive = not stickToEntityActive

        if not stickToEntityActive then
            persona_feature_position.reset()
        end
    end

    if input.bindDown("persona", "flight") then
        flightActive = not flightActive
        if not flightActive then
            mcontroller.controlParameters({
                gravityEnabled = true
            })
        end
    end

    if input.bindDown("persona", "playerRadar") then
        playerRadarActive = not playerRadarActive
    end
    if input.bindDown("persona", "stickymotes") then
        persona_feature_stickymotes.reset()
        stickymotesActive = not stickymotesActive
    end

    fastSelectActive = false
    if input.bind("persona", "fastSelect") then
        fastSelectActive = true
        wheelOptions = optionTables[currentTableIndex]
        persona_feature_fastSelect.show(wheelOptions, zoom)
    end

    -- Cycle through option tables when shift is pressed (not held) and fast select is active
    if fastSelectActive and shift and not lastShiftState then
        currentTableIndex = currentTableIndex + 1
        if currentTableIndex > #optionTables then
            currentTableIndex = 1
        end
        -- Update the wheel with the new options immediately
        wheelOptions = optionTables[currentTableIndex]
        persona_feature_fastSelect.show(wheelOptions, zoom)
    end

    if input.bindDown("persona", "fastSelectAdd") then
        table.insert(wheelOptions, "test_" .. #wheelOptions + 1)
    end
    lastShiftState = shift

    if not fastSelectActive and lastFastSelectState then
        local result = persona_feature_fastSelect.select()
        if result then
            if currentTableIndex == 1 then
                player.emote(result)
                sb.logInfo("Selected emote: %s", result)
            elseif currentTableIndex == 2 and contains(otherOptions, result) then
                sb.logInfo("Selected other option: %s", result)
            end
        end
    end
    lastFastSelectState = fastSelectActive

    if playerRadarActive then
        if os.__localAnimator then
            local playerIds = persona_players.getAll()

            persona_localanimation.displayImage({0, 0}, "/celestial/system/gas_giant/shadows/0.png", 0.8 / zoom)
            persona_localanimation.displayText(vec2.add(mcontroller.position(), {0, 28 / zoom}),
                "^shadow;PlayerRadar^reset;" or "", 1.5 / zoom)
            for _, playerId in ipairs(playerIds) do
                persona_players.getPortrait(playerId, zoom)
            end
        end
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

    if flightActive then
        persona_feature_position.flight(shift, alt)
    end

    if stickToEntityActive then
        persona_feature_position.stickToEntity()
    end

    if stickymotesActive then
        persona_feature_stickymotes.update()
    end

    persona_feature_size.update()

    persona_feature_playerLog.update()

    persona_feature_sit.sit()

    _update(dt)
end

function uninit(...)
    persona_feature_playerLog.uninit()
    _uninit(...)
end
