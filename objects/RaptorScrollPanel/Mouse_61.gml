/// @description event
event_inherited();

if ((mouse_drag_mode != mouse_drag.none || vertical_scrollbar) && mouse_over_content()) 
	__update_scroller(__vscroll, wheel_scroll_lines);
