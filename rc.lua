-- {{{ Requires
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("vicious")
require("lib/mpd")
-- }}}

-- {{{ Variable definitions
-- Load theme
beautiful.init(awful.util.getdir("config") .. "/zenburn.lua")

per_screen_tags = {}
per_screen_tags[1] = { "misc", "dev", "chat", "music" }
per_screen_tags[2] = { "misc", "dev" }

-- This is used later as the default terminal and editor to run.
terminal = "terminal"
browser = "uzbl"
editor = "vim"

airport_code = "KATW"

low_battery_threshold = 60

-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"
shiftkey = "Shift"
controlkey = "Control"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
  awful.layout.suit.tile, awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom, awful.layout.suit.tile.top,
  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
tags = {}

for s = 1, screen.count() do
  tags[s] = awful.tag(per_screen_tags[s], s, awful.layout.suit.tile)
end
-- }}}

-- {{{ Wibox

-- {{{ Widgets
-- {{{ Reusable separators
local separator = widget({ type = "textbox" })
separator.text  = "  "
-- }}}

-- {{{ Date
dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)
datewidget = widget({ type = "textbox" })
vicious.register(datewidget, vicious.widgets.date, "%a %m/%d %I:%M%P")
-- }}}

-- {{{ Pacman
pacmanicon = widget({ type = "imagebox" })
pacmanicon.image = image(beautiful.widget_pacman)
pacmanwidget = widget({ type = "textbox" })
pacmanseparator = widget({ type = "textbox" })
pacmanseparator.text  = "  "
vicious.register(pacmanwidget, vicious.widgets.script, 
  function(widget, args)
    local number = tonumber(args[1])
    if number > 0 then
      pacmanicon.visible = true
      pacmanwidget.visible = true
      pacmanseparator.visible = true
      return number
    else
      pacmanicon.visible = false
      pacmanwidget.visible = false
      pacmanseparator.visible = false
    end
  end, 3650, "system_updates.rb")
-- }}}

-- {{{ Weather
weathericon = widget({ type = "imagebox" })
weathericon.image = image(beautiful.widget_weather)
weatherwidget = widget({ type = "textbox" })
vicious.register(weatherwidget, vicious.widgets.weather, "${tempf}° ${sky}", 3600, airport_code)
-- }}}

-- {{{ Network usage
local dnicon = widget({ type = "imagebox" })
local upicon = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)
local netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net,
  function(widget, args)
    local format_speed = function(max, s)
      local n = tonumber(s)
      if n < max then return 0
      else return math.floor(n)
      end
    end

    return '<span color="' .. beautiful.fg_netdn_widget ..'">'
      .. format_speed(25, args["{wlan0 down_kb}"]) .. '</span>'
      .. ' <span color="' .. beautiful.fg_netup_widget ..'">'
      .. format_speed(5, args["{wlan0 up_kb}"]) .. '</span>'
  end, 3)
-- }}}

-- {{{ Mail
milclandotcomunread_unread = 0
donpetersendotnet_unread = 0

mailseparator = widget({ type = "textbox" })
mailseparator.text  = "  "
mailicon = widget({ type = "imagebox" })
mailicon.image = image(beautiful.widget_mail)

donpetersendotnetwidget = widget({ type = "textbox" })
milclandotcomwidget = widget({ type = "textbox" })

check_mail_widgets = function()
  if donpetersendotnet_unread == 0 and milclandotcomunread_unread == 0 then
    mailseparator.visible = false
    mailicon.visible = false
    donpetersendotnetwidget.visible = false
    milclandotcomwidget.visible = false
  else
    mailseparator.visible = true
    mailicon.visible = true
    donpetersendotnetwidget.visible = true
    milclandotcomwidget.visible = true
  end
end

vicious.register(donpetersendotnetwidget, vicious.widgets.donpetersendotnet,
  function(widget, args)
    local count = tonumber(args["{count}"])
    donpetersendotnet_unread = count
    check_mail_widgets()
    return '<span color="' .. beautiful.fg_donpetersendotnet_widget .. '">' .. count .. '</span>'
  end, 330)

vicious.register(milclandotcomwidget, vicious.widgets.milclandotcom,
  function(widget, args)
    local count = tonumber(args["{count}"])
    milclandotcomunread_unread = count
    check_mail_widgets()
    return '<span color="' .. beautiful.fg_normal .. '">|</span>'
      .. '<span color="' .. beautiful.fg_milclandotcom_widget .. '">' .. count .. '</span>'
  end, 300)
-- }}}

-- {{{ Power
powerseparator = widget({ type = "textbox" })
powerseparator.text  = "  "
powericon = widget({ type = "imagebox" })
powericon.image = image(beautiful.widget_power)
powerwidget = widget({ type = "textbox" })
vicious.register(powerwidget, vicious.widgets.bat,
  function(widget, args)
    local on_battery = (args[1] == "-")
    local percent = args[2]
    local time = args[3]

    if on_battery then
      powerseparator.visible = true
      powericon.visible = true

      if percent < low_battery_threshold then return percent .. "% " .. time
      else return percent .. "%"
      end
    else
      if percent < low_battery_threshold then
        powerseparator.visible = true
        powericon.visible = true
        return "↯ " .. percent .. "% " .. time
      else
        powerseparator.visible = false
        powericon.visible = false
      end
    end
  end, 300, "BAT0")
-- }}}

-- {{{ Systray
system_tray = widget({ type = "systray" })
-- }}}

-- {{{ Wifi
wifiicon = widget({ type = "imagebox" })
wifiicon.image = image(beautiful.widget_wifi)
wifiwidget = widget({ type = "textbox" })
vicious.register(wifiwidget, vicious.widgets.wifi, "${ssid}[${link}]", 33, "wlan0")
-- }}}

-- {{{ MPD
mpdseparator = widget({ type = "textbox" })
mpdseparator.text  = "  "
mpdicon = widget({ type = "imagebox" })
mpdicon.image = image(beautiful.widget_music)
mpdwidget = widget({ type = "textbox" })

mpdprogressbar = awful.widget.progressbar()
mpdprogressbar:set_width(4)
mpdprogressbar:set_height(14)
mpdprogressbar:set_vertical(true)
mpdprogressbar:set_background_color(beautiful.fg_off_widget)
mpdprogressbar:set_border_color(nil)
mpdprogressbar:set_color(beautiful.fg_widget)
mpdprogressbar:set_gradient_colors({ beautiful.fg_widget,
    beautiful.fg_center_widget, beautiful.fg_end_widget })

vicious.enable_caching(vicious.widgets.mpd_extended)

vicious.register(mpdwidget, vicious.widgets.mpd_extended,
  function(widget, args)
    if args["{status}"] == "playing" then
      return '<span color="' .. beautiful.fg_mpd_playing .. '">' 
      .. args["{now_playing}"] .. " [" ..args["{time_left}"] .. ']</span>'
    else
      return '<span color="' .. beautiful.fg_mpd_paused .. '">'
        .. args["{now_playing}"] .. '</span>'
    end
  end
)

vicious.register(mpdprogressbar, vicious.widgets.mpd_extended, "${percentage}")
-- }}}

-- {{{ Volume
local volumeicon = widget({ type = "imagebox" })
volumeicon.image = image(beautiful.widget_vol)
local volumebar = awful.widget.progressbar()

volumebar:set_width(4)
volumebar:set_height(14)
volumebar:set_vertical(true)
volumebar:set_background_color(beautiful.fg_off_widget)
volumebar:set_border_color(nil)
volumebar:set_color(beautiful.fg_widget)
volumebar:set_gradient_colors({ beautiful.fg_widget,
    beautiful.fg_center_widget, beautiful.fg_end_widget })

vicious.enable_caching(vicious.widgets.volume)

vicious.register(volumebar, vicious.widgets.volume, "$1",  2, "PCM")
-- }}}

-- {{{ CPU
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)

cpugraph  = awful.widget.graph()
cpugraph:set_width(14)
cpugraph:set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_color(beautiful.fg_end_widget)
cpugraph:set_gradient_angle(0)
cpugraph:set_gradient_colors({ beautiful.fg_end_widget,
    beautiful.fg_center_widget, beautiful.fg_widget })
vicious.register(cpugraph, vicious.widgets.cpu, "$1")
-- }}}
-- }}}

