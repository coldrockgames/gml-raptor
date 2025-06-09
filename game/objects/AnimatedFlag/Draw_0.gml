/// @desc Draw vertex primitve
event_inherited();

ripple = wave_speed * (-current_time / 500) * (room_speed / animation_fps);

draw_primitive_begin_texture(pr_trianglestrip, texture);

for (i = 0; i <= running_vertices; i++) {
	// calculate current vertex
    vertex_index	= i / running_vertices;
    vertex_offset	= ripple + vertex_index * intensity;
    wave_offset		= wave_height * vertex_index;
	
	// vertext drawing positions
    vertex_x		= x - sprite_xoffset + scale_x * width * vertex_index;
    start_vertex_x	= vertex_x + scale_x * sin(vertex_offset) * wave_offset;
    end_vertex_x	= vertex_x + scale_x * cos(vertex_offset) * wave_offset;
    vertex_y		= y - sprite_yoffset + scale_y * sin(vertex_offset) * wave_offset;
    draw_width		= vertex_index * texture_width;
	
	// determine vertex color
	col_base		= 200 + (cos(vertex_offset) > 0 ? 0 : 55 * abs(cos(vertex_offset))); 
	col				= make_color_rgb(col_base, col_base, col_base);
	
	// draw
    draw_vertex_texture_color(start_vertex_x, vertex_y, draw_width, 0, col, image_alpha);
    draw_vertex_texture_color(end_vertex_x, vertex_y + scale_y * height, draw_width, texture_height, col, image_alpha);
}

draw_primitive_end();

