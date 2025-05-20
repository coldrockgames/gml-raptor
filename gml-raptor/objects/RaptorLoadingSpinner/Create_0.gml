/// @description rotate forever
event_inherited();

visible = visible_on_create;
image_angle = 0;
animation_run(self, 0, one_turn_frames, acLinearRotate, -1)
	.set_rotation_distance(-360)
	.add_finished_trigger(function() { image_angle = 0; });