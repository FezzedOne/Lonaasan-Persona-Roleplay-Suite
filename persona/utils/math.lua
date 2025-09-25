--- persona Math functions
--- Author: Lonaasan
string.persona = string.persona or {};
string.persona.math = string.persona.math or {};

persona_math = {}

--- atan2 implementation for Lua < 5.2
--- @param y number
--- @param x number
--- @return number
function persona_math.atan2(y, x)
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 then
        if y >= 0 then
            return math.atan(y / x) + math.pi
        else
            return math.atan(y / x) - math.pi
        end
    else -- x == 0
        if y > 0 then
            return math.pi / 2
        elseif y < 0 then
            return -math.pi / 2
        else
            return 0 -- undefined, return 0
        end
    end
end

--- Distance between two points
--- @param a table
--- @param b table
--- @return number
function persona_math.distance(a, b)
    local dx = b[1] - a[1]
    local dy = b[2] - a[2]
    return math.sqrt(dx * dx + dy * dy)
end

--- Angle from point a to point b
--- @param a table
--- @param b table
--- @return number
function persona_math.angleBetween(a, b)
    local dx = b[1] - a[1]
    local dy = b[2] - a[2]
    return persona_math.atan2(dy, dx)
end


--- Export the functions for 3rd parties to use without the possibility of changing the original code
string.persona.math = persona_math;