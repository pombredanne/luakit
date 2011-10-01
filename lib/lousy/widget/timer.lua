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
    local timeout = t.time
    local bound = timeout < 0 and math.ceil or math.floor
    local mins = bound(timeout / 60)
    local secs = math.abs(math.mod(timeout, 60))
    t.widget.text = string.format("%s:%02i", tostring(mins), secs)

    local theme = get_theme()
    local prefix = timeout < 0              and "negative" or
                   timeout < t.etaps.finish and "finish"   or
                   timeout < t.etaps.middle and "middle"   or ""
    for k, v in pairs{
        fg   = theme[prefix .. "_timer_fg"],
        font = theme[prefix .. "_timer_font"],
    } do
        t.widget[k] = v
    end
end

function start(t)
    t.timer:add_signal("timeout", function ()
        t.time = t.time - 1
        update(t)
    end)
    t.timer:start()
end

function stop(t)
    t.timer:stop()
end

function new(opts)
    local timeout = opts.timeout or 15
    local middle = opts.middle or timeout / 2
    local finish = opts.finish or timeout / 4
    local t = {
        etaps = {
            middle = middle * 60,
            finish = finish * 60,
        },
        time = timeout * 60,
        widget = capi.widget{type="label"},
        timer = capi.timer{interval=1000},
        start = function (t) start(t) end,
        stop = function (t) stop(t) end,
        update = function (t) update(t) end,
    }

    t.widget.align = { x = 0.5, y = 0.5 }
    update(t)

    return t
end

