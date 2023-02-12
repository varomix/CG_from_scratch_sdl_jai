#import "Basic";
#import "SDL";
#import "String";
#import "Math";

WIDTH :: 600;
HEIGHT :: 600;
VIEWPORT_SIZE :: 1;
PROJECTION_PLANE_Z :: 1;
NUM_SPHERES :: 3;
RED :: u8.[255, 0, 0, 255];
GREEN :: u8.[0, 255, 0, 255];
BLUE :: u8.[0, 0, 255, 255];
CYAN :: u8.[0, 255, 255, 255];
BACKGROUND_COLOR :: u8.[255, 255, 255, 255];

Color :: [4]u8;

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

    camera_position := make_vector3(0, 0, 0);

    spheres := Sphere.[
        Sphere.{ Vector3.{ 0, -1, 3}, 1, RED },
        Sphere.{ Vector3.{ 2,  0, 4}, 1, BLUE },
        Sphere.{ Vector3.{-2,  0, 4}, 1, GREEN },
    ];

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

        for x:(-WIDTH / 2)..(WIDTH / 2) {
            for y:(-HEIGHT / 2)..(HEIGHT / 2) {
            	direction := canvas_to_viewport(x, y);
            	color := trace_ray(camera_position, direction, 1, FLOAT32_INFINITY, spheres);
                draw_pixel(renderer, make_vector2(cast(float)x, cast(float)y), color);
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
    color  : [4]u8;
}

draw_pixel :: (renderer :*SDL_Renderer, position : Vector2, color : [4]u8) {
    SDL_SetRenderDrawColor(renderer, color[0], color[1], color[2], color[3]);
    SDL_RenderDrawPoint(renderer, (WIDTH / 2) + cast(s32)position.x, (HEIGHT / 2) - cast(s32)position.y - 1);
    // reset to black after
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);

}

canvas_to_viewport :: (x : int, y : int) -> Vector3 {
    return Vector3.{ x * VIEWPORT_SIZE / cast(float)WIDTH, y * VIEWPORT_SIZE / cast(float)HEIGHT, PROJECTION_PLANE_Z };
}

intersect_ray_sphere :: (origin : Vector3, direction : Vector3, sphere : Sphere) -> Vector2 {
    oc := origin - sphere.center;
    k1 := dot_product(direction, direction);
    k2 := 2 * dot_product(oc, direction);
    k3 := dot_product(oc, oc) - sphere.radius * sphere.radius;
    
    discriminant := k2 * k2 - 4 * k1 * k3;
    if discriminant < 0 {
        return Vector2.{FLOAT32_INFINITY, FLOAT32_INFINITY};
    }

    t1 := (-k2 + sqrt(discriminant)) / (2.0 * k1);
    t2 := (-k2 - sqrt(discriminant)) / (2.0 * k1);
    return Vector2.{t1, t2};

}

trace_ray :: (origin : Vector3, direction : Vector3, t_min : float, t_max : float, spheres :[]Sphere) -> Color {
    closest_t := FLOAT32_INFINITY;
    closest_sphere : Sphere;
    sphere_found := false;

    for i: 0..NUM_SPHERES -1 {
        ts := intersect_ray_sphere(origin, direction, spheres[i]);
        if ts.x < closest_t && t_min < ts.x && ts.x < t_max {
            closest_t = ts.x;
            closest_sphere = spheres[i];
            sphere_found = true;
        }
        if ts.y < closest_t && t_min < ts.y && ts.y < t_max {
            closest_t = ts.y;
            closest_sphere = spheres[i];
            sphere_found = true;
        }
    }
    if sphere_found == false {
        return BACKGROUND_COLOR;
    }

    return closest_sphere.color;
}