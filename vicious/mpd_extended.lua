---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
--  * (c) Wicked, Lucas de Vries
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local string = { find = string.find, match = string.match }
local tonumber = tonumber
-- }}}


-- Mpd: provides the currently playing song in MPD
module("vicious.mpd_extended")


-- {{{ MPD widget type
local function worker(format)
    -- Get data from mpc
    local f = io.popen("mpc")
    local np = f:read("*line")
    local status = f:read("*line")
    local setup = f:read("*line")
    f:close()

    local mpdinfo = {
        ["{is_stopped}"] = "true",
        ["{now_playing}"] = "N/A",
        ["{status}"] = "N/A",
        ["{current_time}"] = "N/A",
        ["{time_left}"] = "N/A",
        ["{total_time}"] = "N/A",
        ["{percentage}"] = 0,
        ["{volume}"] = 0
    }

    -- Check if it's stopped, off or not installed
    if np == nil
    or (string.find(np, "MPD_HOST") or string.find(np, "volume:")) then return mpdinfo
    else mpdinfo["{is_stopped}"] = "false"
    end

    -- Sanitize the song name
    local nowplaying = helpers.escape(np)

    -- Don't abuse the wibox, truncate
    mpdinfo["{now_playing}"] = helpers.truncate(nowplaying, 60)

    -- Get info
    mpdinfo["{status}"] = string.match(status, "^%[(.+)%]")
    mpdinfo["{current_time}"] = string.match(status, "^%S+%s+%S+%s+([%d:]+)")
    mpdinfo["{total_time}"] = string.match(status, "^%S+%s+%S+%s+[%d:]+/([%d:]+)")
    mpdinfo["{percentage}"] = string.match(status, "%((%d+)%%%)$")
    mpdinfo["{volume}"] = string.match(setup, "volume: (%d+)")

    -- Calculate time left
    mpdinfo["{time_left}"] = "Hey bitch"
    if mpdinfo["{current_time}"] ~= "" then
        local strip_seconds = function(s)
            return tonumber(string.match(s, ":(%d+)$"))
        end

        local strip_minutes = function(s)
            return tonumber(string.match(s, "^(%d+):"))
        end

        local minutize = function(s)
            local seconds = s % 60
            local minutes = (s - seconds) / 60
            local padding = ""
            if seconds < 10 then padding = "0" end
            return minutes .. ":" .. padding .. seconds
        end

        local current_time = mpdinfo["{current_time}"]
        local total_time = mpdinfo["{total_time}"]
        local current_seconds = (strip_minutes(current_time) * 60) + strip_seconds(current_time)
        local total_seconds = (strip_minutes(total_time) * 60) + strip_seconds(total_time)
        mpdinfo["{time_left}"] = minutize(total_seconds - current_seconds)
    end

    return mpdinfo
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
