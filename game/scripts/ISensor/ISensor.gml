#macro __RAPTOR_BC_SENSOR_ENTER						".enter"
#macro __RAPTOR_BC_SENSOR_STEP						".step"
#macro __RAPTOR_BC_SENSOR_LEAVE						".leave"

#macro BC_SENSOR_ENTER								$"sensor{__RAPTOR_BC_SENSOR_ENTER}"
#macro BC_SENSOR_STEP								$"sensor{__RAPTOR_BC_SENSOR_STEP}"
#macro BC_SENSOR_LEAVE								$"sensor{__RAPTOR_BC_SENSOR_LEAVE}"

#macro BC_RADAR_ENTER								$"radar{__RAPTOR_BC_SENSOR_ENTER}"
#macro BC_RADAR_STEP								$"radar{__RAPTOR_BC_SENSOR_STEP}"
#macro BC_RADAR_LEAVE								$"radar{__RAPTOR_BC_SENSOR_LEAVE}"

#macro BC_COLLISION_RADAR_ENTER						$"cradar{__RAPTOR_BC_SENSOR_ENTER}"
#macro BC_COLLISION_RADAR_STEP						$"cradar{__RAPTOR_BC_SENSOR_STEP}"
#macro BC_COLLISION_RADAR_LEAVE						$"cradar{__RAPTOR_BC_SENSOR_LEAVE}"

/*
	Sensory Interfaces
	
	- ISensor for general event-driven collision awareness.
	- IRadar for fast, lightweight proximity checks.
	- ICollisionRadar for precise, mask-based collision needs.
	
	Each sensor is enriched with default properties:

	- is_enabled (bool): Whether the sensor is active. Default: true.
	- detail_mode (bool): Whether to store rich collision data or just IDs. Default: true.
	- interval (number): Update interval (steps between checks). Default: 5.
	- radius (number): Detection radius. Default: 30.
	- offset (array [x,y]): Position offset relative to the instance. Default: [0, 0].
	- target_instances (array): Specific instances to detect.
	- target_types (array): Object types to detect.
*/

///@func ISensor(_name = "sensor")
function ISensor(_name = "sensor") constructor {
	ctor {
		__raptor_sensor_check();
		struct_remove(self, "__raptor_sensor_current_name");
	}
	
	// raptor runtime values
	__raptor_sensor_current_name = _name;
	var sensor_instance = other;
	vsgetx(sensor_instance, $"__raptor_{_name}", {
		name: _name,
		has_detection: false,
		instances: [],
		collisions: [],
	});
	
	// sensor definition
	struct_enrich_into(vsgetx(other, _name, {}), {
		is_enabled: true,
		detail_mode: true,
		interval: 5,
		radius: 30,
		offset: [0, 0],
		target_instances: [],
		target_types: [],
	});
	
	__raptor_sensor_check = function(
		_raptor_sensor = self[$ $"__raptor_{__raptor_sensor_current_name}"], 
		_sensor = self[$ __raptor_sensor_current_name]
	) {
		run_delayed(self, _sensor.interval, function(_data) {
			var rsen = _data.raptor_sensor;
			var sen	 = _data.sensor;
			
			if (!instance_exists(self))
				return;
			if (!sen.is_enabled) {
				__raptor_sensor_check(rsen, sen);
				return;
			}
			
			var next = rsen.check(self.id, rsen, sen);
		
			for (var i = 0, len = array_length(next.instances); i < len; ++i) {
				if (next.collisions[@i].is_collider_first) {
					invoke_if_exists(sen, "on_enter", next.collisions[@i]);
					BROADCASTER.send(self, $"{rsen.name}{__RAPTOR_BC_SENSOR_ENTER}", next.collisions[@i]);
				} else {
					invoke_if_exists(sen, "on_step", next.collisions[@i]);
					BROADCASTER.send(self, $"{rsen.name}{__RAPTOR_BC_SENSOR_STEP}", next.collisions[@i]);
					array_remove(rsen.instances, next.instances[@i]);
					array_remove(rsen.collisions, next.collisions[@i]);
				}
			}
			for (var i = 0, len = array_length(rsen.instances); i < len; ++i) {
				invoke_if_exists(sen, "on_leave", rsen.collisions[@i]);
				BROADCASTER.send(self, $"{rsen.name}{__RAPTOR_BC_SENSOR_LEAVE}", rsen.collisions[@i]);
			}
			
			rsen.instances = next.instances;
			rsen.collisions = next.collisions;
			
			__raptor_sensor_check(rsen, sen);
		}, { raptor_sensor: _raptor_sensor, sensor: _sensor })
	}
	
	if (struct_exists(sensor_instance, $"__raptor_{_name}")) {
		struct_set(sensor_instance[$ $"__raptor_{_name}"], "check", function(_inst, _rsen, _sen) {
			var rv = {
				instances: [],
				collisions: [],
			};
			var pos = new Coord2(_inst.x + _sen.offset[0], _inst.y + _sen.offset[1]);
			var r1_plus_r2 = undefined;
			var distance = undefined;
			with (_raptorBase) {
				if (!implements(self, ISensor) || self.id == _inst.id
					|| array_contains(rv.instances, self.id) 
					|| (!array_contains(_sen.target_types, asset_get_index(MY_OBJECT_NAME)) && !array_contains(_sen.target_instances, self.id)))
					|| !struct_exists(self, _rsen.name)
					continue;
				distance = pos.distance_to_xy(x + self[$ _rsen.name].offset[0], y + self[$ _rsen.name].offset[1]);
				r1_plus_r2 = _sen.radius + self[$ _rsen.name].radius;
				if (distance < r1_plus_r2) {
					array_push(rv.instances, self.id);
					array_push(rv.collisions, _sen.detail_mode ? {
						is_collider_first: !array_contains(_rsen.instances, self.id),
						other_sensor: self.id,
						distance_to_other: distance,
						overlap_distance: r1_plus_r2 - distance,
					} : self.id);
				}
			}
			return rv;
		});
	}
}