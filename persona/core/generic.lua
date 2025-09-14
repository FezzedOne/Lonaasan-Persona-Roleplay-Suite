require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/persona/utils/client.lua"
require "/persona/features/sit.lua"

local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

local client = "unknown"

function init(...)
    --client = persona_client.getClient() owo

    _init(...)
end

function update(dt)
    -- persona_feature_sit.sit()

    _update(dt)
end

function uninit(...)

    _uninit(...)
end