---persona size statuseffect
---Author: Lonaasan
local oldSize = 1

function init()

end

function update(dt)

    local playerSize = status.statusProperty("personaSize", 1) or 1
    if playerSize ~= oldSize then
        oldSize = playerSize
        effect.setParentDirectives("?scalenearest=" .. tostring(playerSize))
    end
end

function uninit()

end
