/// @desc async image list
event_inherited();

__async_list = {};

__get_queue_length = function() {
	return array_length(struct_get_names(__async_list));
}

/// @func	wait_for_sprite(_sprite_id, _callback)
wait_for_sprite = function(_sprite_id, _callback) {
	__async_list[$ string(_sprite_id)] = _callback;
	dlog($"{MY_NAME} waiting for sprite {_sprite_id}, queue length now {__get_queue_length()}");
}

