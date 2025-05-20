/// @desc draw outline if mouse is over
event_inherited();

GUI_EVENT_DRAW;
if (sprite_index != -1) __draw();
