---persona fastSelect functions
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.fastSelect = string.persona.feature.fastSelect or {};

persona_feature_fastSelect = {}

require '/scripts/vec2.lua'
require '/persona/utils/log.lua'
require '/persona/utils/localanimation.lua'

-- Constants
local CONSTANTS = {
    INNER_RADIUS = 4.85,
    OUTER_RADIUS = 16,
    TEXT_RADIUS = 10.7,
    HEADER_OFFSET = 17.5,
    TWO_PI = math.pi * 2,

    COLORS = {
        SELECTED = "red",
        BORDER = "gray",
        CENTER_ALPHA = 200
    },

    LINE_WIDTHS = {
        NORMAL = 1.0,
        SELECTED = 2.0
    },

    TEXT_SCALES = {
        HEADER = 1.25,
        NORMAL = 1.0,
        SELECTED = 1.2
    }
}

-- State variables
local state = {
    selectInitialCursorPosition = {0, 0},
    selectLocation = {0, 0},
    selectedOption = 1,
    options = {}
}

-- Helper functions
local function normalizeAngle(angle)
    return angle < 0 and angle + CONSTANTS.TWO_PI or angle
end

local function getOptionFromCursor(cursorRotation, optionCount)
    return math.floor((cursorRotation / CONSTANTS.TWO_PI) * optionCount) + 1
end

local function clampOptionIndex(option, maxOptions)
    return option > maxOptions and 1 or option
end

local function getAngleForOption(optionIndex, totalOptions)
    return ((optionIndex - 1) / totalOptions) * CONSTANTS.TWO_PI
end

local function getTextAngleForOption(optionIndex, totalOptions)
    return (((optionIndex - 1) + 0.5) / totalOptions) * CONSTANTS.TWO_PI
end

local function getPositionAtDistance(center, angle, distance)
    return vec2.add(center, vec2.mul(vec2.norm({math.cos(angle), math.sin(angle)}), distance))
end

local function drawCenterElements(zoom)
    local centerOffset = world.distance(state.selectLocation, mcontroller.position())

    -- Background images
    persona_localanimation.displayImage(centerOffset, "/celestial/system/terrestrial/biomes/midnight/maskie2.png",
        0.5 / zoom, {255, 255, 255, CONSTANTS.COLORS.CENTER_ALPHA})
    persona_localanimation.displayImage(centerOffset, "/celestial/system/gas_giant/shadows/0.png", 0.5 / zoom)

    -- Foreground images
    persona_localanimation.displayImage(centerOffset, "/celestial/system/terrestrial/biomes/midnight/maskie1.png",
        0.145 / zoom)
    persona_localanimation.displayImage(centerOffset, "/celestial/system/gas_giant/shadows/0.png", 0.15 / zoom)
end

local function drawHeaderText(zoom)
    local headerText = state.selectedOption > 0 and state.options[state.selectedOption].description or "back"
    local headerPosition = vec2.add(state.selectLocation, {0, CONSTANTS.HEADER_OFFSET / zoom})

    persona_localanimation.displayText(headerPosition, "^shadow;FastSelect " .. headerText .. "^reset;",
        CONSTANTS.TEXT_SCALES.HEADER / zoom)
end

