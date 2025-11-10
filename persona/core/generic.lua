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
require "/persona/features/dance.lua"
require "/persona/utils/log.lua"

local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

-- key triggers
local fastSelectActive = false
local lastFastSelectState = false
local playerRadarActive = false
local stickymotesActive = false
local stickToEntityActive = false
local flightActive = false

-- variables
local client = "unknown"
local selfId = 0
local lastShiftState = false
local lastParentState = nil

-- fastwheel options (export to json later)
local emoteOptions = {{
    name = "idle",
    description = "Idle"
}, {
    name = "happy",
    description = "Happy"
}, {
    name = "sad",
    description = "Sad"
}, {
    name = "neutral",
    description = "Neutral"
}, {
    name = "laugh",
    description = "Laugh"
}, {
    name = "annoyed",
    description = "Annoyed"
}, {
    name = "oh",
    description = "Oh"
}, {
    name = "oooh",
    description = "Oooh"
}, {
    name = "wink",
    description = "Wink"
}, {
    name = "sleep",
    description = "Sleep"
}}

local stateOptions = {{
    name = "Stand",
    description = "Stand"
}, {
    name = "Fly",
    description = "Fly"
}, {
    name = "Fall",
    description = "Fall"
}, {
    name = "Sit",
    description = "Sit"
}, {
    name = "Lay",
    description = "Lay"
}, {
    name = "Duck",
    description = "Duck"
}, {
    name = "Walk",
    description = "Walk"
}, {
    name = "Run",
    description = "Run"
}, {
    name = "Swim",
    description = "Swim"
}, {
    name = nil,
    description = "Reset"
}}

local danceOptions1 = {{
    name = "wave",
    description = "Wave",
    cyclic = false,
    duration = 0.75,
    steps = 8
}, {
    name = "warmhands",
    description = "Warming",
    cyclic = true
}, {
    name = "typing",
    description = "Typing",
    cyclic = true
}, {
    name = "steer",
    description = "Steer",
    cyclic = true
}, {
    name = "sell",
    description = "Sell",
    cyclic = false,
    duration = 1,
    steps = 7
}, {
    name = "punch",
    description = "Punch",
    cyclic = false,
    duration = 0.5,
    steps = 4
}, {
    name = "pressbutton",
    description = "Press",
    cyclic = false,
    duration = 0.5,
    steps = 4
}, {
    name = "panic",
    description = "Panic",
    cyclic = true
}, {
    name = "drink",
    description = "Drink",
    cyclic = true
}, {
    name = "comfort",
    description = "Comfort",
    cyclic = false,
    duration = 3.5,
    steps = 15
}}
local danceOptions2 = {{
    name = "posedance",
    description = "Pose Dance",
    cyclic = true
}, {
    name = "hylotldance",
    description = "Hylotl Dance",
    cyclic = true
}, {
    name = "armswingdance",
    description = "Arm Swing",
    cyclic = true
}, {
    name = "titanic",
    description = "Titanic",
    cyclic = true
}, {
    name = "postmail",
    description = "Post Mail",
    cyclic = false,
    duration = 1,
    steps = 8
}, {
    name = "wiggledance",
    description = "Wiggle Dance",
    cyclic = true
}}
local wheelOptions = {}
local optionTables = {emoteOptions, danceOptions1, danceOptions2} -- Add more tables here as needed
local currentTableIndex = 1

function init(...)
    client = persona_client.getClient()
    selfId = player.id()
    persona_feature_playerLog.init()
    player.emote("Idle", 0)

    if not status.statusProperty("personaIgnored", false) and
        player.equippedTech("body") ~= "personabody" and player.equippedTech("legs") ~= "personalegs" and
            player.equippedTech("head") ~= "personahead" then
        player.interact("ScriptPane", "/interface/persona/techEquip/techEquip.config")
    end

    _init(...)
end

function update(dt, ...)

    if os.__localAnimator then
        os.__localAnimator.clearDrawables()
    end

    if os.__tech then
        optionTables = {emoteOptions, stateOptions, danceOptions1, danceOptions2} -- Update option tables if tech is present
    end

    local zoom = root.getConfigurationPath("zoomLevel") or 2
    local shift = input.bind("persona", "shiftOverride") --input.key("RShift") or input.key("LShift")
    local shiftDown = input.bindDown("persona", "shiftHoldOverride") --input.keyDown("RShift") or input.keyDown("LShift")
    local alt = input.bindDown("persona", "altOverride") --input.keyDown("RAlt") or input.keyDown("LAlt")

    if input.bindDown("persona", "rotateReset") then
        persona_feature_dance.exit()
        persona_feature_rotate.reset()
    end
    if input.bind("persona", "rotateAtCursor") then
        persona_feature_dance.exit()
        persona_feature_rotate.atCursor(zoom, shift)
    end
    if input.bind("persona", "resizeReset") then
        persona_feature_dance.exit()
        persona_feature_size.reset()
    end
    if input.bind("persona", "resizeToCursor") then
        persona_feature_dance.exit()
        persona_feature_size.toCursor(zoom, shift)
    end

    if input.bindDown("persona", "stickToEntity") then
        stickToEntityActive = not stickToEntityActive

        interface.queueMessage("Stick to entity: " .. (stickToEntityActive and "^green;Enabled^reset;" or "^red;Disabled^reset;"))

        if not stickToEntityActive then
            persona_feature_position.reset()
        end
    end

    if input.bindDown("persona", "flight") then
        flightActive = not flightActive

        interface.queueMessage("Flight mode: " .. (flightActive and "^green;Enabled^reset;" or "^red;Disabled^reset;"))

        if not flightActive then
            mcontroller.controlParameters({
                gravityEnabled = true
            })
        end
    end

    if input.bindDown("persona", "teleport") then
        mcontroller.setPosition(player.aimPosition())
    end

    if input.bindDown("persona", "playerRadar") then
        playerRadarActive = not playerRadarActive
    end
    if input.bindDown("persona", "stickymotes") then
        persona_feature_stickymotes.reset()
        stickymotesActive = not stickymotesActive

        interface.queueMessage("Stickymotes: " .. (stickymotesActive and "^green;Enabled^reset;" or "^red;Disabled^reset;"))
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
            if contains(emoteOptions, result) then
                player.emote(result.name)
            elseif contains(danceOptions1, result) or contains(danceOptions2, result) then
                persona_feature_dance.dance(result)
            elseif contains(stateOptions, result) then
                local state = result.name or nil
                if os.__tech then
                    if not state or lastParentState == state then
                       state = nil
                    end
                    os.__tech.setParentState(state)
                end
                lastParentState = state
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
        persona_feature_position.flight(shiftDown, alt)
    end

    if stickToEntityActive then
        persona_feature_position.stickToEntity()
    end

    if stickymotesActive then
        persona_feature_stickymotes.update()
    end

    persona_feature_size.update()

    persona_feature_playerLog.update()

    if input.bindDown("persona", "test") then
    end

    _update(dt)
end

function uninit(...)
    persona_feature_playerLog.uninit()
    _uninit(...)
end
