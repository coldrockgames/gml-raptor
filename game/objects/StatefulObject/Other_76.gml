/// @desc event
event_inherited();

if (event_data[? "event_type"] == "sprite event") {
	var msg = event_data[? "message"];
	var ele = event_data[? "element_id"];
	if (layer_get_element_type(ele) == layerelementtype_instance) {
		var inst = layer_instance_get_instance(ele);
		if (inst != -1 && inst.id == id)
			states.set_state(string_concat("bc:", string_trim(msg)));
	}
}
