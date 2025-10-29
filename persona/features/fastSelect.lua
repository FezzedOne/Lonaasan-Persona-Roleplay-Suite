---persona fastSelect functions
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.fastSelect = string.persona.feature.fastSelect or {};

persona_feature_fastSelect = {}

require '/scripts/vec2.lua'
require '/persona/utils/log.lua'
require '/persona/utils/localanimation.lua'

local fastSelectLocation = {0, 0}
local fastSelectOption = 1
local storedOptions = {}

function persona_feature_fastSelect.show(options, zoom)
    storedOptions = options or {}
    if fastSelectLocation[1] == 0 and fastSelectLocation[2] == 0 then
        fastSelectLocation = player.aimPosition()
    end
    local cursorPositionRelativeToStart = world.distance(player.aimPosition(), fastSelectLocation)
    local distanceToCursor = vec2.mag(cursorPositionRelativeToStart)

    local cursorRotation = vec2.angle(cursorPositionRelativeToStart)
    -- Normalize the angle to 0-2π range
    if cursorRotation < 0 then
        cursorRotation = cursorRotation + (math.pi * 2)
    end

    if distanceToCursor < 16 / zoom and distanceToCursor > 4.85 / zoom then
        fastSelectOption = math.floor((cursorRotation / (math.pi * 2)) * #storedOptions) + 1
    end
    if distanceToCursor <= 4.85 / zoom then
        fastSelectOption = 0
    end

    -- Ensure fastSelectOption is within valid range
    if fastSelectOption > #storedOptions then
        fastSelectOption = 1
    end

    -- show the center image relative to (player - select location)
    persona_localanimation.displayImage(world.distance(fastSelectLocation, mcontroller.position()),
        "/celestial/system/terrestrial/biomes/midnight/maskie2.png", 0.5 / zoom, {255, 255, 255, 200})
    persona_localanimation.displayImage(world.distance(fastSelectLocation, mcontroller.position()),
        "/celestial/system/gas_giant/shadows/0.png", 0.5 / zoom)

    -- "/celestial/system/gas_giant/shadows/0.png", "/cinematics/crazyring.png", "/celestial/system/terrestrial/biomes/midnight/maskie2.png"

    local fastSelectText = "back"
    if fastSelectOption > 0 then
        fastSelectText = storedOptions[fastSelectOption] or ""
    end

    persona_localanimation.displayText(vec2.add(fastSelectLocation, {0, 17.5 / zoom}),
        "^shadow;FastSelect " .. fastSelectText .. "^reset;" or "", 1.25 / zoom)

    -- Draw the border lines inbetween options based on option count
    -- start 4.85 / zoom away from center

    for i = 0, #storedOptions - 1 do
        local angle = (i / #storedOptions) * (math.pi * 2)
        local lineEnd = vec2.add(fastSelectLocation, vec2.mul(vec2.norm({math.cos(angle), math.sin(angle)}), 16 / zoom))
        local lineStart = vec2.add(fastSelectLocation,
            vec2.mul(vec2.norm({math.cos(angle), math.sin(angle)}), 4.85 / zoom))
        persona_localanimation.displayLine(lineStart, lineEnd, "gray", 1.0 / zoom)
    end

    -- Draw unselected option texts
    for i = 1, #storedOptions do
        if i ~= fastSelectOption then
            local textAngle = (((i - 1) + 0.5) / #storedOptions) * (math.pi * 2)
            local textPosition = vec2.add(fastSelectLocation,
                vec2.mul(vec2.norm({math.cos(textAngle), math.sin(textAngle)}), 10.7 / zoom))
            persona_localanimation.displayText(textPosition, storedOptions[i] or "", 1.0 / zoom)
        end
    end

    if distanceToCursor > 4.85 / zoom then
        -- draw the borders around the selected option in bold and red
        local selectedAngleStart = ((fastSelectOption - 1) / #storedOptions) * (math.pi * 2)
        local selectedAngleEnd = (fastSelectOption / #storedOptions) * (math.pi * 2)
        -- start 4.85 / zoom away from center
        local innerStartPoint = vec2.add(fastSelectLocation, vec2.mul(
            vec2.norm({math.cos(selectedAngleStart), math.sin(selectedAngleStart)}), 4.85 / zoom))
        local innerEndPoint = vec2.add(fastSelectLocation, vec2.mul(
            vec2.norm({math.cos(selectedAngleEnd), math.sin(selectedAngleEnd)}), 4.85 / zoom))

        local startPoint = vec2.add(fastSelectLocation, vec2.mul(
            vec2.norm({math.cos(selectedAngleStart), math.sin(selectedAngleStart)}), 16 / zoom))
        local endPoint = vec2.add(fastSelectLocation, vec2.mul(
            vec2.norm({math.cos(selectedAngleEnd), math.sin(selectedAngleEnd)}), 16 / zoom))

        persona_localanimation.displayLine(innerStartPoint, startPoint, "red", 2.0 / zoom)
        persona_localanimation.displayLine(innerEndPoint, endPoint, "red", 2.0 / zoom)

        -- draw the selected option text in bold and red
        local selectedTextAngle = (((fastSelectOption - 1) + 0.5) / #storedOptions) * (math.pi * 2)
        local selectedTextPosition = vec2.add(fastSelectLocation, vec2.mul(
            vec2.norm({math.cos(selectedTextAngle), math.sin(selectedTextAngle)}), 10.7 / zoom))
        persona_localanimation.displayText(selectedTextPosition,
            "^red;" .. storedOptions[fastSelectOption] .. "^reset;", 1.2 / zoom)
        persona_localanimation.displayText(fastSelectLocation, "back", 1.0 / zoom)

    else
        persona_localanimation.displayText(fastSelectLocation,
            "^red;back^reset;", 1.2 / zoom)
    end
            persona_localanimation.displayImage(world.distance(fastSelectLocation, mcontroller.position()),
        "/celestial/system/terrestrial/biomes/midnight/maskie1.png", 0.145 / zoom)
            persona_localanimation.displayImage(world.distance(fastSelectLocation, mcontroller.position()),
            "/celestial/system/gas_giant/shadows/0.png", 0.15 / zoom)

end

function persona_feature_fastSelect.select()
    fastSelectLocation = {0, 0}
    if fastSelectOption == 0 then
        sb.logInfo("Exited fast select menu without selecting an option.")
        storedOptions = {}
        return nil
    end
    sb.logInfo("Selected option " .. storedOptions[fastSelectOption] .. " in fast select menu.")
    local selectedOption = storedOptions[fastSelectOption]
    storedOptions = {}
    return selectedOption

end

string.persona.feature.fastSelect = persona_feature_fastSelect
