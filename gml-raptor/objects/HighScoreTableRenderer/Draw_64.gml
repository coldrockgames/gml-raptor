/// @desc 
event_inherited();
GUI_EVENT_DRAW_GUI;

if (__ensure_surface_is_ready()) 
	draw_surface(__surface, x - surfw * __align_h_multi, y - surfh * __align_v_multi);
