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
local assert = assert

module "lousy.widget.timer"

local data = setmetatable({}, {__mode="k"})

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
    local d = assert(data[t], "not a timer widget")
    if not d.started then
        d.timer:start()
        d.started = true
    end
end

function stop(t)
    local d = assert(data[t], "not a timer widget")
    if d.started then
        d.timer:stop()
        d.started = false
    end
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
        start = function (t) start(t) end,
        stop = function (t) stop(t) end,
        update = function (t) update(t) end,
    }

    local d = {
        timer = capi.timer{interval=1000},
        started = false,
    }
    data[t] = d

    d.timer:add_signal("timeout", function ()
        t.time = t.time - 1
        update(t)
    end)

    t.widget.align = { x = 0.5, y = 0.5 }
    update(t)

    return t
end

