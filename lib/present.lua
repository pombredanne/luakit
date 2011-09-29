---------------------------------------------------------------------------
-- @author Fabian Streitel (luakit@rottenrei.be)
-- @copyright 2011 Mason Larobina
---------------------------------------------------------------------------


local tablist_hider = function (t) t.widget:hide() end

new_mode("present", {
    enter = function (w)
        w.win.fullscreen = true
        w.ibar.input:hide()
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
})

