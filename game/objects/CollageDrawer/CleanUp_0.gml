/// @desc event
event_inherited();

if (!__is_parent)
	ds_list_destroy(__collision_list);
	
if (__collider != undefined && instance_exists(__collider)) {
	instance_destroy(__collider);
	__collider = undefined;
}