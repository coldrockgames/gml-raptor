/// @desc event
event_inherited();

var _filename = async_load[? "filename"];
var _id = async_load[? "id"];

var cb = vsget(__async_list, string(_id));
if (cb != undefined) {
	with(cb) __async_image_received(_id);
	struct_remove(__async_list, string(_id));
	dlog($"{MY_NAME} received image '{_filename}', queue length now {__get_queue_length()}");
} else
	dlog($"{MY_NAME} received image '{_filename}'");

CollageImageAsync();

if (array_length(struct_get_names(__async_list)) == 0 && !COLLAGE.__any_collage_waiting())
	run_delayed_ex(self, 1, function() { 
		if (COLLAGE.__async_handler_finished()) {
			dlog($"{MY_NAME} shutting down");
			instance_destroy(self);
		}
	});
