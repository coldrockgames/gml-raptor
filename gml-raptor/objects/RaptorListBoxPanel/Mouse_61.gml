/// @desc scroll down
event_inherited();

GUI_EVENT_UNTARGETTED;

if (listbox != undefined && listbox.mouse_over_list_or_panel())
	wheel_scroll(1);
