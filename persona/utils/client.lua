---persona client utilities
---Author: Lonaasan
string.persona = string.persona or {};
string.persona.client = string.persona.client or {};

persona_client = {}

---Check if we are running with Neon++
---@return boolean
function persona_client.isNeon()
    return neon ~= nil;
end

---Check if we are running with StarExtensions
---@return boolean
function persona_client.isStarExtensions()
    return starExtensions ~= nil;
end

---Check if we are running in OpenStarbound
---@return boolean
function persona_client.isOpenStarbound()
    return root.assetJson("/player.config:genericScriptContexts").OpenStarbound ~= nil;
end

---Check if we are running in XStarbound
---@return boolean
function persona_client.isXStarbound()
    return xsb ~= nil;
end

---Check if we are running in Vanilla
---@return boolean
function persona_client.isVanilla()
    return not persona_client.isNeon() and not persona_client.isStarExtensions() and
               not persona_client.isOpenStarbound() and not persona_client.isXStarbound();
end

--- Get the client object for the current environment
---@return string
function persona_client.getClient()
    if persona_client.isNeon() then
        return "Neon";
    elseif persona_client.isStarExtensions() then
        return "StarExtensions";
    elseif persona_client.isOpenStarbound() then
        return "OpenStarbound";
    elseif persona_client.isXStarbound() then
        return "XStarbound";
    else
        return "Vanilla";
    end
end

--- Export the functions for 3rd parties to use without the possibility of changing the original code
string.persona.client = persona_client;
