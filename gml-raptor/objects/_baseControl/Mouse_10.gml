/// @desc mouse_is_over=true
event_inherited();
GUI_EVENT_MOUSE;

if (!mouse_is_over && !__mouse_events_locked) {
	vlog($"{MY_NAME}: onMouseEnter");
	mouse_is_over = true;
	__animate_draw_color(draw_color_mouse_over);
	__animate_text_color(text_color_mouse_over);
	force_redraw(false);
	invoke_if_exists(self, "on_mouse_enter", self);
}
