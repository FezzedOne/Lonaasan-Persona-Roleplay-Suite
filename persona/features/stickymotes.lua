---persona stickymotes functions
---Author: Lonaasan & Aisha Heartleigh, integrated into persona
string.persona = string.persona or {};
string.persona.feature = string.persona.feature or {};
string.persona.feature.stickymotes = string.persona.feature.stickymotes or {};

persona_feature_stickymotes = {}

-- Annoyed, Blabbering, Blink, Eat, Happy, Idle, Laugh, NEUTRAL, Oh, OOOH, Sad, Shouting, Sleep, Wink
local lastEmote = nil
local resetTime = 2

--- Resets stickymotes
function persona_feature_stickymotes.reset()
    lastEmote = nil
    resetTime = 2
end

--- Update stickymotes
function persona_feature_stickymotes.update()
    local emote, time = player.currentEmote()

    if emote == "Blabbering" -- Do nothing with emotes the game may trigger itself (Blabbering/Shouting, Eat, Blink)
    or emote == "Shouting" -- you'd have to unstick these each time the game triggers them otherwise
    or emote == "Eat" then
        lastEmote = emote
        return -- Skip the entire rest of the script, let the emote play out normally

    elseif emote ~= lastEmote then -- Triggering any emote other than the one currently active

        if emote == "Blink" then -- Blinks are faster
            player.emote(emote, 0.5 + resetTime)

        elseif emote == "Wink" then -- Winks stick for only half a second, making them spammable ;) ;) ;) ;)
            player.emote(emote, 0.45 + resetTime)

        elseif emote == "Sleep" then -- Sleep sticks forever until another emote is triggered
            player.emote(emote, math.huge)

        elseif emote ~= "Idle" then -- Any other emotes stick for <stickyTime> seconds
            local stickyTime = 300
            player.emote(emote, stickyTime + resetTime)

        end

        -- time <= 2 would break emotes on loungeables, such as beds, and I REALLY need to write down why
    elseif time < resetTime -- Current emote has less than resetTime seconds on timer (or was retriggered!)
    and time ~= 1.9833333492279053 -- SCC's afk
    then
        player.emote("Idle", 0) -- Go back to Idle emote
    end

    lastEmote = emote -- Remember emote next update
end

string.persona.feature.stickymotes = persona_feature_stickymotes
