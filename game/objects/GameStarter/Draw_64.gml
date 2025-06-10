/// @description draw spinner
if (wait_for_async_tasks || draw_spinner) {
	draw_sprite_ext(spinner_sprite,0,spinner_x,spinner_y,1,1,spinner_rotation,c_white,1);
	if (spinner_font != undefined) {
		draw_set_font(spinner_font);
		draw_text(
			spinner_x - string_width(spinner_text) - spinner_w / 2 - 16,
			spinner_y - string_height(spinner_text) / 2,
			spinner_text);
	}
}
