--------------------------
-- Default luakit theme --
--------------------------

local theme = {}

-- Default settings
theme.font = "monospace normal 9"
theme.fg   = "#fff"
theme.bg   = "#000"

-- Presentation colors
theme.blank_screen = "#000"

-- Timer specific
theme.timer_font = "monospace normal 72"
theme.middle_timer_fg = "#9F9"
theme.finish_timer_fg = "#FA0"
theme.negative_timer_fg = "#F00"

-- General colours
theme.success_fg = "#0f0"
theme.loaded_fg  = "#33AADD"
theme.error_fg = "#FFF"
theme.error_bg = "#F00"

-- Warning colours
theme.warning_fg = "#F00"
theme.warning_bg = "#FFF"

-- Notification colours
theme.notif_fg = "#444"
theme.notif_bg = "#FFF"

-- Statusbar specific
theme.sbar_fg         = "#fff"
theme.sbar_bg         = "#000"

-- Input bar specific
theme.ibar_fg           = "#000"
theme.ibar_bg           = "#fff"

-- Tab label
theme.tab_fg            = "#888"
theme.tab_bg            = "#222"
theme.tab_ntheme        = "#ddd"
theme.selected_fg       = "#fff"
theme.selected_bg       = "#000"
theme.selected_ntheme   = "#ddd"
theme.loading_fg        = "#33AADD"
theme.loading_bg        = "#000"

return theme
-- vim: et:sw=4:ts=8:sts=4:tw=80
