/*
 * widgets/webview/frames.c - webview webframes extension
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

#include "widgets/webview/frames.h"

typedef struct {
} frames_extension_data_t;

static void
frames_extension_destructor(webview_extension_t *e, webview_data_t *d)
{
    g_free(e->data);
    g_free(e);
}

static int
frames_extension_index(webview_extension_t *e, webview_data_t *d, lua_State *L, luakit_token_t t)
{
}

static int
frames_extension_newindex(webview_extension_t *e, webview_data_t *d, lua_State *L, luakit_token_t t)
{
}

webview_extension_t *
frames_extension_new(webview_data_t *d)
{
    webview_extension_t *e = g_slice_new(webview_extension_t);
    e->destructor = frames_extension_destructor;
    e->index = frames_extension_index;
    e->newindex = frames_extension_newindex;
    e->data = g_slice_new(frames_extension_data_t);
    return e;
}

