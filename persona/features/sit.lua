---persona sit functions
---Author: Aisha Heartleigh
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.sit = string.persona.feature.sit or {};

persona_feature_sit = {}

local tech
if os.__tech then tech = os.__tech else return end

local testActive

---Some description of the function
---@return boolean
function persona_feature_sit.sit()
	
	if input.bind("persona", "test") then testActive = not testActive end

  if testActive then 
  	os.__tech.setParentState("Sit")
  else
  	os.__tech.setParentState()
  end
end

string.persona.feature.sit = persona_feature_sit