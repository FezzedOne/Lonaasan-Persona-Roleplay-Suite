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

    if distanceToCursor < 25.5 / zoom and distanceToCursor > 0.5 / zoom then
        fastSelectOption = math.floor((cursorRotation / (math.pi * 2)) * #storedOptions) + 1
    end
    
    -- Ensure fastSelectOption is within valid range
    if fastSelectOption > #storedOptions then
        fastSelectOption = 1
    end


    -- show the center image relative to (player - select location)
    persona_localanimation.displayImage(world.distance(fastSelectLocation, mcontroller.position()),
        "/celestial/system/terrestrial/biomes/midnight/maskie2.png", 0.8 / zoom, {255, 255, 255, 200})
    persona_localanimation.displayImage(world.distance(fastSelectLocation, mcontroller.position()),
        "/celestial/system/gas_giant/shadows/0.png", 0.8 / zoom)


        --"/celestial/system/gas_giant/shadows/0.png", "/cinematics/crazyring.png", "/celestial/system/terrestrial/biomes/midnight/maskie2.png"

    persona_localanimation.displayText(vec2.add(fastSelectLocation, {0, 28 / zoom}),
        "^shadow;FastSelect " .. storedOptions[fastSelectOption] .. "^reset;" or "", 1.5 / zoom)

    -- Draw the border lines inbetween options based on option count

    for i = 0, #storedOptions - 1 do
        local angle = (i / #storedOptions) * (math.pi * 2)
        local lineEnd = vec2.add(fastSelectLocation,
            vec2.mul(vec2.norm({math.cos(angle), math.sin(angle)}), 25.5 / zoom))
        persona_localanimation.displayLine(fastSelectLocation, lineEnd, "gray", 1.0 / zoom)
    end

    -- Draw unselected option texts
    for i = 1, #storedOptions do
        if i ~= fastSelectOption then
            local textAngle = (((i - 1) + 0.5) / #storedOptions) * (math.pi * 2)
            local textPosition = vec2.add(fastSelectLocation,
                vec2.mul(vec2.norm({math.cos(textAngle), math.sin(textAngle)}), 17 / zoom))
            persona_localanimation.displayText(textPosition,
                storedOptions[i] or "", 1.0 / zoom)
        end
    end


    -- draw the borders around the selected option in bold and red
    local selectedAngleStart = ((fastSelectOption - 1) / #storedOptions) * (math.pi * 2)
    local selectedAngleEnd = (fastSelectOption / #storedOptions) * (math.pi * 2)

    local startPoint = vec2.add(fastSelectLocation, vec2.mul(vec2.norm({math.cos(selectedAngleStart), math.sin(selectedAngleStart)}), 25.5 / zoom))
    local endPoint = vec2.add(fastSelectLocation, vec2.mul(vec2.norm({math.cos(selectedAngleEnd), math.sin(selectedAngleEnd)}), 25.5 / zoom))

    persona_localanimation.displayLine(fastSelectLocation, startPoint, "red", 2.0 / zoom)
    persona_localanimation.displayLine(fastSelectLocation, endPoint, "red", 2.0 / zoom)

    -- draw the selected option text in bold and red
    local selectedTextAngle = (((fastSelectOption - 1) + 0.5) / #storedOptions) * (math.pi * 2)
    local selectedTextPosition = vec2.add(fastSelectLocation,
        vec2.mul(vec2.norm({math.cos(selectedTextAngle), math.sin(selectedTextAngle)}), 17 / zoom))
    persona_localanimation.displayText(selectedTextPosition,
        "^red;" .. storedOptions[fastSelectOption] .. "^reset;", 1.2 / zoom)
end


function persona_feature_fastSelect.select()
    fastSelectLocation = {0, 0}
    sb.logInfo("Selected option " .. storedOptions[fastSelectOption] .. " in fast select menu.")
    local selectedOption = storedOptions[fastSelectOption]
    storedOptions = {}
    return selectedOption

end

string.persona.feature.fastSelect = persona_feature_fastSelect
