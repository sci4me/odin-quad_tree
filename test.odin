package quad_tree

import "core:fmt"
import "core:os"
import "core:math/rand"

import sdl "shared:odin-sdl2"

SIZE :: 600;

fail :: proc(s: string, args: ..any) -> ! {
	fmt.printf(s, ..args);
	os.exit(1);
}

main :: proc() {
    if sdl.init(.Video | .Events) != 0 do fail("Failed to initialize SDL: %s\n", sdl.get_error());
	defer sdl.quit();

    window := sdl.create_window("test", i32(sdl.Window_Pos.Undefined), i32(sdl.Window_Pos.Undefined), SIZE, SIZE, sdl.Window_Flags(0));
	if window == nil do fail("Failed to create window: %s\n", sdl.get_error());

    renderer := sdl.create_renderer(window, -1, .Present_VSync);
	if renderer == nil do fail("Failed to create renderer: %s\n", sdl.get_error());

    qt := make_quad_tree(Rect(i32){0, 0, SIZE, SIZE}, 0, i32, 3, 4);
    insert_timer := 0;
    inserted := 0;

    running := true;
	for running {
		sdl.pump_events();

		e: sdl.Event;
		for sdl.poll_event(&e) != 0 && running {
			if e.type == sdl.Event_Type.Quit {
				running = false;
			}
		}

        sdl.set_render_draw_color(renderer, 0, 0, 0, 255);
		sdl.render_clear(renderer);

        // TODO
        
        insert_timer += 1;
        if(insert_timer == 10 && inserted < 256) {
            insert_timer = 0;
            inserted += 1;
            
            x, y := rand.int31_max(SIZE), rand.int31_max(SIZE);
            w, h := (rand.int31_max(5) + 3) * 5, (rand.int31_max(5) + 3) * 5;
            insert(qt, Rect(i32){x, y, w, h}, rand.int31());
        }

        draw_quad_tree(qt, renderer);

        sdl.render_present(renderer);
    }
}

draw_quad_tree :: proc(qt: ^Quad_Tree(i32, i32), r: ^sdl.Renderer) {
    nodes := make([dynamic]Quad_Tree_Node(i32, i32));
    defer delete(nodes);
    query(qt, Rect(i32){0, 0, SIZE, SIZE}, &nodes);

    zones := make([dynamic]Rect(i32));
    defer delete(zones);
    get_zones(qt, &zones);

    sdl.set_render_draw_color(r, 0x00, 0xFF, 0x00, 0xFF);
    for node in nodes {
        using node.zone;
        sdl.render_draw_line(r, x, y, x + w, y);
        sdl.render_draw_line(r, x, y + h, x + w, y + h);
        sdl.render_draw_line(r, x, y, x, y + h);
        sdl.render_draw_line(r, x + w, y, x + w, y + h);
    }

    sdl.set_render_draw_color(r, 0x00, 0x00, 0xFF, 0xFF);
    for zone in zones {
        using zone;
        sdl.render_draw_line(r, x, y, x + w, y);
        sdl.render_draw_line(r, x, y + h, x + w, y + h);
        sdl.render_draw_line(r, x, y, x, y + h);
        sdl.render_draw_line(r, x + w, y, x + w, y + h);
    }
}