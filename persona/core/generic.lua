require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/persona/utils/client.lua"

local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

local client = persona_client.getClient()

function init(...)

    _init(...)
end

function update(dt)


    if os.__tech then -- Check if tech is equipped
        os.__tech.setParentState("Duck");
    end

    _update(dt)
end

function uninit(...)

    _uninit(...)
end