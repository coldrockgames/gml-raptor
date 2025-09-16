///@func ICollisionRadar(_name = "cradar")
function ICollisionRadar(_name = "cradar") : ISensor(_name) constructor {
	
	// raptor runtime values
	struct_enrich_into(other[$ $"__raptor_{_name}"], {
		list_id: ds_list_create(),
	});
	
	// radar definition
	struct_enrich_into(other[$ _name], {
		exclude_myself: true,
		precise_collision_masks: false,
		order_instances: false,
	});
	
	struct_set(other[$ $"__raptor_{_name}"], "check", function(_inst, _rradar, _radar) {
		var rv = {
			instances: [],
			collisions: [],
		};
		var targets = array_concat(_radar.target_instances, _radar.target_types);
		for (var i = 0, len = array_length(targets); i < len; ++i) {
			if (!instance_exists(targets[@i]))
				continue;
			with (_inst.id) collision_circle_list(x, y,
				_radar.radius,
				targets[@i],
				_radar.precise_collision_masks, 
				_radar.exclude_myself, 
				_rradar.list_id,
				_radar.order_instances
			);
		}
		var pos = new Coord2(_inst.x + _radar.offset[0], _inst.y + _radar.offset[1]);
		var instance = undefined;
		var distance = undefined;
		for (var i = 0, len = ds_list_size(_rradar.list_id); i < len; ++i) {
			instance = ds_list_find_value(_rradar.list_id, i);
			if (!array_contains(rv.instances, instance.id)) {
				distance = pos.distance_to_xy(instance.x, instance.y);
				array_push(rv.instances, instance.id);
				array_push(rv.collisions, _radar.detail_mode ? {
					is_collider_first: !array_contains(_rradar.instances, instance.id),
					other_cradar: instance.id,
					distance_to_other: distance,
					distance_to_border: _radar.radius - distance,
				} : instance);
			}
		}
		ds_list_clear(_rradar.list_id);
		return rv;
	});
}