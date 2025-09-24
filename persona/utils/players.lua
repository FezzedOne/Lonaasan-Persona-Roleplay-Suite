---persona players utilities
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.players = string.persona.players or {};

persona_players = {}

--- Get a list of all player entity IDs
---@return table entityIds
function persona_players.getAll()
    return world.players()
end

--- Get detailed info about a player by their entity I
function persona_players.getInfo(entityId, zoom, client)
    local color = "white"

    local isExisting = world.entityExists(entityId)
    if not isExisting then
        sb.logInfo("Entity with ID " .. entityId .. " does not exist.")
        return
    end

    if client == "Vanilla" or client == "Neon" or client == "OpenStarbound" then
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

        local isValidTarget
        local distanceToEntity
        local entityInSight

        ----------- Advanced Info (needs entity table) -----------
        if os.__entity then
            isValidTarget = os.__entity.isValidTarget(entityId)
            distanceToEntity = os.__entity.distanceToEntity(entityId)
            entityInSight = os.__entity.entityInSight(entityId)
        end

        ----------- Advanced Info (needs oSB) -----------
        local entity
        local isInteractive
        local currency

        if client == "OpenStarbound" then
            entity = world.entity(entityId)
            -- local description = entity:description() or nil
            isInteractive = entity:isInteractive() or nil
            currency = entity:currency("money") or nil
            -- local handItemDescriptor = entity:handItemDescriptor("primary") or nil

            -- sb.logInfo("%s", handItemDescriptor)
        end

        -------------- Vectors --------------
        local pos = world.entityPosition(entityId)
        local velocity = world.entityVelocity(entityId)
        local mouthPos = world.entityMouthPosition(entityId)
        local health = world.entityHealth(entityId)

        -- Text --

        -- Build the debug text dynamically
        local debugLines = {}

        if uuid then
            table.insert(debugLines, "UUID: ^" .. color .. ";" .. uuid .. "^reset;")
        end
        if name and name ~= "" then
            table.insert(debugLines, "Name: ^" .. color .. ";" .. name .. "^reset;")
        end
        -- if description then
        --     table.insert(debugLines, "Description: ^" .. color .. ";" .. description .. "^reset;")
        -- end
        if entityType then
            table.insert(debugLines, "Type: ^" .. color .. ";" .. entityType .. "^reset;")
        end
        if isValidTarget ~= nil then
            table.insert(debugLines, "Is Valid Target: ^" .. (isValidTarget and "green" or "red") .. ";" ..
                tostring(isValidTarget) .. "^reset;")
        end
        if isInteractive ~= nil then
            table.insert(debugLines, "Is Interactive: ^" .. (isInteractive and "green" or "red") .. ";" ..
                tostring(isInteractive) .. "^reset;")
        end
        if currency then
            table.insert(debugLines, "Currency: ^" .. color .. ";" .. currency .. "^reset;")
        end
        -- if handItemDescriptor then
        --     table.insert(debugLines, "Hand Item Descriptor: ^" .. color .. ";" .. handItemDescriptor .. "^reset;")
        -- end
        if distanceToEntity then
            local distanceFromVector = math.sqrt(distanceToEntity[1] * distanceToEntity[1] + distanceToEntity[2] *
                                                     distanceToEntity[2])
            local distanceClamped = string.format("%.2f", distanceFromVector)
            table.insert(debugLines, "Distance to Entity: ^" .. color .. ";" .. distanceClamped .. "^reset;")
        end
        if entityInSight ~= nil then
            table.insert(debugLines, "Entity in Sight: ^" .. (entityInSight and "green" or "red") .. ";" ..
                tostring(entityInSight) .. "^reset;")
        end
        if health ~= nil then
            local remainingHealth = health[1]
            local maxHealth = health[2]
            local remainingHealthClamped = string.format("%.2f", remainingHealth)
            local maxHealthClamped = string.format("%.2f", maxHealth)
            table.insert(debugLines,
                "Health: ^" .. color .. ";" .. remainingHealthClamped .. " / " .. maxHealthClamped .. "^reset;")
        end
        if typeName and typeName ~= "" then
            table.insert(debugLines, "Type Name: ^" .. color .. ";" .. typeName .. "^reset;")
        end
        if species and species ~= "" then
            table.insert(debugLines, "Species: ^" .. color .. ";" .. species .. "^reset;")
        end
        if gender then
            table.insert(debugLines, "Gender: ^" .. color .. ";" .. gender .. "^reset;")
        end
        if damageTeam and damageTeam.type then
            table.insert(debugLines, "Damage Team: ^" .. color .. ";" .. damageTeam.type .. "^reset;")
        end
        if canDamage ~= nil then
            table.insert(debugLines,
                "Can Damage: ^" .. (canDamage and "green" or "red") .. ";" .. tostring(canDamage) .. "^reset;")
        end
        if isAggressive ~= nil then
            table.insert(debugLines, "Is Aggressive: ^" .. (isAggressive and "green" or "red") .. ";" ..
                tostring(isAggressive) .. "^reset;")
        end

        -- Join all lines into one text with line breaks
        local debugText = table.concat(debugLines, "\n")

        -- Drawing the info:

        if os.__localAnimator then
            -- Display a single debug text
            if #debugText > 0 then
                DisplayLine({pos[1] - 3, pos[2] + 3}, pos, "white")

                os.__localAnimator.spawnParticle({
                    type = "text",
                    fullbright = true,
                    color = {255, 255, 255},
                    layer = "front",
                    collidesForeground = false,
                    text = debugText or "",
                    position = {pos[1] - 0, pos[2] + 5},
                    size = 1 / zoom
                })
            end

            -- Velocity --
            if velocity ~= nil then
                local adjustedVelocity = {pos[1] + velocity[1], pos[2] + velocity[2]}
                DisplayLine(adjustedVelocity, pos, "blue")
            end

            -- Mouth --
            if mouthPos ~= nil then
                DisplayLine(mouthPos, pos, "red")
            end

            if client == "Neon" and entityType == 'player' then
                local aim, aim2 = neon.world.getPlayerAimPosition(entityId)

                local entityPos = world.entityPosition(entityId)
                local aimPos = {aim, aim2}

                -- Draw a line from the entity to the aim position
                DisplayLine(aimPos, entityPos, "cyan")
            end

            if client == "OpenStarbound" and entityType == 'player' then
                local aimPos = world.entityAimPosition(entityId)
                local entityPos = world.entityPosition(entityId)

                -- Draw a line from the entity to the aim position
                DisplayLine(aimPos, entityPos, "cyan")
                os.__localAnimator.spawnParticle({
                    type = "text",
                    fullbright = true,
                    color = {255, 255, 255},
                    layer = "front",
                    collidesForeground = false,
                    text = name or "",
                    position = {aimPos[1], aimPos[2]},
                    size = 1 / zoom
                })
            end
        end
    end

