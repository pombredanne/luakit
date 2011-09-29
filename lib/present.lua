---------------------------------------------------------------------------
-- @author Fabian Streitel (luakit@rottenrei.be)
-- @copyright 2011 Mason Larobina
---------------------------------------------------------------------------

new_mode("present", {
    enter = function (w)
        w.win.fullscreen = true
        w.ibar.input:hide()
        w.sbar.ebox:hide()
    end,

    leave = function (w)
        w.win.fullscreen = false
        w.sbar.ebox:show()
    end,

    passthrough = true,
})

