/// @desc gain focus & cursor pos

GUI_EVENT_MOUSE;

event_inherited();
var had_focus = __RAPTORDATA.has_focus;
set_focus();
if (had_focus || !select_all_on_focus)
	__set_cursor_pos_from_click();

