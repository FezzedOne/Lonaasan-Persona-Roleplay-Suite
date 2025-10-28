---persona local animation utilities
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.localanimation = string.persona.localanimation or {};

persona_localanimation = {}

function persona_localanimation.displayPortrait(pos, image, size, life, layer)
    if os.__localAnimator then
        os.__localAnimator.spawnParticle({
            type = "textured",
            image = image,

            fullbright = true,

            timeToLive = life or 0,
            layer = layer or "front",
            size = size or 16,
            color = {255, 255, 255},

            position = {pos[1], pos[2]},
            velocity = {0, 0},
            variance = {
                position = {0, 0}
            }
        })
    end
end

function persona_localanimation.displayImage(pos, image, size, color, layer)
    if os.__localAnimator then
        local drawable = {
            image = image,
            fullbright = true,
            position = pos,
            centered = true,
            scale = size or {1, 1},
            color = color or {255, 255, 255}
        }
        os.__localAnimator.addDrawable(drawable, layer or "ForegroundEntity+10")
    end
end

function persona_localanimation.displayText(pos, text, size)
    if os.__localAnimator then
        os.__localAnimator.spawnParticle({
            type = "text",
            fullbright = true,
            color = {255, 255, 255},
            layer = "front",
            collidesForeground = false,
            text = text or "",
            position = pos,
            size = (size or (2 / 3))
        })
    end
end

function persona_localanimation.displayLine(dest, origin, color, size, life)
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
string.persona.localanimation = persona_localanimation;
