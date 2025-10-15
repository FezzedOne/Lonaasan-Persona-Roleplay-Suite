---persona position functions
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.position = string.persona.feature.position or {};

persona_feature_position = {}

local stickyTarget = nil
local stickyOffset = {0, 0}

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
        mcontroller.setPosition(vec2.add(targetPos, stickyOffset))
        mcontroller.setVelocity({0, 0})
    else
        stickyTarget = nil
        stickyOffset = {0, 0}
    end
end

function persona_feature_position.reset()
    stickyTarget = nil
    stickyOffset = {0, 0}
end

string.persona.feature.position = persona_feature_position
