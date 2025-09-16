local _init = init or function()
end;
local _update = update or function()
end;
local _uninit = uninit or function()
end;

function init(...)

    os.__localAnimator = localAnimator -- Getting localAnimator to generic for module access
    return _init(...)
end

function update(...)

    _update(...)
end

function uninit(...)

    _uninit(...)
end
