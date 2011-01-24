---------------------------------------------------------
-- Bindings for the web inspector                      --
-- (C) 2010 Fabian Streitel <karottenreibe@gmail.com>  --
---------------------------------------------------------

local windows = setmetatable({}, {__mode = "k"})

-- Register signal handlers and enable inspector.
webview.init_funcs.inspector = function (view, w)
    view:set_prop("enable-developer-extras", true)
    view:add_signal("inspect-web-view", function ()
        local win = widget{type="window"}
        local iview = widget{type="webview"}
        win:set_child(iview)
        windows[iview] = win
        return iview
    end)
    view:add_signal("show-inspector", function (_, iview)
        local win = windows[iview]
        if win then
          win:show()
        end
    end)
    view:add_signal("close-inspector", function (_, iview)
        local win = windows[iview]
        if win then
          windows[iview] = nil
          win:destroy()
        end
    end)
end

-- Toggle web inspector.
webview.methods.toggle_inspector = function (view, w, show)
    if show or not view.inspector.visible then
        view.inspector:show()
    else
        view.inspector:close()
    end
end

-- Add command to toggle inspector.
local cmd = lousy.bind.cmd
add_cmds({
    cmd({"inspect"},       function (w)    w:toggle_inspector(true) end),
    cmd({"inspect!"},      function (w)    w:toggle_inspector() end),
})

