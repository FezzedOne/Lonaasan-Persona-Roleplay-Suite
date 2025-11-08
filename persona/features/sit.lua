---persona sit functions
---Author: Aisha Heartleigh
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.sit = string.persona.feature.sit or {};

persona_feature_sit = {}

local testActive = false

---Some description of the function
---@return boolean
function persona_feature_sit.sit()

    if input.bindDown("persona", "test") then
        testActive = not testActive
    end

    if testActive then
    end
end

string.persona.feature.sit = persona_feature_sit
