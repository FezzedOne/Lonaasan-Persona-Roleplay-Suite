local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

function init()
    os.__tech = tech -- Getting tech to generic for module access
    _init()
end

function update(dt)

    _update(dt)
end

function uninit()

    _uninit()
end