topwibox = {}
promptbox = {}
layoutbox = {}
taglist = {}
taglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ }, 3, awful.tag.viewtoggle))

for s = 1, screen.count() do
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)
  promptbox[s] = awful.widget.prompt()

  layoutbox[s] = awful.widget.layoutbox(s)
  layoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)))

  topwibox[s] = awful.wibox({
    position = "top", screen = s,
    fg = beautiful.fg_normal, bg = beautiful.bg_normal, height = beautiful.statusbar_height
  })

  topwibox[s].widgets = {
    {
      taglist[s],
      layoutbox[s],
      separator,
      promptbox[s],
      layout = awful.widget.layout.horizontal.leftright
    },
    s == 1 and {
      system_tray, separator,
      mpdicon, mpdwidget, mpdprogressbar, mpdseparator,
      volumeicon, volumebar, separator,
      powericon, powerwidget, powerseparator,
      wifiicon, wifiwidget, separator,
      pacmanicon, pacmanwidget, pacmanseparator,
      mailicon, donpetersendotnetwidget,
      milclandotcomwidget, mailseparator,
      cpuicon, cpugraph, separator,
      dnicon, netwidget, upicon, separator,
      weathericon, weatherwidget, separator,
      dateicon, datewidget, separator,
      layout = awful.widget.layout.horizontal.rightleft
    } or nil,
    layout = awful.widget.layout.horizontal.leftright
  }
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  awful.key({ modkey,           }, "j",
  function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey,           }, "k",
  function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),

  -- Layout manipulation
  awful.key({ modkey, shiftkey   }, "j", function () awful.client.swap.byidx(  1) end),
  awful.key({ modkey, shiftkey   }, "k", function () awful.client.swap.byidx( -1) end),
  awful.key({ modkey, controlkey }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, controlkey }, "k", function () awful.screen.focus_relative(-1) end),

  -- Standard program
  awful.key({ modkey,            }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey,            }, "e", function () awful.util.spawn(browser) end),
  awful.key({ modkey, controlkey }, "r", awesome.restart),
  awful.key({ modkey, shiftkey   }, "q", awesome.quit),
  awful.key({ modkey, controlkey }, "c", function ()
    for line in io.popen("awesome --check 2>&1"):lines() do naughty.notify({ text = line }) end
  end),

  awful.key({ modkey, controlkey }, "w", function ()
    local class = ""
    local name = ""
    local instance = ""

    if client.focus.class then
      class = client.focus.class
    end
    if client.focus.name then
      name = client.focus.name
    end
    if client.focus.instance then
      instance = client.focus.instance
    end

    naughty.notify({ text="c: " .. class .. " i: " .. instance, title=name, timeout=10 })
  end),

  awful.key({ modkey,            }, "l",     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey,            }, "h",     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, shiftkey   }, "h",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, shiftkey   }, "l",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ modkey,            }, "space", function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, shiftkey   }, "space", function () awful.layout.inc(layouts, -1) end),

  -- Mixer & MPD controls
  awful.key({ altkey, controlkey }, "j",     function () mpd.volume_down(5); mpdwidget.text = mpd_widget_text() end),
  awful.key({ altkey, controlkey }, "k",     function () mpd.volume_up(5);   mpdwidget.text = mpd_widget_text() end),
  awful.key({ altkey, controlkey }, "space", function () mpd.toggle_play();  mpdwidget.text = mpd_widget_text() end),
  awful.key({ altkey, controlkey }, "s",     function () mpd.stop();         mpdwidget.text = mpd_widget_text() end),
  awful.key({ altkey, controlkey }, "h",     function () mpd.previous();     mpdwidget.text = mpd_widget_text() end),
  awful.key({ altkey, controlkey }, "l",     function () mpd.next();         mpdwidget.text = mpd_widget_text() end),

  -- Prompt
  awful.key({ modkey },            "r",     function () promptbox[mouse.screen]:run() end),
  awful.key({ modkey }, "s", function ()
    awful.prompt.run({ prompt = "Web search: " }, promptbox[mouse.screen].widget,
    function (command)
      awful.util.spawn(browser .. " 'http://yubnub.org/parser/parse?command=" .. command.. "'", false)
    end)
  end)

)

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = awful.util.table.join(
  awful.key({ modkey,            }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey, shiftkey   }, "c",      function (c) c:kill()                         end),
  awful.key({ modkey, controlkey }, "space",  awful.client.floating.toggle                     ),
  awful.key({ modkey, controlkey }, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,            }, "o",      awful.client.movetoscreen                        ),
  awful.key({ modkey, shiftkey   }, "r",      function (c) c:redraw()                       end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
  awful.key({ modkey }, i,
    function ()
      local screen = mouse.screen
      if tags[screen][i] then
        awful.tag.viewonly(tags[screen][i])
      end
    end),
  awful.key({ modkey, controlkey }, i,
    function ()
      local screen = mouse.screen
      if tags[screen][i] then
        tags[screen][i].selected = not tags[screen][i].selected
      end
    end),
  awful.key({ modkey, shiftkey }, i,
    function ()
      if client.focus and tags[client.focus.screen][i] then
        awful.client.movetotag(tags[client.focus.screen][i])
      end
    end),
  awful.key({ modkey, controlkey, shiftkey }, i,
    function ()
      if client.focus and tags[client.focus.screen][i] then
        awful.client.toggletag(tags[client.focus.screen][i])
      end
    end)
  )
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = { },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = true,
      keys = clientkeys,
      buttons = clientbuttons
    }
  },
  {
    rule = { class = "gimp" },
    properties = { floating = true }
  }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:add_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  -- No gaps around windows
  c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- vim: ft=lua:ai:sw=2:sts=2:ts=2:et
