---persona size functions
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.size = string.persona.feature.size or {};

require "/persona/utils/math.lua"
require '/persona/utils/localanimation.lua'

persona_feature_size = {}

local playerSize = 0

--- Resizes the character to the size at the cursor position
function persona_feature_size.toCursor(zoom, shift)
    local cursorPositionRelativeToPlayer = world.distance(player.aimPosition(), mcontroller.position())

    local size = math.abs(cursorPositionRelativeToPlayer[2]) / 5
    if size < 0.2 then
        size = 0.2
    end
    if size > 6 then
        size = 6
    end

    -- If shift is pressed, snap to 0.1 increments
    if shift then
        size = math.floor(size / 0.1 + 0.5) * 0.1 -- Round to nearest 0.1
    end

    playerSize = size
    status.setStatusProperty("personaSize", size)

    persona_localanimation.displayText(vec2.add(mcontroller.position(), {0, 28 / zoom}),
        string.format("^shadow;Size: %.2f^reset;", playerSize), 1.5 / zoom)
end

function persona_feature_size.update()
    local effects = status.activeUniqueStatusEffectSummary()
    if playerSize == 0 then
        playerSize = status.statusProperty("personaSize", 1)
    end
    if playerSize ~= 1 then
        if not effects["personaSize"] then
            status.addEphemeralEffect("personaSize", math.huge)
        end
        mcontroller.controlParameters({
            standingPoly = persona_math.scalePoly({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0},
                                                   {0.75, 0.65}, {0.35, 1.22}, {-0.35, 1.22}, {-0.75, 0.65}}, playerSize),
            crouchingPoly = persona_math.scalePoly({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0},
                                                    {0.75, -1.0}, {0.35, -0.5}, {-0.35, -0.5}, {-0.75, -1.0}},
                playerSize)
        })
    else
        if effects["personaSize"] then
            status.removeEphemeralEffect("personaSize") -- remove it here too if u are normal sized
        end
    end
end

function persona_feature_size.reset()
    if effects["personaSize"] then
        status.removeEphemeralEffect("personaSize")
    end
    playerSize = status.setStatusProperty("personaSize", 1)
    mcontroller.controlParameters({
        standingPoly = {{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, 0.65}, {0.35, 1.22},
                        {-0.35, 1.22}, {-0.75, 0.65}},
        crouchingPoly = {{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, -1.0}, {0.35, -0.5},
                         {-0.35, -0.5}, {-0.75, -1.0}}
    })
end

function persona_feature_size.uninit()
    if effects["personaSize"] then
        status.removeEphemeralEffect("personaSize")
    end
    mcontroller.controlParameters({
        standingPoly = {{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, 0.65}, {0.35, 1.22},
                        {-0.35, 1.22}, {-0.75, 0.65}},
        crouchingPoly = {{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, -1.0}, {0.35, -0.5},
                         {-0.35, -0.5}, {-0.75, -1.0}}
    })
end

string.persona.feature.size = persona_feature_size
