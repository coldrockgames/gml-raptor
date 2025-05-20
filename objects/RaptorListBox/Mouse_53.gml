/// @desc close if outside
event_inherited();

GUI_EVENT_UNTARGETTED;

// local event triggers before global event
if (is_open && !mouse_over_list_or_panel())
	close_list();
