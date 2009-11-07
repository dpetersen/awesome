---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local awful = awful
--local string = { match = string.match }
-- }}}


-- Pacman: provides number of pending updates on Arch Linux
module("vicious.script")


-- {{{ Script widget type
local function worker(format, name)
    local f = io.popen(awful.util.getdir("config") .. "/scripts/" .. name)
    local output = f:read("*all")
    f:close()

    return {output}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
