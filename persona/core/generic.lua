require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/persona/utils/client.lua"
require "/persona/features/rotate.lua"

local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

local client = "unknown"

function init(...)
    client = persona_client.getClient()

    _init(...)
end

function update(dt)
    if input.bindDown("persona", "rotateReset") then persona_feature_rotate.reset() end
    if input.bind("persona", "rotateAtCursor") then persona_feature_rotate.atCursor() end

    _update(dt)
end

function uninit(...)

    _uninit(...)
end