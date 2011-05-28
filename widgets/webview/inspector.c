/*
 * widgets/webview/inspector.c - webview webinspector extension
 *
 * Copyright © 2011 Mason Larobina <mason.larobina@gmail.com>
 * Copyright © 2011 Fabian Streitel <karottenreibe@gmail.com>
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

#include "widgets/webview/inspector.h"

/* extension destructor */
static void
inspector_extension_destructor(webview_extension_t *e, webview_data_t *wd)
{
    (void) wd;

    g_slice_free(webview_extension_t, e);
}

/* registers methods on the webview */
static int
inspector_extension_index(webview_extension_t *e, webview_data_t *d, lua_State *L, luakit_token_t t)
{
    (void) e;
    (void) d;

    switch(t) {
      default:
        break;
    }

    return WEBVIEW_EXTENSION_NO_MATCH;
}

/**
 * Creates a new inspector extension that handles webframe events and makes them
 * available to Lua.
 */
webview_extension_t *
inspector_extension_new(webview_data_t *wd)
{
    (void) wd;

    webview_extension_t *e = g_slice_new(webview_extension_t);
    e->destructor = inspector_extension_destructor;
    e->index = inspector_extension_index;
    e->newindex = NULL;
    e->data = NULL;
    return e;
}

// vim: ft=c:et:sw=4:ts=8:sts=4:tw=80
