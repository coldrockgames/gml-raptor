///@func IRadar(_name = "radar")
function IRadar(_name = "radar") : ISensor(_name) constructor {
	struct_set(other[$ $"__raptor_{_name}"], "check", function(_inst, _rradar, _radar) {
		var rv = {
			instances: [],
			collisions: [],
		};
		var pos = new Coord2(_inst.x + _radar.offset[0], _inst.y + _radar.offset[1]);
		var distance = undefined;
		with (_raptorBase) {
			if (self.id == _inst.id || array_contains(rv.instances, self.id)
				|| (!array_contains(_radar.target_types, asset_get_index(MY_OBJECT_NAME)) && !array_contains(_radar.target_instances, self.id)))
				continue;
			distance = pos.distance_to_xy(x, y);
			if (distance < _radar.radius) {
				array_push(rv.instances, self.id);
				array_push(rv.collisions, _radar.detail_mode ? {
					is_collider_first: !array_contains(_rradar.instances, self.id),
					other_radar: self.id,
					distance_to_other: distance,
					distance_to_border: _radar.radius - distance,
				} : self.id);
			}
		}
		return rv;
	});
}
