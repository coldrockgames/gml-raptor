/// @desc set image_index_default

GUI_EVENT_MOUSE;

event_inherited();
if (mouse_is_over) __set_over_image(); else __set_default_image();

