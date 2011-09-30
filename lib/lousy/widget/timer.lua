-------------------------------------------------------------
-- @author Fabian Streitel (luakit@rottenrei.be)           --
-- @copyright 2010 Mason Larobina                          --
-------------------------------------------------------------

-- Grab environment we need
local capi = { widget = widget, timer = timer }
local setmetatable = setmetatable
local math = require "math"
local os = require "os"
local string = string
local get_theme = require("lousy.theme").get
local pairs = pairs

module "lousy.widget.timer"

function update(t)
    local now = os.time()
    local diff = t.start_time and now - t.start_time or 0
    diff = t.timeout - diff
    local mins = math.floor(diff / 60)
    local secs = math.floor(diff % 60)
    t.widget.text = string.format("%i:%02i", mins, secs)
end

function start(t)
    t.start_time = os.time()
    t.timer:add_signal("timeout", function () update(t) end)
    t.timer:start()
end

function new(opts)
    local t = {
        timeout = (opts.timeout or 15) * 60,
        widget = capi.widget{type="label"},
        timer = capi.timer{interval=500},
        start = function (t) start(t) end,
        update = function (t) update(t) end,
    }

    local theme = get_theme()
    for k, v in pairs{
        fg = theme.timer_fg,
        bg = theme.timer_bg,
        font = theme.timer_font,
    } do
        t.widget[k] = v
    end

    t.widget.align = { x = 0.5, y = 0.5 }
    update(t)

    return t
end

