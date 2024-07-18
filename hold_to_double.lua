
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

local doubled = false
local fast_speed_multiplier = 2.0
local slow_speed_diviser = 2.0
local current_speed = 0.0

local function fast_play(table)
	if table == nil or table["event"] == "down" or table["event"] == "repeat" then	
		if not doubled then
			current_speed = mp.get_property_number("speed", 1.0)
			mp.set_property("speed", current_speed * fast_speed_multiplier)
			mp.osd_message((">> x%.1f"):format(current_speed * fast_speed_multiplier), osd_duration)
			doubled = true
		end
	elseif table["event"] == "up" then
		mp.set_property("speed", current_speed)
		mp.osd_message(tostring(current_speed), osd_duration)
		doubled = false
	end
end

local function slow_play(table)
	if table == nil or table["event"] == "down" or table["event"] == "repeat" then
		if not doubled then
			current_speed = mp.get_property_number("speed", 1.0)
			mp.set_property("speed", current_speed / slow_speed_diviser)
			mp.osd_message((">> x%.1f"):format(current_speed / slow_speed_diviser), osd_duration)
			doubled = true
		end
	elseif table["event"] == "up" then
		mp.set_property("speed", current_speed)
		mp.osd_message(tostring(current_speed), osd_duration)
		doubled = false
	end
end

mp.add_forced_key_binding("MBTN_RIGHT", "hold_slow", slow_play, { complex = true, repeatable = false })
mp.add_forced_key_binding("MBTN_LEFT", "hold_fast", fast_play, { complex = true, repeatable = false })