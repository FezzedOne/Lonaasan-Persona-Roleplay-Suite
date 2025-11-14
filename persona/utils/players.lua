---persona players utilities
---Author: Lonaasan
require '/persona/utils/localanimation.lua'
require '/persona/utils/math.lua'
require '/persona/utils/log.lua'

string.persona = string.persona or {};
string.persona.players = string.persona.players or {};

persona_players = {}

--- Get a list of all player entity IDs
---@return table entityIds
function persona_players.getAll()
    return world.players()
end

--- Get detailed info about a player by their entity Id
function persona_players.getInfo(entityId, zoom, client)
    local color = "white"

    local isExisting = world.entityExists(entityId)
    if not isExisting then
        persona_log.writeCustom("Entity with ID " .. entityId .. " does not exist.")
        return
    end

    if client == "Vanilla" or client == "Neon" or client == "OpenStarbound" or client == "XStarbound" then
        -------------- Basic entity info --------------
        local uuid = world.entityUniqueId(entityId)
        local name = world.entityName(entityId)
        local entityType = world.entityType(entityId)
        local typeName = world.entityTypeName(entityId)
        local species = world.entitySpecies(entityId)
        local gender = world.entityGender(entityId)
        local damageTeam = world.entityDamageTeam(entityId)
        local canDamage = world.entityCanDamage(entityId, player.id())
        local isAggressive = world.entityAggressive(entityId)

        -- Hold Items
        -- local handItem = world.entityHandItem(entityId, "left")
        -- local handItem2 = world.entityHandItem(entityId, "right")
        -- local handItemDescription = world.entityHandItemDescriptor(entityId, "left")
        -- local handItemDescription2 = world.entityHandItemDescriptor(entityId, "right")

        ----------- Advanced Info (needs entity table) -----------

        local isValidTarget
        local distanceToEntity
        local entityInSight

        if os.__entity then
            isValidTarget = os.__entity.isValidTarget(entityId)
            distanceToEntity = os.__entity.distanceToEntity(entityId)
            entityInSight = os.__entity.entityInSight(entityId)
        end

        ----------- Advanced Info (needs oSB) -----------
        -- local entity

        -- if client == "OpenStarbound" then
        --     if os.__entity and world.entity then
        --     entity = world.entity(entityId)
        --     -- local description = entity:description() or nil
        --     isInteractive = entity:isInteractive() or nil
        --     currency = entity:currency("money") or nil
        --     -- local handItemDescriptor = entity:handItemDescriptor("primary") or nil
        --     -- persona_log.writeCustom("%s", handItemDescriptor)
        --     end
        -- end


        local isInteractive = world.isEntityInteractive(entityId)
        local currency = world.entityCurrency(entityId, "money")

        -------------- Vectors --------------
        local pos = world.entityPosition(entityId)
        local velocity = world.entityVelocity(entityId)
        local mouthPos = world.entityMouthPosition(entityId)
        local health = world.entityHealth(entityId)

        -- Text --

        -- Build the debug text dynamically
        local debugLines = {}

        if uuid then
            table.insert(debugLines, "^shadow;UUID: ^" .. color .. ";" .. uuid .. "^reset;")
        end
        if name and name ~= "" then
            table.insert(debugLines, "^shadow;Name: ^" .. color .. ";" .. name .. "^reset;")
        end
        -- if description then
        --     table.insert(debugLines, "Description: ^" .. color .. ";" .. description .. "^reset;")
        -- end
        if entityType then
            table.insert(debugLines, "^shadow;Type: ^" .. color .. ";" .. entityType .. "^reset;")
        end
        if isValidTarget ~= nil then
            table.insert(debugLines, "^shadow;Is Valid Target: ^" .. (isValidTarget and "green" or "red") .. ";" ..
                tostring(isValidTarget) .. "^reset;")
        end
        if isInteractive ~= nil then
            table.insert(debugLines, "^shadow;Is Interactive: ^" .. (isInteractive and "green" or "red") .. ";" ..
                tostring(isInteractive) .. "^reset;")
        end
        if currency then
            table.insert(debugLines, "^shadow;Currency: ^" .. color .. ";" .. currency .. "^reset;")
        end
        -- if handItemDescriptor then
        --     table.insert(debugLines, "Hand Item Descriptor: ^" .. color .. ";" .. handItemDescriptor .. "^reset;")
        -- end
        if distanceToEntity then
            local distanceFromVector = persona_math.distance(mcontroller.position(), pos)
            local distanceClamped = string.format("%.2f", distanceFromVector)
            table.insert(debugLines, "^shadow;Distance to Entity: ^" .. color .. ";" .. distanceClamped .. "^reset;")
        end
        if entityInSight ~= nil then
            table.insert(debugLines, "^shadow;Entity in Sight: ^" .. (entityInSight and "green" or "red") .. ";" ..
                tostring(entityInSight) .. "^reset;")
        end
        if health ~= nil then
            local remainingHealth = health[1]
            local maxHealth = health[2]
            local remainingHealthClamped = string.format("%.2f", remainingHealth)
            local maxHealthClamped = string.format("%.2f", maxHealth)
            table.insert(debugLines, "^shadow;Health: ^" .. color .. ";" .. remainingHealthClamped .. " / " ..
                maxHealthClamped .. "^reset;")
        end
        if typeName and typeName ~= "" then
            table.insert(debugLines, "^shadow;Type Name: ^" .. color .. ";" .. typeName .. "^reset;")
        end
        if species and species ~= "" then
            table.insert(debugLines, "^shadow;Species: ^" .. color .. ";" .. species .. "^reset;")
        end
        if gender then
            table.insert(debugLines, "^shadow;Gender: ^" .. color .. ";" .. gender .. "^reset;")
        end
        if damageTeam and damageTeam.type then
            table.insert(debugLines, "^shadow;Damage Team: ^" .. color .. ";" .. damageTeam.type .. "^reset;")
        end
        if canDamage ~= nil then
            table.insert(debugLines, "^shadow;Can Damage: ^" .. (canDamage and "green" or "red") .. ";" ..
                tostring(canDamage) .. "^reset;")
        end
        if isAggressive ~= nil then
            table.insert(debugLines, "^shadow;Is Aggressive: ^" .. (isAggressive and "green" or "red") .. ";" ..
                tostring(isAggressive) .. "^reset;")
        end

        -- Join all lines into one text with line breaks
        local debugText = table.concat(debugLines, "\n")

        -- Drawing the info:

        if os.__localAnimator then
            -- Display a single debug text
            if #debugText > 0 then
                -- persona_localanimation.displayLine({pos[1] - 3, pos[2] + 3}, pos, "white")
                persona_localanimation.displayText({pos[1] - 0, pos[2] + 5}, debugText or "", 1 / zoom)
            end

            -- Velocity --
            if velocity ~= nil then
                local adjustedVelocity = {pos[1] + velocity[1], pos[2] + velocity[2]}
                persona_localanimation.displayLine(adjustedVelocity, pos, "blue")
            end

            -- Mouth --
            if mouthPos ~= nil then
                persona_localanimation.displayLine(mouthPos, pos, "red")
            end

            if client == "Neon" and entityType == 'player' then
                local aim, aim2 = neon.world.getPlayerAimPosition(entityId)

                local entityPos = world.entityPosition(entityId)
                local aimPos = {aim, aim2}

                persona_localanimation.displayLine(aimPos, entityPos, "cyan")
            end

            if (client == "OpenStarbound" or client == "XStarbound") and entityType == 'player' then
                local aimPos = world.entityAimPosition(entityId)
                local entityPos = world.entityPosition(entityId)

                persona_localanimation.displayLine(aimPos, entityPos, "cyan")
                persona_localanimation.displayText({aimPos[1], aimPos[2]}, "^shadow;" .. (name or ""), 1 / zoom)
            end
        end
    end

end

--- Get and display the portrait of a player by their entity Id
function persona_players.getPortrait(entityId, zoom)
    entityId = entityId or player.id()
    local playerPos = world.entityPosition(player.id())
    local entityPos = world.entityPosition(entityId)
    local portrait = world.entityPortrait(entityId, "full")
    local distance = persona_math.distance(playerPos, entityPos)

    if not portrait or entityId == player.id() then
        return
    end

    local radius = 20 / zoom

    local dx = entityPos[1] - playerPos[1]
    local dy = entityPos[2] - playerPos[2]
    local angle = persona_math.atan2(dy, dx)

    for i = 1, #portrait do
        local drawable = portrait[i]
        if os.__localAnimator then
            local px = radius * math.cos(angle)
            local py = radius * math.sin(angle)

            persona_localanimation.displayImage({px, py}, drawable.image, math.max(math.min((distance * 0.1), 1), 0.5) * 2 / zoom)
        end
    end
end

--- Export the functions for 3rd parties to use without the possibility of changing the original code
string.persona.players = persona_players;
