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

-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"
shiftkey = "Shift"
controlkey = "Control"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
  awful.layout.suit.tile, awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom, awful.layout.suit.tile.top,
  awful.layout.suit.max.fullscreen, awful.layout.suit.magnifier,
  awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
tags = {}

for s = 1, screen.count() do
  tags[s] = awful.tag(per_screen_tags[s], s, awful.layout.suit.tile)
end
-- }}}

-- {{{ Top Wibox

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
vicious.register(pacmanwidget, vicious.widgets.pacman,
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
  end,
  3650)
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

-- {{{ donpetersen.net Mail
donpetersendotneticon = widget({ type = "imagebox" })
donpetersendotneticon.image = image(beautiful.widget_mail)
donpetersendotnetwidget = widget({ type = "textbox" })
vicious.register(donpetersendotnetwidget, vicious.widgets.donpetersendotnet,
  '<span color="' .. beautiful.fg_donpetersendotnet_widget .. '">${count}</span>', 650)
-- }}}

-- {{{ milclan.com Mail
milclandotcomwidget = widget({ type = "textbox" })
vicious.register(milclandotcomwidget, vicious.widgets.milclandotcom,
  '<span color="' .. beautiful.fg_normal .. '">|</span>'
  .. '<span color="' .. beautiful.fg_milclandotcom_widget .. '">${count}</span>', 600)
-- }}}

-- {{{ Systray
system_tray = widget({ type = "systray" })
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
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
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
      separator,
      datewidget, dateicon, separator,
      weatherwidget, weathericon, separator,
      pacmanwidget, pacmanicon, pacmanseparator,
      upicon, netwidget, dnicon, separator,
      milclandotcomwidget,
      donpetersendotnetwidget, donpetersendotneticon, separator,
      system_tray,
      layout = awful.widget.layout.horizontal.rightleft
    } or nil,
    layout = awful.widget.layout.horizontal.leftright
  }
end
-- }}}

-- {{{ Bottom Wibox

-- {{{ MPD Widget
-- (need the mpd lib for lua)

last_songid = nil
mpd.scroll  = 0
function mpd_widget_text()
  local function timeformat(t)
    if tonumber(t) >= 60 * 60 then -- more than one hour !
      return os.date("%X", t)
    else
      return os.date("%M:%S", t)
    end
  end

  local function unknowize(x)
    return awful.util.escape(x or "(unknown)")
  end

  local now_playing, status, total_time, current_time
  local stats = mpd.send("status")

  if not stats.state then
    return "MPD not launched?"
  end

  if stats.state == "stop" then
    last_songid = false
    return ""
  end

  local zstats = mpd.send("playlistid " .. stats.songid)
  now_playing = string.format("%s - %s - %s",
  unknowize(zstats.artist), unknowize(zstats.album), unknowize(zstats.title))

  if stats.state ~= "play" then
    now_playing = now_playing .. " (" .. stats.state .. ")"
  end

  current_time   = timeformat(stats.time:match("(%d+):"))
  total_time     = timeformat(stats.time:match("%d+:(%d+)"))

  if use_naughty then
    if not last_songid or last_songid ~= stats.songid then
      last_songid = stats.songid
      naughty.notify {
        text = string.format("%s: %s\n%s:  %s\n%s: %s",
        bold("artist"), unknowize(zstats.artist),
        bold("album"),  unknowize(zstats.album),
        bold("title"),  unknowize(zstats.title)),
        width = 280,
        timeout = 6
      }
    end
  end

  return "now playing: " .. now_playing .. " - " .. current_time .. "/" .. total_time .. " vol: " .. stats.volume
end

-- }}}

-- {{{  Mutt Widget
previous_unread_mail_count = 0
function mutt_widget_text(count)
  count = tonumber(count)
  if count == 0 then
    muttwidget.text = ""
  else
    muttwidget.text = "Mail: " .. count
  end

  if previous_unread_mail_count == 0 and count > 0 then
    naughty.notify({ text = "You have new mail!", timeout = 15, bg = "red" })
  end
end
-- }}}

dividerwidget = widget({ type = "textbox" })
dividerwidget.text = " // "

spacerwidget = widget({ type = "textbox" })
spacerwidget.text = "  "

mpdwidget = widget { type = "textbox" }
muttwidget = widget { type = "textbox" }

bottom_wibox = awful.wibox({ position = "bottom", fg = beautiful.fg_normal, bg = beautiful.bg_normal, height = beautiful.statusbar_height })
bottom_wibox.widgets = {
  {
    spacerwidget,
    layout = awful.widget.layout.horizontal.leftright
  },
  muttwidget, mpdwidget,
  layout = awful.widget.layout.horizontal.rightleft
}
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

second_timer = timer { timeout = 1 }
second_timer:add_signal("timeout", function()
  mpdwidget.text = mpd_widget_text()
end)
second_timer:start()
-- }}}

-- vim: ft=lua:ai:sw=2:sts=2:ts=2:et
