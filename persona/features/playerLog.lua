---persona playerLog functions
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.playerLog = string.persona.feature.playerLog or {};

persona_feature_playerLog = {}

require '/scripts/vec2.lua'
require '/persona/utils/log.lua'

local playerTable = {}

--- Resets the playertable
function persona_feature_playerLog.reset()
    playerTable = {}
end

function persona_feature_playerLog.init()
    if os.__entity then
        local nearbyPlayers = world.entityQuery(mcontroller.position(), 50, {
            includedTypes = {"player"},
            order = "nearest"
        })
        local playersInSight = {}

        -- Check which players are currently in sight
        for _, playerId in ipairs(nearbyPlayers) do
            local entityInSight = os.__entity.entityInSight(playerId)
            if entityInSight then
                playersInSight[playerId] = true
            end
        end

        -- Log players who have entered
        for playerId, _ in pairs(playersInSight) do
            if not playerTable[playerId] then
                persona_log.writeCustom("*" .. world.entityName(playerId) .. " has entered your view*")
            end
            playerTable[playerId] = true
        end
    end
end

--- Update the playertable with nearby players
function persona_feature_playerLog.update()
    if os.__entity then
        local nearbyPlayers = world.entityQuery(mcontroller.position(), 50, {
            includedTypes = {"player"},
            order = "nearest"
        })

        local playersInSight = {}

        -- Check which players are currently in sight
        for _, playerId in ipairs(nearbyPlayers) do
            local entityInSight = os.__entity.entityInSight(playerId)
            if entityInSight then
                playersInSight[playerId] = true
            end
        end

        -- Log players who have entered
        for playerId, _ in pairs(playersInSight) do
            if not playerTable[playerId] then
                persona_log.writeCustom("*" .. world.entityName(playerId) .. " has entered your view*")
            end
            playerTable[playerId] = true
        end

        -- Log players who have left
        for playerId, _ in pairs(playerTable) do
            if not playersInSight[playerId] then
                persona_log.writeCustom("*" .. world.entityName(playerId) .. " has left your view*")
                playerTable[playerId] = nil
            end
        end
    end
end

function persona_feature_playerLog.uninit()
    for playerId, _ in pairs(playerTable) do
        persona_log.writeCustom("*" .. world.entityName(playerId) .. " has left your view*")
    end
end

string.persona.feature.playerLog = persona_feature_playerLog
