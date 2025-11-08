---persona position functions
---Author: Lonaasan & Aisha Heartleigh
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.position = string.persona.feature.position or {};

persona_feature_position = {}

local stickyTarget = nil
local stickyOffset = {0, 0}
local altControlsEnabled = false
local colEnabled = true

--- Sticks the player to the nearest entity (NPC, monster, player, etc.)
function persona_feature_position.stickToEntity()
    if not stickyTarget then
        stickyTarget = world.entityQuery(mcontroller.position(), 5, {
            includedTypes = {"npc", "monster", "player"},
            order = "nearest"
        })[2] -- [1] is self
        if stickyTarget then
            stickyOffset = vec2.sub(mcontroller.position(), world.entityPosition(stickyTarget))
        else
            return
        end
    end
    if not world.entityExists(stickyTarget) then
        stickyTarget = nil
        stickyOffset = {0, 0}
        return
    end
    local targetPos = world.entityPosition(stickyTarget)
    if targetPos then
        -- move offset through arrow keys
        local moveBinds = root.getConfigurationPath("bindings") -- finds your binds!
        local movement = {(input.keyHeld(moveBinds.PlayerLeft[1].value) and -0.05) or
            (input.keyHeld(moveBinds.PlayerRight[1].value) and 0.05) or 0,
                          (input.keyHeld(moveBinds.PlayerDown[1].value) and -0.05) or
            (input.keyHeld(moveBinds.PlayerUp[1].value) and 0.05) or 0}
        stickyOffset = vec2.add(stickyOffset, movement)

        -- move offset through mouse
        if input.mouseHeld("MouseMiddle") then
            stickyOffset = vec2.lerp(0.01, stickyOffset,
                world.distance(player.aimPosition(), world.entityPosition(stickyTarget)))
        end

        mcontroller.setPosition(vec2.add(targetPos, stickyOffset))
        mcontroller.controlApproachVelocity({0, 0}, 1e+6)
    else
        stickyTarget = nil
        stickyOffset = {0, 0}
    end
end

function persona_feature_position.flight(shift, alt)

    mcontroller.controlParameters({
        gravityEnabled = false
    })

    if alt then
        altControlsEnabled = not altControlsEnabled
    end

    if shift then
        colEnabled = not colEnabled
    end

    if altControlsEnabled then
        mcontroller.controlApproachVelocity(vec2.mul(world.distance(player.aimPosition(), mcontroller.position()), 8),
            300)
    else
        local moveBinds = root.getConfigurationPath("bindings") -- finds your binds!
        local movement = {(input.keyHeld(moveBinds.PlayerLeft[1].value) and -0.05) or
            (input.keyHeld(moveBinds.PlayerRight[1].value) and 0.05) or 0,
                          (input.keyHeld(moveBinds.PlayerDown[1].value) and -0.05) or
            (input.keyHeld(moveBinds.PlayerUp[1].value) and 0.05) or 0}

        mcontroller.controlApproachVelocity(vec2.mul(movement, 60), 300)
    end

    if not colEnabled then
        mcontroller.controlParameters({
            collisionEnabled = false
        }) -- phase through walls
    end
end

function persona_feature_position.reset()
    stickyTarget = nil
    stickyOffset = {0, 0}
end

string.persona.feature.position = persona_feature_position
