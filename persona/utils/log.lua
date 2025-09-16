---persona client utilities
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.log = string.persona.log or {};

persona_log = {}

--- Write a custom message in the log
---@param message string
---@return string
function persona_log.writeCustom(message)
    sb.logInfo('Persona: ' .. message)
end

--- Export the functions for 3rd parties to use without the possibility of changing the original code
string.persona.log = persona_log;
