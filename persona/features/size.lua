---persona size functions
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.size = string.persona.feature.size or {};

require "/persona/utils/math.lua"

persona_feature_size = {}

local playerSize = 1

--- Resizes the character to the size at the cursor position
function persona_feature_size.toCursor()
    local cursorPositionRelativeToPlayer = world.distance(player.aimPosition(), mcontroller.position())

    local size = math.abs(cursorPositionRelativeToPlayer[2]) / 5
    if size < 0.2 then size = 0.2 end
    if size > 6 then size = 6 end

    playerSize = size
    status.setStatusProperty("personaSize", size)
    mcontroller.controlParameters({
        standingPoly = persona_math.scalePoly({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, 0.65},
                                               {0.35, 1.22}, {-0.35, 1.22}, {-0.75, 0.65}}, size),
        crouchingPoly = persona_math.scalePoly({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, -1.0},
                                                {0.35, -0.5}, {-0.35, -0.5}, {-0.75, -1.0}}, size)
    })
    if os.__tech then
        os.__tech.setParentDirectives("?scalenearest=" .. tostring(size))
    end
end

function persona_feature_size.update()
    if playerSize ~= 1 then
        mcontroller.controlParameters({
        standingPoly = persona_math.scalePoly({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, 0.65},
                                               {0.35, 1.22}, {-0.35, 1.22}, {-0.75, 0.65}}, playerSize),
        crouchingPoly = persona_math.scalePoly({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, -1.0},
                                                {0.35, -0.5}, {-0.35, -0.5}, {-0.75, -1.0}}, playerSize)
    })
    end
end

function persona_feature_size.reset()
    playerSize = 1
    status.setStatusProperty("personaSize", 1)
    mcontroller.controlParameters({
        standingPoly = {{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, 0.65}, {0.35, 1.22},
                        {-0.35, 1.22}, {-0.75, 0.65}},
        crouchingPoly = {{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, -1.0}, {0.35, -0.5},
                         {-0.35, -0.5}, {-0.75, -1.0}}
    })
    if os.__tech then
        os.__tech.setParentDirectives("?scalenearest=1") -- Makes visual player image match the resize performed
    end
end

string.persona.feature.size = persona_feature_size
