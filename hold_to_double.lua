--
-- Hold mouse key to alter playback speed and release to playback at a normal speed
--
-- Code modified from Ciacconas/mpv-scripts/hold_accelerate.lua

--
-- Usage: put this file in the mpv scripts folder
-- You can customize the speed multiplier and diviser by changing the
-- the corresponding variables. The key can also be changed by varying
-- first argument of the key_binding commands at the end.

local mp = require("mp")
local decay_delay = 0.05 -- rate of time by which playback speed is decreased
local osd_duration = math.max(decay_delay, mp.get_property_number("osd-duration") / 1000)

local fast_speed_multiplier = 2.0
local slow_speed_diviser = 2.0

local holding = nil
local current_speed = nil
local start_time = nil

local function fast_play(table)
    if start_time == nil then
        start_time = os.clock()
    end
    if os.clock() < start_time + 0.3 then
        if table["event"] == "up" then
            mp.command("cycle pause")
            start_time = nil
        end
    elseif os.clock() >= start_time + 0.3 then
        if table == nil or table["event"] == "down" or table["event"] == "repeat" and not holding then
            current_speed = mp.get_property_number("speed", 1.0)
            mp.set_property("speed", current_speed * fast_speed_multiplier)
            mp.osd_message((">> x%.1f"):format(current_speed * fast_speed_multiplier), 3600)
            holding = true
        elseif table["event"] == "up" then
            mp.set_property("speed", current_speed)
            mp.osd_message(tostring(current_speed), osd_duration)
            start_time = nil
            holding = false
        end
    end
end

local function slow_play(table)
    if table == nil or table["event"] == "down" or table["event"] == "repeat" then
        if not holding then
            current_speed = mp.get_property_number("speed", 1.0)
            mp.set_property("speed", current_speed / slow_speed_diviser)
            mp.osd_message((">> x%.1f"):format(current_speed / slow_speed_diviser), 3600)
            holding = true
        end
    elseif table["event"] == "up" then
        mp.set_property("speed", current_speed)
        mp.osd_message(tostring(current_speed), osd_duration)
        holding = false
    end
end




mp.add_forced_key_binding("b", "hold_slow", slow_play, { complex = true, repeatable = false })
mp.add_forced_key_binding("space", "hold_fast", fast_play, { complex = true, repeatable = false })
