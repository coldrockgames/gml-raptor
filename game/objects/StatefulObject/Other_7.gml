/// @desc states.data.animation_end = true
event_inherited();
states.data.animation_end = true;

if (__single_sprite_animation_running) 
	__single_sprite_animation_finished();
