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
local tostring = tostring

module "lousy.widget.timer"

function update(t)
    local bound = t.timeout < 0 and math.ceil or math.floor
    local mins = bound(t.timeout / 60)
    local secs = math.abs(math.mod(t.timeout, 60))
    t.widget.text = string.format("%s:%02i", tostring(mins), secs)
end

function start(t)
    t.timer:add_signal("timeout", function ()
        t.timeout = t.timeout - 1
        update(t)
    end)
    t.timer:start()
end

function stop(t)
    t.timer:stop()
end

function new(opts)
    local t = {
        timeout = (opts.timeout or 15) * 60,
        widget = capi.widget{type="label"},
        timer = capi.timer{interval=1000},
        start = function (t) start(t) end,
        stop = function (t) stop(t) end,
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

