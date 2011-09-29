---------------------------------------------------------------------------
-- @author Fabian Streitel (luakit@rottenrei.be)
-- @copyright 2011 Mason Larobina
---------------------------------------------------------------------------

local tablist_hider = function (t) t.widget:hide() end

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

local key, buf, but = lousy.bind.key, lousy.bind.buf, lousy.bind.but
local cmd, any = lousy.bind.cmd, lousy.bind.any

add_binds("all", {
    key({},         "F5",           function (w) w:set_mode("present") end),

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

