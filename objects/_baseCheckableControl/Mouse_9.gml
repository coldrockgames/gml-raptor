/// @desc set image_index_default

GUI_EVENT_MOUSE;

if (__auto_change_checked) set_checked(!checked);
event_inherited();
if (mouse_is_over) __set_over_image(); else __set_default_image();
