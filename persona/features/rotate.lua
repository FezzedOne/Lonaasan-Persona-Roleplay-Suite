---persona rotate functions
---Author: Aisha Heartleigh
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.rotate = string.persona.feature.rotate or {};

persona_feature_rotate = {}

require '/scripts/vec2.lua'
require '/persona/utils/localanimation.lua'

--- Resets the player's rotation, so that they face right side up again.
function persona_feature_rotate.reset()
    mcontroller.setRotation(0)
end

--- Rotates the player, so that their head faces directly towards the cursor.
function persona_feature_rotate.atCursor(zoom, shift)
    local cursorPositionRelativeToPlayer = world.distance(player.aimPosition(), mcontroller.position())
    local cursorRotation = vec2.angle(cursorPositionRelativeToPlayer) - (math.pi / 2)

    -- If shift is pressed, snap to 10-degree increments
    if shift then
        local degrees = math.deg(cursorRotation)
        degrees = math.floor(degrees / 10 + 0.5) * 10 -- Round to nearest 10 degrees
        cursorRotation = math.rad(degrees)
    end

    mcontroller.setRotation(cursorRotation)

    persona_localanimation.displayText(vec2.add(mcontroller.position(), {0, 28 / zoom}),
        string.format("^shadow;Rotation: %.1f^reset;", math.deg(cursorRotation)), 1.5 / zoom)

    -- /debug info
    sb.setLogMap("^##rot30,#6FF;[Persona] Rotate_AimAtCursor_Position",
        string.format("[ ^red;%.3f^reset;, ^cornflowerblue;%.3f ^reset;]", cursorPositionRelativeToPlayer[1],
            cursorPositionRelativeToPlayer[2]))
    sb.setLogMap("^##rot31,#6FF;[Persona] Rotate_AimAtCursor_Rotation", string.format("%.3f", cursorRotation))
end

--- lerp towards rotationGoal (not implemented yet)
--- @param float rotationGoal
--- @param float ratio
function persona_feature_rotate.Approach(rotationGoal, ratio)
    local currentRotation = mcontroller.rotation()

    local newRotation = currentRotation + ((rotationGoal - currentRotation) * ratio)
    newRotation = newRotation + (newRotation < 0 and -0.7 or 0.7) -- speed up for the last few degrees

    if math.abs(newRotation - rotationGoal) < 2 then
        newRotation = rotationGoal
    end

    mcontroller.setRotation(newRotation)
end

string.persona.feature.rotate = persona_feature_rotate
