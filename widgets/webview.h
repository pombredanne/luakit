/*
 * widgets/webview.h - webkit webview widget header
 *
 * Copyright © 2010-2011 Mason Larobina <mason.larobina@gmail.com>
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

typedef struct {
    /** The parent widget_t struct */
    widget_t *widget;
    /** The webview widget */
    WebKitWebView *view;
    /** The GtkScrolledWindow for the webview widget */
    GtkScrolledWindow *win;
    /** Current webview uri */
    gchar *uri;
    /** Currently hovered uri */
    gchar *hover;
    /** Scrollbar hide signal id */
    gulong hide_id;
} webview_data_t;

#define luaH_checkwvdata(L, udx) ((webview_data_t*)(luaH_checkwebview(L, udx)->data))

widget_t* luaH_checkwebview(lua_State *L, gint udx);