local function drawOptionBorders(zoom)
    for i = 0, #state.options - 1 do
        local angle = getAngleForOption(i + 1, #state.options)
        local lineStart = getPositionAtDistance(state.selectLocation, angle, CONSTANTS.INNER_RADIUS / zoom)
        local lineEnd = getPositionAtDistance(state.selectLocation, angle, CONSTANTS.OUTER_RADIUS / zoom)

        persona_localanimation.displayLine(lineStart, lineEnd, CONSTANTS.COLORS.BORDER,
            CONSTANTS.LINE_WIDTHS.NORMAL / zoom)
    end
end

local function drawUnselectedOptions(zoom)
    for i = 1, #state.options do
        if i ~= state.selectedOption then
            local textAngle = getTextAngleForOption(i, #state.options)
            local textPosition = getPositionAtDistance(state.selectLocation, textAngle, CONSTANTS.TEXT_RADIUS / zoom)

            persona_localanimation.displayText(textPosition, state.options[i].description or "",
                CONSTANTS.TEXT_SCALES.NORMAL / zoom)
        end
    end
end

local function drawSelectedOption(zoom)
    if state.selectedOption <= 0 then
        return
    end

    local selectedAngleStart = getAngleForOption(state.selectedOption, #state.options)
    local selectedAngleEnd = getAngleForOption(state.selectedOption + 1, #state.options)

    -- Draw selection borders
    local innerStart = getPositionAtDistance(state.selectLocation, selectedAngleStart, CONSTANTS.INNER_RADIUS / zoom)
    local outerStart = getPositionAtDistance(state.selectLocation, selectedAngleStart, CONSTANTS.OUTER_RADIUS / zoom)
    local innerEnd = getPositionAtDistance(state.selectLocation, selectedAngleEnd, CONSTANTS.INNER_RADIUS / zoom)
    local outerEnd = getPositionAtDistance(state.selectLocation, selectedAngleEnd, CONSTANTS.OUTER_RADIUS / zoom)

    persona_localanimation.displayLine(innerStart, outerStart, CONSTANTS.COLORS.SELECTED,
        CONSTANTS.LINE_WIDTHS.SELECTED / zoom)
    persona_localanimation.displayLine(innerEnd, outerEnd, CONSTANTS.COLORS.SELECTED,
        CONSTANTS.LINE_WIDTHS.SELECTED / zoom)

    -- Draw selected text
    local selectedTextAngle = getTextAngleForOption(state.selectedOption, #state.options)
    local selectedTextPosition = getPositionAtDistance(state.selectLocation, selectedTextAngle,
        CONSTANTS.TEXT_RADIUS / zoom)

    if (#state.options < state.selectedOption) then
        state.selectedOption = #state.options
    end
    persona_localanimation.displayText(selectedTextPosition, "^" .. CONSTANTS.COLORS.SELECTED .. ";" ..
        state.options[state.selectedOption].description .. "^reset;", CONSTANTS.TEXT_SCALES.SELECTED / zoom)
end

local function drawCenterText(distanceToCursor, zoom)
    local centerText = distanceToCursor <= CONSTANTS.INNER_RADIUS / zoom and "^red;back^reset;" or "back"
    local textScale = distanceToCursor <= CONSTANTS.INNER_RADIUS / zoom and CONSTANTS.TEXT_SCALES.SELECTED or
                          CONSTANTS.TEXT_SCALES.NORMAL

    persona_localanimation.displayText(state.selectLocation, centerText, textScale / zoom)
end

-- Main functions
function persona_feature_fastSelect.show(options, zoom)
    state.options = options or {}

    -- Initialize select location if not set
    -- change code so wheel selection is the offset from player position to aim position
    if state.selectInitialCursorPosition[1] == 0 and state.selectInitialCursorPosition[2] == 0 then
        state.selectInitialCursorPosition = world.distance(player.aimPosition(), mcontroller.position())
    end
    state.selectLocation = vec2.add(mcontroller.position(), state.selectInitialCursorPosition)

    -- Calculate cursor position and distance
    local cursorOffset = world.distance(player.aimPosition(), state.selectLocation)
    local distanceToCursor = vec2.mag(cursorOffset)
    local cursorRotation = normalizeAngle(vec2.angle(cursorOffset))

    -- Determine selected option based on cursor position
    if distanceToCursor < CONSTANTS.OUTER_RADIUS / zoom and distanceToCursor > CONSTANTS.INNER_RADIUS / zoom then
        state.selectedOption = clampOptionIndex(getOptionFromCursor(cursorRotation, #state.options), #state.options)
    elseif distanceToCursor <= CONSTANTS.INNER_RADIUS / zoom then
        state.selectedOption = 0
    end

    -- Draw all UI elements
    drawCenterElements(zoom)
    drawHeaderText(zoom)
    drawOptionBorders(zoom)
    drawUnselectedOptions(zoom)

    if distanceToCursor > CONSTANTS.INNER_RADIUS / zoom then
        drawSelectedOption(zoom)
    end

    drawCenterText(distanceToCursor, zoom)
end

function persona_feature_fastSelect.select()
    state.selectLocation = {0, 0}
    state.selectInitialCursorPosition = {0, 0}

    if state.selectedOption == 0 then
        state.options = {}
        return nil
    end
    if #state.options == 0 then
        persona_log.writeCustom("No options available to select in fast select menu.")
        return nil
    end

    if state.selectedOption > #state.options then
        persona_log.writeCustom("No valid option selected in fast select menu.")
        state.options = {}
        return nil
    end

    local selectedOption = state.options[state.selectedOption]
    state.options = {}
    return selectedOption
end

string.persona.feature.fastSelect = persona_feature_fastSelect
