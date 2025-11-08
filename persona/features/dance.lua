---persona dance functions
---Author: Lonaasan & Degranon, integrated into persona
---https://ko-fi.com/degranon
---Original code: https://steamcommunity.com/sharedfiles/filedetails/?id=1253782150
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.dance = string.persona.feature.dance or {};

persona_feature_dance = {}

require '/scripts/vec2.lua'
require '/persona/utils/log.lua'
require '/persona/utils/localanimation.lua'

local vehicleUUID = ""
local vehicleRotation = 0
local vehicleFlipped = false

local state = "stand"

function persona_feature_dance.exit()
    -- If the player is lounging in a mech, despawn it for transformation reasons
    if player.isLounging() then
        local loungeId = player.loungingIn()
        local entityResponse = world.sendEntityMessage(loungeId, "restoreId")
        if entityResponse:finished() then
            local uuid = entityResponse:result()
            if uuid == vehicleUUID then
                world.sendEntityMessage(loungeId, "despawnMech")
            end
        end
    end
end

function persona_feature_dance.dance(dance)
    vehicleUUID = player.uniqueId() .. "emoteVehicle"
    -- If the player is already lounging in a mech, despawn it first
    if player.isLounging() then
        local loungeId = player.loungingIn()
        local entityResponse = world.sendEntityMessage(loungeId, "restoreId")
        if entityResponse:finished() then
            local uuid = entityResponse:result()
            if uuid == vehicleUUID then
                world.sendEntityMessage(loungeId, "despawnMech")
            end
        end
    end

    vehicleRotation = mcontroller.rotation()
    vehicleFlipped = mcontroller.facingDirection() < 0

    local vehicleId = spawnVehicle(dance, vehicleFlipped, vehicleRotation, state)
    if vehicleId then
        player.lounge(vehicleId)
    end
end

function spawnVehicle(dance, flipping, rotation, state)
    local position = world.entityPosition(player.id())

    return world.spawnVehicle("modularmech", position, {
        script = "/vehicles/persona/dancer.lua",
        cyclic = dance.cyclic,
        duration = dance.duration,
        steps = dance.steps,
        boundBox = {0, 0, 0, 0},
        uniqueID = vehicleUUID,
        animation = "/items/active/grapplinghooks/climbingrope/climbingrope.animation",
        flipped = flipping,
        rotation = rotation,
        animationCustom = {
            animatedParts = {
                parts = {
                    rope = {
                        properties = {
                            image = ""
                        }
                    },
                    emotes = {
                        properties = {
                            emoteSeatPosition = {0, 0},
                            transformationGroups = {"emoteRotation"}
                        }
                    }
                }
            },
            transformationGroups = {
                emoteRotation = {}
            }
        },
        movementSettings = {
            collisionPoly = {{0, 0}},
            gravityEnabled = false
        },
        loungePositions = {
            emoteSeat = {
                part = "emotes",
                partAnchor = "emoteSeatPosition",
                orientation = state,
                cameraFocus = false,
                dance = dance.name
            }
        }
    })
end

string.persona.feature.dance = persona_feature_dance;
