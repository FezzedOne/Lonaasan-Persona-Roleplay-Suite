---persona players utilities
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.players = string.persona.players or {};

persona_players = {}

--- Get a list of all player entity IDs
---@return table entityIds
function persona_players.getAll()
    return world.players()
end

--- Export the functions for 3rd parties to use without the possibility of changing the original code
string.persona.players = persona_players;
