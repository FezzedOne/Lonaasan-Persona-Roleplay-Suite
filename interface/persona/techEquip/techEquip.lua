--- Tech Loader interface
-- The tech loader notifies the player they haven't equipped the dash tech yet.
-- The interface should only be opened if the character does not have dash
-- equipped and the status property "wedittechLoaderIgnored" is not set.
--
-- LICENSE
-- This file falls under an MIT License, which is part of this project.
-- An online copy can be viewed via the following link:
-- https://github.com/Silverfeelin/Starbound-WEdit/blob/master/LICENSE
---persona tech equip interface
---Author: Lonaasan & Silverfeelin, integrated and expanded in persona
require "/scripts/vec2.lua"

local scrolled = false
local scrollDelay = 1

if not techEquip then
    techEquip = {}
end

function init()
    techEquip.scrollWidgets = config.getParameter("scrollWidgets", {})
    techEquip.scrollPositions = {}
    techEquip.scrollOffset = config.getParameter("scrollOffset", {0, 0})

    for _, v in ipairs(techEquip.scrollWidgets) do
        techEquip.scrollPositions[v] = widget.getPosition(v)
        widget.setPosition(v, vec2.add(techEquip.scrollPositions[v], techEquip.scrollOffset))
    end
end

function update(dt)
    if not scrolled then
        techEquip.scrollIn(dt)
    end
end

function techEquip.scrollIn(dt)
    scrollDelay = scrollDelay - dt
    if scrollDelay > 0 then
        return
    end

    techEquip.scrollOffset[2] = techEquip.scrollOffset[2] + 60 * dt

    if techEquip.scrollOffset[2] > 0 then
        techEquip.scrollOffset[2] = 0
        scrolled = true
    end

    for k, v in ipairs(techEquip.scrollWidgets) do
        widget.setPosition(v, vec2.add(techEquip.scrollPositions[v], techEquip.scrollOffset))
    end
end

function techEquip.head()
    player.makeTechAvailable("personahead")
    player.enableTech("personahead")
    player.equipTech("personahead")
    techEquip.dismiss()
end

function techEquip.body()
    player.makeTechAvailable("personabody")
    player.enableTech("personabody")
    player.equipTech("personabody")
    techEquip.dismiss()
end

function techEquip.legs()
    player.makeTechAvailable("personalegs")
    player.enableTech("personalegs")
    player.equipTech("personalegs")
    techEquip.dismiss()
end

function techEquip.dismiss()
    pane.dismiss()
end

function techEquip.ignore()
    status.setStatusProperty("personaIgnored", true)
    techEquip.dismiss()
end