end

function persona_players.getPortrait(entityId, zoom)
    entityId = entityId or player.id()
    local playerPos = world.entityPosition(player.id())
    local entityPos = world.entityPosition(entityId)
    local playerstate = player.currentState()
    local dir = mcontroller.facingDirection()
    local portrait = world.entityPortrait(entityId, "full")

    if not portrait then
        return
    end

    -- Calculate angle using basic trigonometry
    local dx = entityPos[1] - playerPos[1]
    local dy = entityPos[2] - playerPos[2]
    
    -- Handle special cases for vertical/horizontal alignment
    local angle
    if dx == 0 then
        angle = dy > 0 and math.pi/2 or -math.pi/2
    elseif dy == 0 then
        angle = dx > 0 and 0 or math.pi
    else
        -- Use arctangent approximation
        local abs_dx = math.abs(dx)
        local abs_dy = math.abs(dy)
        local ratio = abs_dy/abs_dx
        
        -- Calculate base angle (between 0 and pi/4)
        local base_angle = ratio < 1 and math.asin(ratio) or math.acos(1/ratio)
        
        -- Adjust angle based on quadrant
        if dx > 0 and dy >= 0 then
            angle = base_angle
        elseif dx <= 0 and dy > 0 then
            angle = math.pi - base_angle
        elseif dx < 0 and dy <= 0 then
            angle = math.pi + base_angle
        else
            angle = 2*math.pi - base_angle
        end
    end
    
    -- Constants for circle positioning
    local radius = 30 / zoom

    local totalLayers = #portrait

    for i = 1, totalLayers do
        local drawable = portrait[i]
        if os.__localAnimator then
            -- Calculate position on circle
            local circleX = math.cos(angle) * radius
            local circleY = math.sin(angle) * radius
            
            -- Create drawable with new position
            local finishedDrawable = {
                image = drawable.image,
                fullbright = true,
                position = {circleX, circleY},
                centered = true
            }
            
            -- Add to animator
            os.__localAnimator.addDrawable(finishedDrawable, "ForegroundEntity+10")
        end
    end
end

function DisplayLine(dest, origin, color, size, life)
    if os.__localAnimator then
        os.__localAnimator.spawnParticle({
            type = "streak",
            length = world.magnitude(dest, origin) * 8,

            fullbright = true,

            timeToLive = life or 0,
            layer = "front",
            size = (size or (2 / 3)),
            color = color or {255, 255, 255},

            position = vec2.add(world.distance(origin, dest), dest),
            velocity = vec2.div(world.distance(origin, dest), 2000),
            variance = {
                length = 0
            }
        })
    end
end

--- Export the functions for 3rd parties to use without the possibility of changing the original code
string.persona.players = persona_players;
