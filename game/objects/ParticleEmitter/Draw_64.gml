/// @desc manual particles
event_inherited();

if (visible && draw_on_gui && emitter_mode == emitter_render.local)
	part_system_drawit(__my_partsys.system);
