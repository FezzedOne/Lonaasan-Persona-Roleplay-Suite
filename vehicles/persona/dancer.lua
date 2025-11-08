---persona dancer vehicle
---Author: Lonaasan & Degranon, integrated into persona
---https://ko-fi.com/degranon
---Original code: https://steamcommunity.com/sharedfiles/filedetails/?id=1253782150

local currentrotation = 0

function init()
    self.started = false
    self.seatName = "emoteSeat"
    self.cyclic = config.getParameter("cyclic")
    self.duration = config.getParameter("duration")
    self.steps = config.getParameter("steps")
    animator.setFlipped(config.getParameter("flipped", false))
    self.uuid = config.getParameter("uniqueID")
    vehicle.setLoungeEnabled("seat", false)
    self.timer = 0

    if animator.hasTransformationGroup("emoteRotation") then
        local rotation = config.getParameter("rotation", 0)
        if config.getParameter("flipped", false) then
            rotation = -rotation
        end

        currentrotation = rotation
        animator.rotateTransformationGroup("emoteRotation", rotation)
    end

    message.setHandler("restoreId", function()
        return self.uuid
    end)
    message.setHandler("despawnMech", function()
        despawn()
    end)
end

function update(dt)
    if vehicle.entityLoungingIn(self.seatName) then
        self.started = true
    end

    if vehicle.controlHeld(self.seatName, "left") or vehicle.controlHeld(self.seatName, "right") or
        vehicle.controlHeld(self.seatName, "up") or vehicle.controlHeld(self.seatName, "down") or
        vehicle.controlHeld(self.seatName, "jump") then
        despawn()
    end

    if not self.started and not vehicle.entityLoungingIn(self.seatName) then
        despawn()
    end

    if self.started and not self.cyclic then
        self.timer = self.timer + dt
        if self.timer > self.duration then
            despawn()
        end
    end
end

function despawn()
    vehicle.setInteractive(false)
    vehicle.destroy()
end
