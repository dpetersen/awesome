-- Modified Zenburn theme by anrxc

-- {{{ Main
theme = {}
theme.confdir       = awful.util.getdir("config")
-- }}}

-- {{{ Styles
theme.font      = "Profont 8"
theme.statusbar_height = 14

-- {{{ Colors
theme.fg_normal = "#DCDCCC"
theme.fg_focus  = "#F0DFAF"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#3F3F3F"
theme.bg_focus  = "#1E2320"
theme.bg_urgent = "#3F3F3F"
-- }}}

-- {{{ Borders
theme.border_width  = "2"
theme.border_normal = "#3F3F3F"
theme.border_focus = "#CC9393"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- {{{ Widgets
theme.fg_widget        = "#AECF96"
theme.fg_center_widget = "#88A175"
theme.fg_end_widget    = "#FF5656"
theme.fg_off_widget    = "#494B4F"
theme.fg_netup_widget  = "#7F9F7F"
theme.fg_netdn_widget  = "#CC9393"
theme.bg_widget        = "#3F3F3F"
theme.border_widget    = "#3F3F3F"
theme.fg_milclandotcom_widget  = "#CC9393"
theme.fg_donpetersendotnet_widget  = "#7F9F7F"
-- }}}
-- }}}

-- {{{ Icons
--
-- {{{ Taglist icons
theme.taglist_squares_sel   = theme.confdir .. "/icons/taglist/squarefz.png"
theme.taglist_squares_unsel = theme.confdir .. "/icons/taglist/squareza.png"
-- }}}

-- {{{ Layout icons
theme.layout_tile       = theme.confdir .. "/icons/layouts/tile.png"
theme.layout_tileleft   = theme.confdir .. "/icons/layouts/tileleft.png"
theme.layout_tilebottom = theme.confdir .. "/icons/layouts/tilebottom.png"
theme.layout_tiletop    = theme.confdir .. "/icons/layouts/tiletop.png"
theme.layout_fairv      = theme.confdir .. "/icons/layouts/fairv.png"
theme.layout_fairh      = theme.confdir .. "/icons/layouts/fairh.png"
theme.layout_spiral     = theme.confdir .. "/icons/layouts/spiral.png"
theme.layout_dwindle    = theme.confdir .. "/icons/layouts/dwindle.png"
theme.layout_max        = theme.confdir .. "/icons/layouts/max.png"
theme.layout_fullscreen = theme.confdir .. "/icons/layouts/fullscreen.png"
theme.layout_magnifier  = theme.confdir .. "/icons/layouts/magnifier.png"
theme.layout_floating   = theme.confdir .. "/icons/layouts/floating.png"
-- }}}

-- {{{ Widget icons
theme.widget_cpu    = theme.confdir .. "/icons/cpu.png"
theme.widget_bat    = theme.confdir .. "/icons/bat.png"
theme.widget_mem    = theme.confdir .. "/icons/mem.png"
theme.widget_fs     = theme.confdir .. "/icons/disk.png"
theme.widget_net    = theme.confdir .. "/icons/down.png"
theme.widget_netup  = theme.confdir .. "/icons/up.png"
theme.widget_mail   = theme.confdir .. "/icons/mail.png"
theme.widget_vol    = theme.confdir .. "/icons/vol.png"
theme.widget_date   = theme.confdir .. "/icons/time.png"
theme.widget_pacman = theme.confdir .. "/icons/pacman.png"
theme.widget_weather = theme.confdir .. "/icons/temp.png"
-- }}}

-- {{{ Titlebar icons
theme.titlebar_close_button_focus  = theme.confdir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.confdir .. "/icons/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active    = theme.confdir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active   = theme.confdir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme.confdir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.confdir .. "/icons/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active    = theme.confdir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active   = theme.confdir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme.confdir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.confdir .. "/icons/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active    = theme.confdir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active   = theme.confdir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme.confdir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.confdir .. "/icons/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = theme.confdir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.confdir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.confdir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.confdir .. "/icons/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}


return theme
