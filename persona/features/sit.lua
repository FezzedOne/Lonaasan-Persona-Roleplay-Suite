---persona sit functions
---Author: Cirup
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.sit = string.persona.feature.sit or {};

persona_feature_sit = {}

---Some description of the function
---@return boolean
function persona_feature_sit.sit()
	local tech
	if os.__tech then tech = os.__tech else return end

  os.__tech.setParentState("Sit")
end

string.persona.feature.sit = persona_feature_sit