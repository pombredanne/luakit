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
    end,

    leave = function (w)
        w.win.fullscreen = false
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
                                        local uri = w.view.uri
                                        if not string.match(uri, "#%d*$") then uri = uri .. "#" end
                                        w.view.uri = string.gsub(uri, "#%d*$", "#"..m.count)
                                    end, {count = 1}),
    buf("^G$" ,                     function (w, b, m)
                                        local uri = w.view.uri
                                        if not string.match(uri, "#%d*$") then uri = uri .. "#" end
                                        w.view.uri = string.gsub(uri, "#%d*$", "#"..m.count)
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

