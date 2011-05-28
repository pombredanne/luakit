/*
 * widgets/webview/extension.h - webview extension framework header
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

#ifndef LUAKIT_WIDGET_H
#define LUAKIT_WIDGET_H

#include "widgets/webview.h"

/**
 * Returned by the \ref index and \ref noindex functions of an extension if
 * nothing was matched.
 */
#define WEBVIEW_EXTENSION_NO_MATCH -1

typedef struct _webview_extension_t webview_extension_t;

/** Extension for the webview widget */
struct _webview_extension_t {
    /**
     * Extension destruction function
     *
     * Called from the webview destructor.
     * Must also free the extension itself.
     */
    void (*destructor)(webview_extension_t *, webview_data_t *);
    /**
     * Extension for luaH_webview_index
     *
     * @return WEBVIEW_EXTENSION_NO_MATCH if it didn't match and the number of
     *         pushed arguments otherwise.
     */
    int (*index)(webview_extension_t *, webview_data_t *, lua_State* L, luakit_token_t);
    /**
     * Extension for luaH_webview_newindex
     *
     * @return WEBVIEW_EXTENSION_NO_MATCH if it didn't match and the number of
     *         pushed arguments otherwise.
     */
    int (*newindex)(webview_extension_t *, webview_data_t *, lua_State* L, luakit_token_t);
    /** Custom private data of the extension */
    gpointer data;
};

#endif

// vim: ft=c:et:sw=4:ts=8:sts=4:tw=80
