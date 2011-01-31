/*
 * inspector.c - WebKitWebInspector wrapper
 *
 * Copyright (C) 2010 Fabian Streitel <karottenreibe@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "globalconf.h"
#include "classes/inspector.h"

static lua_class_t inspector_class;
LUA_OBJECT_FUNCS(inspector_class, inspector_t, inspector)

static WebKitWebView*
inspect_webview_cb(WebKitWebInspector *inspector, WebKitWebView *v, inspector_t *i)
{
    (void) inspector;
    (void) v;

    lua_State *L = globalconf.L;
    luaH_object_push(L, i->webview->ref);
    gint nret = luaH_object_emit_signal(L, -1, "inspect-web-view", 0, 1);
    if (nret > 0) {
        widget_t *new = luaH_checkwidget(L, -1);
        i->widget = new;
        // fix attached size
        gtk_widget_set_size_request(new->widget, -1, 300);
        return WEBKIT_WEB_VIEW(g_object_get_data(G_OBJECT(new->widget), "webview"));
    } else {
        return NULL;
    }
}

static gboolean
show_window_cb(WebKitWebInspector *inspector, inspector_t *i)
{
    (void) inspector;

    lua_State *L = globalconf.L;
    luaH_object_push(L, i->webview->ref);
    luaH_object_push(L, i->widget->ref);
    luaH_object_emit_signal(L, -2, "show-inspector", 1, 0);
    i->visible = TRUE;
    lua_pop(L, 1);
    return TRUE;
}

static gboolean
close_window_cb(WebKitWebInspector *inspector, inspector_t *i)
{
    (void) inspector;

    lua_State *L = globalconf.L;
    luaH_object_push(L, i->webview->ref);
    luaH_object_push(L, i->widget->ref);
    luaH_object_emit_signal(L, -2, "close-inspector", 1, 0);
    i->visible = FALSE;
    i->attached = FALSE;
    lua_pop(L, 1);
    return TRUE;
}

static gboolean
attach_window_cb(WebKitWebInspector *inspector, inspector_t *i)
{
    (void) inspector;

    lua_State *L = globalconf.L;
    luaH_object_push(L, i->webview->ref);
    luaH_object_push(L, i->widget->ref);
    luaH_object_emit_signal(L, -2, "attach-inspector", 1, 0);
    i->attached = TRUE;
    lua_pop(L, 1);
    return TRUE;
}

static gboolean
detach_window_cb(WebKitWebInspector *inspector, inspector_t *i)
{
    (void) inspector;

    lua_State *L = globalconf.L;
    luaH_object_push(L, i->webview->ref);
    luaH_object_push(L, i->widget->ref);
    luaH_object_emit_signal(L, -2, "detach-inspector", 1, 0);
    i->attached = FALSE;
    lua_pop(L, 1);
    return TRUE;
}

static gint
luaH_inspector_show(lua_State *L)
{
    inspector_t *i = luaH_checkudata(L, 1, &inspector_class);
    webkit_web_inspector_show(i->inspector);
    return 0;
}

static gint
luaH_inspector_close(lua_State *L)
{
    inspector_t *i = luaH_checkudata(L, 1, &inspector_class);
    webkit_web_inspector_close(i->inspector);
    return 0;
}

static gint
luaH_inspector_is_visible(lua_State *L, inspector_t *i)
{
    lua_pushboolean(L, i->visible);
    return 1;
}

static gint
luaH_inspector_is_attached(lua_State *L, inspector_t *i)
{
    lua_pushboolean(L, i->attached);
    return 1;
}

static gint
luaH_inspector_get_widget(lua_State *L, inspector_t *i)
{
    if (i->widget) {
        luaH_object_push(L, i->widget->ref);
    } else {
        lua_pushnil(L);
    }
    return 1;
}

inspector_t *
luaH_inspector_new(lua_State *L, widget_t *w)
{
    inspector_class.allocator(L);
    inspector_t *i = luaH_checkudata(L, -1, &inspector_class);

    i->ref = luaH_object_ref(L, -1);
    i->webview = w;
    i->widget = NULL;
    i->visible = FALSE;
    i->attached = FALSE;
    WebKitWebView *v = WEBKIT_WEB_VIEW(g_object_get_data(G_OBJECT(w->widget), "webview"));
    i->inspector = webkit_web_view_get_inspector(v);

    /* connect inspector signals */
    g_object_connect(G_OBJECT(i->inspector),
      "signal::inspect-web-view",            G_CALLBACK(inspect_webview_cb),   i,
      "signal::show-window",                 G_CALLBACK(show_window_cb),       i,
      "signal::close-window",                G_CALLBACK(close_window_cb),      i,
      "signal::attach-window",               G_CALLBACK(attach_window_cb),     i,
      "signal::detach-window",               G_CALLBACK(detach_window_cb),     i,
      NULL);

    return i;
}

void
luaH_inspector_destroy(lua_State *L, inspector_t *i) {
    luaH_object_unref(L, i->ref);
}

void
inspector_class_setup(lua_State *L)
{
    static const struct luaL_reg inspector_methods[] =
    {
        LUA_CLASS_METHODS(inspector)
        { NULL, NULL }
    };

    static const struct luaL_reg inspector_meta[] =
    {
        LUA_OBJECT_META(inspector)
        LUA_CLASS_META
        { "show", luaH_inspector_show },
        { "close", luaH_inspector_close },
        { NULL, NULL },
    };

    luaH_class_setup(L, &inspector_class, "inspector",
                     (lua_class_allocator_t) inspector_new,
                     luaH_class_index_miss_property, luaH_class_newindex_miss_property,
                     inspector_methods, inspector_meta);
    luaH_class_add_property(&inspector_class, L_TK_WIDGET,
                            (lua_class_propfunc_t) NULL,
                            (lua_class_propfunc_t) luaH_inspector_get_widget,
                            (lua_class_propfunc_t) NULL);
    luaH_class_add_property(&inspector_class, L_TK_ATTACHED,
                            (lua_class_propfunc_t) NULL,
                            (lua_class_propfunc_t) luaH_inspector_is_attached,
                            (lua_class_propfunc_t) NULL);
    luaH_class_add_property(&inspector_class, L_TK_VISIBLE,
                            (lua_class_propfunc_t) NULL,
                            (lua_class_propfunc_t) luaH_inspector_is_visible,
                            (lua_class_propfunc_t) NULL);
}

// vim: ft=c:et:sw=4:ts=8:sts=4:tw=80
