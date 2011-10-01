---------------------------------------------------------------------------
-- @author Fabian Streitel (luakit@rottenrei.be)
-- @copyright 2011 Mason Larobina
---------------------------------------------------------------------------

local presentation
local presenter

local inc = function (uri)
    local slide = string.match(uri, "#(%d*)$")
    return slide and string.gsub(uri, "#%d*$", "#"..tostring(slide + 1)) or uri.."#2"
end

function new_presentation(uris)
    presentation = window.new(uris)
    presentation.win:add_signal("destroy", luakit.quit)
    presentation.view:add_signal("property::uri", function (v, status)
        local uri = v:eval_js("document.location", "(present.lua)")
        presenter.view.uri = uri
        presenter.main.right.uri = inc(uri)
    end)

    presenter = window.new(uris)
    local m = {
        layout = widget{type = "hbox"},
        left = presenter.tabs,
        right = widget{type = "webview"},
    }
    presenter.main = m

    m.layout.homogeneous = true
    m.layout.spacing = 5
    presenter.layout:pack(m.layout, {fill = true, expand = true})
    presenter.layout:reorder(m.layout, 2)
    presenter.layout:remove(presenter.tabs)

    m.right.uri = presenter.view.uri
    m.right:hide()
    m.layout:pack(m.left,  {fill = true, expand = true})
    m.layout:pack(m.right, {fill = true, expand = true})

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
        local timeout = tonumber(w.ibar.input.text)
        if timeout then
            presenter.timer = lousy.widget.timer.new{timeout = timeout}
            presenter.layout:pack(presenter.timer.widget)
        end
        w:set_mode("passthrough")
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
    cmd("next",                     function (w) presenter.main.right:show() end),
    cmd("nonext",                   function (w) presenter.main.right:hide() end),
    cmd("resize",                   function (w, a)
                                        local width, height = string.match(a or "", "^(%d*)x(%d*)$")
                                        if not (width and height) then return w:error("size must be of format <width>x<height>") end
                                        presentation.win:resize(width, height)
                                    end),
})

add_binds("all", {
    key({},         "F5",           function (w)
                                        presentation:set_mode("present")
                                        if presenter.timer then presenter.timer:start() end
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

