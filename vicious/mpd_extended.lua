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

    -- Get extended info
    mpdinfo["{status}"] = string.match(status, "^%[(.+)%]")
    mpdinfo["{current_time}"] = string.match(status, "^%S+%s+%S+%s+([%d:]+)")
    mpdinfo["{total_time}"] = string.match(status, "^%S+%s+%S+%s+[%d:]+/([%d:]+)")
    mpdinfo["{percentage}"] = string.match(status, "%((%d+)%%%)$")
    mpdinfo["{volume}"] = string.match(setup, "volume: (%d+)")

    return mpdinfo
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
