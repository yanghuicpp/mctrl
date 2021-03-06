/*
 * Copyright (c) 2014 Martin Mitas
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef MC_GENERIC_H
#define MC_GENERIC_H

#include "misc.h"
#include "theme.h"


/* "Generic" implementations of some standard control messages. */

static inline LRESULT
generic_paint(HWND win, BOOL no_redraw, BOOL doublebuffer,
              void (*func_paint)(void*, HDC, RECT*, BOOL),
              void* ctrl)
{
    PAINTSTRUCT ps;

    BeginPaint(win, &ps);
    if(!no_redraw) {
        if(doublebuffer)
            mc_doublebuffer(ctrl, &ps, func_paint);
        else
            func_paint(ctrl, ps.hdc, &ps.rcPaint, ps.fErase);
    }
    EndPaint(win, &ps);
    return 0;
}

static inline LRESULT
generic_printclient(HWND win, HDC dc,
                    void (*func_paint)(void*, HDC, RECT*, BOOL),  void* ctrl)
{
    RECT rect;

    GetClientRect(win, &rect);
    func_paint(ctrl, dc, &rect, TRUE);
    return 0;
}

LRESULT generic_ncpaint(HWND win, HTHEME theme, HRGN orig_clip);
LRESULT generic_erasebkgnd(HWND win, HTHEME theme, HDC dc);


#endif  /* MC_GENERIC_H */
