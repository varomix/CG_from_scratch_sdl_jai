#import "Basic";
#import "SDL";
#import "String";
#import "Math";

WIDTH :: 600;
HEIGHT :: 600;
VIEWPORT_SIZE :: 1;
PROJECTION_PLANE_Z :: 1;
NUM_SPHERES :: 3;
RED :: Vector4.{1, 0, 0, 1};
GREEN :: Vector4.{0, 1, 0, 1};
BLUE :: Vector4.{0, 0, 1, 1};
CYAN :: u8.[0, 255, 255, 255];
BACKGROUND_COLOR :: Vector4.{1, 1, 1, 1};

main :: () {

    SDL_Init(SDL_INIT_VIDEO);

    // Create an application window with the following settings:
    window := SDL_CreateWindow("An SDL2 window",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

    // Check that the window was successfully created
    if window == null {
        // In the case that the window could not be made...
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return;
    }
    renderer := SDL_CreateRenderer(window, -1, SDL_RendererFlags.ACCELERATED);
    if renderer == null {
    	print("Could not create renderer %\n", to_string(SDL_GetError() ));
    	return;
    }


    exit := false;
    while !exit {
        event : SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT;
                    exit = true;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE exit = true;
            }
        }
        SDL_RenderClear(renderer);

        // rect := SDL_Rect.{0, 0, 200, 200};
        // SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
        // SDL_RenderFillRect(renderer, *rect);
        // SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);

        for i:0..600 {
        	for j:0..600 {
		        draw_pixel(renderer, make_vector2(cast(float)i, cast(float)j), CYAN);
        	}
        }
         
        SDL_RenderPresent(renderer);
    }

    // Close and destroy the window
    SDL_DestroyWindow(window);

    // Clean up
    SDL_Quit();
}

Sphere :: struct {
	center : Vector3;
	radius : float;
	color  : Vector4;
}

draw_pixel :: (renderer :*SDL_Renderer, position : Vector2, color : [4]u8) {
    SDL_SetRenderDrawColor(renderer, color[0], color[1], color[2], color[3]);
    SDL_RenderDrawPoint(renderer, cast(s32)position.x, cast(s32)position.y);
    // reset to black after
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);

}

canvas_to_viewport :: (x : int, y : int) -> Vector3 {
	return Vector3.{ x * VIEWPORT_SIZE / cast(float)WIDTH, y * VIEWPORT_SIZE / cast(float)HEIGHT, PROJECTION_PLANE_Z };
}
