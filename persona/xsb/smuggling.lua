--- xStarbound smuggling handler for Persona ---
--- $persona/persona/xsb/smuggling.lua ---

-- FezzedOne: Must be required *inside* `init` to work properly!

function jsonPack(...)
    local packedArgs = table.pack(...)
    local argNum = packedArgs.n
    packedArgs.n = nil
    if argNum > 0 then
        local result = jarray(packedArgs)
        for i = 1, argNum do
            if packedArgs[i] == nil then result[i] = null end
        end
        return result
    else
        return jarray()
    end
end

function jsonUnpack(argArr, i)
    i = i or 1
    local argNum = jsize(argArr)
    if i <= argNum then return argArr[i], jsonUnpack(argArr, i + 1) end
end

if xsb then
    if localAnimator then
        message.setHandler("LonasaanPersona::LocalAnimator::callBinding", function(_, isLocal, bindingRef, args)
            if isLocal and type(bindingRef) == "string" and type(args) == "table" then
                local success, result = pcall(
                    function() return jsonPack(localAnimator[bindingRef](jsonUnpack(args))) end
                )
                if success then
                    return result
                else
                    sb.logError(
                        "[Lonasaan::Persona] Error thrown while attempting to invoke tech script function 'localAnimator.%s': %s",
                        bindingRef,
                        result
                    )
                    return jarray({})
                end
            else
                return jarray({})
            end
        end)
    end
    if tech then
        message.setHandler("LonasaanPersona::Tech::callBinding", function(_, isLocal, bindingRef, args)
            if isLocal and type(bindingRef) == "string" and type(args) == "table" then
                local success, result = pcall(function() return jsonPack(tech[bindingRef](jsonUnpack(args))) end)
                if success then
                    return result
                else
                    sb.logError(
                        "[Lonasaan::Persona] Error thrown while attempting to invoke tech script function 'tech.%s': %s",
                        bindingRef,
                        result
                    )
                    return jarray({})
                end
            else
                return jarray({})
            end
        end)
    end

    -- FezzedOne: The actual metatable magic used to emulate OpenStarbound smuggling behaviour.
    local localAnimatorMetatable = {
        __newindex = function(_, _, _) end,
        __index = function(_, key)
            local callbackKey = key
            if world.mainPlayer() ~= entity.id() then
                -- Needed to make sure local animator drawables are rendered correctly when controlling multiple players on xClient.
                return function(...) return nil end
            else
                return function(...)
                    local result = world
                        .sendEntityMessage(world.mainPlayer(), "LonasaanPersona::LocalAnimator::callBinding", callbackKey, jsonPack(...))
                        :result()
                    if result then return jsonUnpack(result) end
                end
            end
        end,
    }

    local localAnimatorTable = {}
    setmetatable(localAnimatorTable, localAnimatorMetatable)
    os.__localAnimator = localAnimatorTable

    local techMetatable = {
        __newindex = function(_, _, _) end,
        __index = function(_, key)
            local callbackKey = key
            return function(...)
                local result = world
                    .sendEntityMessage(entity and entity.id() or world.mainPlayer(), "LonasaanPersona::Tech::callBinding", callbackKey, jsonPack(...))
                    :result()
                if result then return jsonUnpack(result) end
            end
        end,
    }

    local techTable = {}
    setmetatable(techTable, techMetatable)
    os.__tech = techTable

    -- FezzedOne: Because on xSB, `entity` is available in the context where the smuggled entity bindings are used.
    os.__entity = entity

    -- FezzedOne: Ensures binds are passed only to the main player on xClient.
    input.rawBind = input.bind
    input.bind = function(...)
        if world.mainPlayer() == entity.id() then
            return input.rawBind(...)
        else
            return false
        end
    end
    input.bindHeld = input.bind

    input.rawBindDown = input.bindDown
    input.bindDown = function(...)
        if world.mainPlayer() == entity.id() then
            return input.rawBindDown(...)
        else
            return nil
        end
    end

    input.rawBindUp = input.bindUp
    input.bindUp = function(...)
        if world.mainPlayer() == entity.id() then
            return input.rawBindUp(...)
        else
            return nil
        end
    end
end
