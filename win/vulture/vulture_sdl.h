/* NetHack may be freely redistributed.  See license for details. */

/*-------------------------------------------------------------------
 vulture_sdl.h : SDL API calls for Vulture's windowing system.
 Uses SDL 2.
-------------------------------------------------------------------*/

#ifndef _vulture_sdl_h_
#define _vulture_sdl_h_

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

#include "SDL.h"

#define SDL_TIMEREVENT SDL_USEREVENT
#define SDL_MOUSEMOVEOUT (SDL_USEREVENT+1)

/* SDL2 window pointer */
extern SDL_Window *vulture_sdl_window;

/* SDL1->SDL2 key name compatibility defines */
#define SDLK_KP0 SDLK_KP_0
#define SDLK_KP1 SDLK_KP_1
#define SDLK_KP2 SDLK_KP_2
#define SDLK_KP3 SDLK_KP_3
#define SDLK_KP4 SDLK_KP_4
#define SDLK_KP5 SDLK_KP_5
#define SDLK_KP6 SDLK_KP_6
#define SDLK_KP7 SDLK_KP_7
#define SDLK_KP8 SDLK_KP_8
#define SDLK_KP9 SDLK_KP_9

#define SDLK_LMETA SDLK_LGUI
#define SDLK_RMETA SDLK_RGUI
#define KMOD_META KMOD_GUI

#define SDLK_PRINT SDLK_PRINTSCREEN
#define SDLK_SCROLLOCK SDLK_SCROLLLOCK
#define SDLK_NUMLOCK SDLK_NUMLOCKCLEAR
#define SDLK_COMPOSE SDLK_APPLICATION

/* SDL surface flag compatibility */
#define SDL_SRCALPHA 0
#define SDL_SWSURFACE 0

/* SDL1 mouse wheel button compat (SDL2 uses SDL_MOUSEWHEEL events instead) */
#define SDL_BUTTON_WHEELUP 4
#define SDL_BUTTON_WHEELDOWN 5

/* low-level event handling */
extern void vulture_wait_event(SDL_Event *event, int wait_timeout);
extern int vulture_poll_event(SDL_Event *event);
extern void vulture_wait_input(SDL_Event *event, int wait_timeout);
extern void vulture_wait_key(SDL_Event *event);

/* Graphics initialization and closing */
extern void vulture_enter_graphics_mode(void);
extern void vulture_exit_graphics_mode(void);

/* Display updaters */
extern void vulture_refresh(void);
extern void vulture_refresh_region(int, int, int, int);

/* Miscellaneous */
extern void vulture_set_screensize(void);


extern SDL_Surface *vulture_screen;

#endif
