---------------------------------------------------------------------------
-- @author Fabian Streitel (luakit@rottenrei.be)
-- @copyright 2011 Mason Larobina
---------------------------------------------------------------------------

local presentation
local presenter

function new_presentation(uris)
    presentation = window.new(uris)
    presentation.win:add_signal("destroy", luakit.quit)
    presentation.view:add_signal("property::uri", function (v, status)
        presenter.view.uri = v:eval_js("document.location", "(present.lua)")
    end)

    presenter = window.new(uris)
    presenter.win:add_signal("destroy", luakit.quit)

    presenter:set_mode("timer")
end

local timer = require "lousy.widget.timer"
local tablist_hider = function (t) t.widget:hide() end

-- Bindings and commands
new_mode("present", {
    enter = function (w)
        w.win.fullscreen = true
        w.ibar.ebox:hide()
        w.sbar.ebox:hide()
        w.tablist.widget:hide()
        w.tablist:add_signal("updated", tablist_hider)
        -- reset Sozi player
        w:eval_js("sozi.display.clip = false; sozi.display.update()", "(sozi-reset)")
    end,

    leave = function (w)
        w.win.fullscreen = false
        w.ibar.ebox:show()
        w.sbar.ebox:show()
        w.tablist.widget:show()
        w.tablist:remove_signal("updated", tablist_hider)
    end,

    passthrough = true,
    reset_on_focus = false,
    has_buffer = true,
})

new_mode("timer", {
    enter = function (w)
        w:set_prompt("Timer:")
        w:set_input("")
    end,

    activate = function (w)
        presenter.timer = lousy.widget.timer.new{timeout = tonumber(w.ibar.input.text)}
        presenter.layout:pack(presenter.timer.widget)
        w:set_mode()
    end,

    reset_on_navigation = false,
})

local key, buf, but = lousy.bind.key, lousy.bind.buf, lousy.bind.but
local cmd, any = lousy.bind.cmd, lousy.bind.any

add_cmds({
    cmd("timer",                    function (w, a)
                                        if not presenter.timer then
                                            presenter.timer = lousy.widget.timer.new{timeout = tonumber(w.ibar.input.text)}
                                            presenter.layout:pack(presenter.timer.widget)
                                        end
                                        local split = lousy.util.string.split(a or "", "%s")
                                        for k, v in ipairs(split) do split[k] = tonumber(v) end
                                        local time   = split[1] and split[1] * 60 or presenter.timer.time
                                        local middle = split[2] and split[2] * 60 or presenter.timer.etaps.middle
                                        local finish = split[3] and split[3] * 60 or presenter.timer.etaps.finish
                                        presenter.timer.time         = time
                                        presenter.timer.etaps.middle = middle
                                        presenter.timer.etaps.finish = finish
                                        presenter.timer:update()
                                        w:notify(string.format("set timer to %.2f min, middle %.2f min, finish %.2f min", time / 60, middle / 60, finish / 60))
                                    end),
})

add_binds("all", {
    key({},         "F5",           function (w)
                                        presentation:set_mode("present")
                                        presenter.timer:start()
                                    end),

    -- Slide changing binds
    buf("^gg$",                     function (w, b, m)
                                        w:eval_js(string.format("sozi.player.jumpToFrame(%i)", m.count), "(present.lua)")
                                    end, {count = 0}),
    buf("^G$" ,                     function (w, b, m)
                                        w:eval_js(string.format("sozi.player.jumpToFrame(%i)", m.count), "(present.lua)")
                                    end, {count = 9999}),
})

add_binds("present", {
    parse_count_binding,

    -- Blank screen
    key({},         ".",            function (w)
                                        w.blank = not w.blank
                                        if w.blank then
                                            w.layout:hide()
                                        else
                                            w.layout:show()
                                            w.view:focus_view()
                                        end
                                    end),
})

