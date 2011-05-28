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

/* the data kept by this extension */
typedef struct {
    /* the webframes of the webview */
    GHashTable *frames;
} frames_extension_data_t;

/* callback wrapper type for \ref frame_destroyed_cb */
typedef struct {
    frames_extension_data_t *data;
    WebKitWebFrame *frame;
} frame_destroy_callback_t;

#define FRAME_DESTROY_CB_KEY "dummy-destroy-notify"

/* pushes all webframes from the given \ref frames_extension_data_t to the Lua stack */
static gint
luaH_webview_push_frames(lua_State *L, frames_extension_data_t *d)
{
    GHashTable *frames = d->frames;
    lua_createtable(L, g_hash_table_size(frames), 0);
    gint i = 1, tidx = lua_gettop(L);
    gpointer frame;
    GHashTableIter iter;
    g_hash_table_iter_init(&iter, frames);
    while (g_hash_table_iter_next(&iter, &frame, NULL)) {
        lua_pushlightuserdata(L, frame);
        lua_rawseti(L, tidx, i++);
    }
    return 1;
}

/* removes the frame from the \ref frames_extension_data_t */
static void
frame_destroyed_cb(frame_destroy_callback_t *st)
{
    /* the view might be destroyed before the frames */
    gpointer hash = st->data->frames;
    if (hash)
        g_hash_table_remove(hash, st->frame);
    g_slice_free(frame_destroy_callback_t, st);
}

/* adds the frame to the \ref frames_extension_data_t */
static void
document_load_finished_cb(WebKitWebView *v, WebKitWebFrame *f, webview_extension_t *e)
{
    (void) v;
    /* add a bogus property to the frame so we get notified when it's destroyed */
    frame_destroy_callback_t *st = g_slice_new(frame_destroy_callback_t);
    frames_extension_data_t *d = e->data;
    st->data = d;
    st->frame = f;
    /* don't insert while the view is being destroyed */
    if (d->frames) {
        g_object_set_data_full(G_OBJECT(f), FRAME_DESTROY_CB_KEY, st,
                (GDestroyNotify)frame_destroyed_cb);
        g_hash_table_insert(d->frames, f, NULL);
    }
}

/* steals the property that has the destruction callback attached.
 * This ensures the destructor of the frame is never called. */
static void
frame_destructor(gpointer f, gpointer v, gpointer data)
{
    (void) v;
    (void) data;

    /* ensure frame_destroyed_cb isn't called */
    g_object_steal_data(G_OBJECT(f), FRAME_DESTROY_CB_KEY);
}

/* safely destroys all frames, the hash table and the extension */
static void
frames_extension_destructor(webview_extension_t *e, webview_data_t *wd)
{
    (void) wd;

    /* destroy frames before webview, else frame_destroyed_cb will be called
     * after deallocation, causing segfaults */
    frames_extension_data_t *d = e->data;
    gpointer frames = d->frames;
    d->frames = NULL;
    g_hash_table_foreach(frames, frame_destructor, NULL);
    g_hash_table_destroy(frames);

    g_slice_free(frames_extension_data_t, e->data);
    g_slice_free(webview_extension_t, e);
}

/* registers \c frames as a getter on the webview */
static int
frames_extension_index(webview_extension_t *e, webview_data_t *d, lua_State *L, luakit_token_t t)
{
    (void) d;

    switch(t) {
      case L_TK_FRAMES:
        return luaH_webview_push_frames(L, e->data);

      default:
        break;
    }

    return WEBVIEW_EXTENSION_NO_MATCH;
}

/**
 * Creates a new frames extension that handles webframe events and makes them
 * available to Lua.
 */
webview_extension_t *
frames_extension_new(webview_data_t *wd)
{
    webview_extension_t *e = g_slice_new(webview_extension_t);
    e->destructor = frames_extension_destructor;
    e->index = frames_extension_index;
    e->newindex = NULL;
    frames_extension_data_t *d = g_slice_new(frames_extension_data_t);
    e->data = d;
    /* create frame table */
    d->frames = g_hash_table_new(g_direct_hash, g_direct_equal);
    /* register signals */
    g_object_connect(G_OBJECT(wd->view),
      "signal::document-load-finished",               G_CALLBACK(document_load_finished_cb),    e,
      NULL);
    return e;
}

// vim: ft=c:et:sw=4:ts=8:sts=4:tw=80
