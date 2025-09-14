---persona rotate functions
---Author: Aisha Heartleigh
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.rotate = string.persona.feature.rotate or {};

persona_feature_rotate = {}

require '/scripts/vec2.lua'

--- Resets the player's rotation, so that they face right side up again.
function persona_feature_rotate.reset()
    mcontroller.setRotation(0)
end

--- Rotates the player, so that their head faces directly towards the cursor.
function persona_feature_rotate.atCursor()
    local cursorPositionRelativeToPlayer = world.distance(player.aimPosition(), mcontroller.position())
    local cursorRotation = vec2.angle(cursorPositionRelativeToPlayer)-(math.pi/2)

    mcontroller.setRotation(cursorRotation)

    -- /debug info
    sb.setLogMap("^##rot30,#6FF;[Persona] Rotate_AimAtCursor_Position", string.format("[ ^red;%.3f^reset;, ^cornflowerblue;%.3f ^reset;]", cursorPositionRelativeToPlayer[1], cursorPositionRelativeToPlayer[2]))
	sb.setLogMap("^##rot31,#6FF;[Persona] Rotate_AimAtCursor_Rotation", string.format("%.3f", cursorRotation))
end

string.persona.feature.rotate = persona_feature_rotate