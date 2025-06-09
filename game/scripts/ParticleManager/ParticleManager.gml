/*
	Create a particle manager in a Controller Object (like a RoomController)
	Specify the layer name where particles shall be created (that's the layer, the particle system will use).
	
	NOTE: You MUST call the cleanup function in the CleanUp event of the controller to avoid memory leaks!
	
*/

#macro __POOL_EMITTERS		"__particle_emitter_pool"

#macro __DEFAULT_EMITTER_OBJECT	ParticleEmitter

#macro PARTICLES			global.__raptor_particles
#macro ENSURE_PARTICLES		if (!variable_global_exists("__raptor_particles")) PARTICLES = {};
ENSURE_PARTICLES;

/// @func	ParticleManager(particle_layer_name)
/// @desc	Helps in organizing particles for a level
/// @param {string} particle_layer_name
/// @returns {struct} ParticleManager
function ParticleManager(particle_layer_name, system_index = 0) constructor {
	ilog($"ParticleManager created for layer '{particle_layer_name}'");
	system = part_system_create_layer(particle_layer_name, false);
	
	__emitter_object	= __DEFAULT_EMITTER_OBJECT;
	__layer_name		= particle_layer_name;
	__system_index		= system_index;
	__particle_types	= {};
	__emitters			= {};
	__emitter_ranges	= {};
	
	__buffered_delta	= {};
	__buffered_target	= {};
	
	/// @func	__resolve_emitter_name(name_or_emitter)
	static __resolve_emitter_name = function(name_or_emitter) {
		return is_string(name_or_emitter) ? name_or_emitter : name_or_emitter.emitter_name;
	}
	
	/// @func	set_emitter_object(_emitter_object)
	/// @desc	Set an object type to use when attaching or cloning emitters (default = ParticleEmitter)
	static set_emitter_object = function(_emitter_object) {
		__emitter_object = _emitter_object;
	}
	
	/// @func	reset_emitter_object()
	/// @desc	Reset the emitter object to the default ParticleEmitter
	static reset_emitter_object = function() {
		__emitter_object = __DEFAULT_EMITTER_OBJECT;
	}
	
	/// @func	particle_type_get(name)
	/// @desc	register (or get existing) part type for leak-free destroying at end of level
	static particle_type_get = function(name) {
		var rv = variable_struct_exists(__particle_types, name) ? struct_get(__particle_types, name) : part_type_create();
		struct_set(__particle_types, name, rv);
		return rv;
	}

	/// @func	particle_type_exists(name)
	static particle_type_exists = function(name) {
		return variable_struct_exists(__particle_types, name);
	}

	/// @func	particle_type_destroy(name)
	/// @desc	immediately destroy a particle type
	static particle_type_destroy = function(name) {
		if (variable_struct_exists(__particle_types, name)) {
			part_type_destroy(struct_get(__particle_types, name));
			variable_struct_remove(__particle_types, name);
		}
	}
	
	/// @func	emitter_get(name_or_emitter, default_particle_if_new = undefined)
	/// @desc	register (or get existing) emitter for leak-free destroying at end of level
	static emitter_get = function(name_or_emitter, default_particle_if_new = undefined) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		
		if (is_null(name_or_emitter)) return undefined;
		
		var rv = variable_struct_exists(__emitters, name_or_emitter) ? 
			struct_get(__emitters, name_or_emitter) : 
			new __emitter(part_emitter_create(system), default_particle_if_new);

		struct_set(__emitters, name_or_emitter, rv);
		rv.emitter_name = name_or_emitter;
		return rv;
	}
	
	/// @func	emitter_clone(name_or_emitter, new_name = undefined)
	/// @desc	clone an emitter (and its range) to a new name
	static emitter_clone = function(name_or_emitter, new_name = undefined) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		
		new_name = new_name ?? name_or_emitter + SUID;
		var origemi = emitter_get(name_or_emitter);
		var rv = emitter_get(new_name, origemi.default_particle);
		var orig = struct_get(__emitter_ranges, name_or_emitter);
		var rng = new __emitter_range(new_name).clone_from(orig);
		
		struct_set(__emitter_ranges, new_name, rng);
		return rv;
	}
	
	/// @func	emitter_attach(name_or_emitter, instance, layer_name_or_depth = undefined, particle_type_name = undefined, follow_this_instance = true, use_object_pools = true)
	/// @desc	Attach a new ParticleEmitter instance on the specified layer to an instance
	///			with optional follow-setting.
	///			NOTE: If you need more than one emitter of this kind, look at emitter_attach_clone
	static emitter_attach = function(name_or_emitter, instance, layer_name_or_depth = undefined, particle_type_name = undefined,
									 follow_this_instance = true, use_object_pools = true) {
		var ix  = __system_index;
		
		var xgui	= 0;
		var ygui	= 0;
		var is_gui = instance[$ "draw_on_gui"] ?? false;
		
		var xp	= instance.x + xgui;
		var yp	= instance.y + ygui;
		
		var init = {
			x				: xp,
			y				: yp,
			is_gui_draw		: is_gui,
			partsys_index	: ix,
			follow_instance	: follow_this_instance ? instance : undefined,
		};
		
		layer_name_or_depth = layer_name_or_depth ?? __layer_name;
		var rv	= use_object_pools ?
			pool_get_instance(__POOL_EMITTERS, __emitter_object, layer_name_or_depth, init) :
			instance_create(xp, yp, layer_name_or_depth, __emitter_object, init);

		with(rv) if (stream_on_create) stop(); // stop for now - you don't have a particle!

		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var emi = emitter_get(name_or_emitter);
		emitter_move_range_to(name_or_emitter, xp, yp);
		particle_type_name = particle_type_name ?? emi.default_particle;

		with(rv) {
			emitter_name			= name_or_emitter;
			__my_emitter			= name_or_emitter;
			stream_particle_name	= particle_type_name;
			burst_particle_name		= particle_type_name;
			
			if (stream_on_create) rv = stream(); // NOW you may stream!
		}	
		
		if (DEBUG_LOG_PARTICLES)
			dlog($"Emitter '{name_or_emitter}' created at {xp}/{yp} {__emitter_ranges[$ name_or_emitter]}");
		
		return rv;
	}
	
	/// @func	emitter_attach_clone(name_or_emitter, instance, layer_name_or_depth = undefined, particle_type_name = undefined, follow_this_instance = true, use_object_pools = true)
	/// @desc	Attach a clone of an existing emitter to a new ParticleEmitter instance 
	///			on the specified layer to an instance with optional follow-setting.
	static emitter_attach_clone = function(name_or_emitter, instance, layer_name_or_depth = undefined, particle_type_name = undefined, 
										   follow_this_instance = true, use_object_pools = true) {
		return emitter_attach(emitter_clone(name_or_emitter), instance, layer_name_or_depth, particle_type_name, follow_this_instance, use_object_pools);
	}
	
	/// @func	emitter_exists(name)
	static emitter_exists = function(name) {
		return variable_struct_exists(__emitters, name);
	}

	/// @func	emitter_set_range(name_or_emitter, xmin, xmax, ymin, ymax, shape, distribution)
	/// @desc	Set the range of an emitter
	static emitter_set_range = function(name_or_emitter, xmin, xmax, ymin, ymax, shape, distribution) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var emi = emitter_get(name_or_emitter); // creates the emitter if it does not exist
		var rng = struct_get(__emitter_ranges, name_or_emitter) ?? 
			new __emitter_range(name_or_emitter).with_values(
				xmin, xmax, ymin, ymax, 
				shape, distribution
			);
		rng.minco.set(xmin, ymin);
		rng.maxco.set(xmax, ymax);
		rng.eshape = shape;
		rng.edist = distribution;
		part_emitter_region(system, emi.emitter, xmin, xmax, ymin, ymax, shape, distribution);
		struct_set(__emitter_ranges, name_or_emitter, rng);
	}

	/// @func	emitter_move_range_by(name_or_emitter, xdelta, ydelta)
	/// @desc	Move the range of the emitter by the specified delta, keeping its size, shape and distribution.
	///			Use this, if an emitter shall follow another object on screen (like the mouse cursor)
	static emitter_move_range_by = function(name_or_emitter, xdelta, ydelta) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var rng = struct_get(__emitter_ranges, name_or_emitter);
		if (rng == undefined) {
			if (DEBUG_LOG_PARTICLES)
				dlog($"Buffering range_by for '{name_or_emitter}', until the range exists!");
			struct_set(__buffered_delta, name_or_emitter, new Coord2(xdelta, ydelta));
			return;
		}
		__buffered_delta = undefined;
		rng.minco.add(xdelta, ydelta);
		rng.maxco.add(xdelta, ydelta);
		part_emitter_region(system, emitter_get(name_or_emitter).emitter, rng.minco.x, rng.maxco.x, rng.minco.y, rng.maxco.y, rng.eshape, rng.edist);
	}

	/// @func	emitter_move_range_to(name_or_emitter, newx, newy)
	/// @desc	Move the range of the emitter a new position, keeping its shape and distribution.
	///			Use this, if an emitter shall follow another object on screen (like the mouse cursor)
	static emitter_move_range_to = function(name_or_emitter, newx, newy) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var rng = struct_get(__emitter_ranges, name_or_emitter);
		if (rng == undefined) {
			if (DEBUG_LOG_PARTICLES)
				dlog($"Buffering range_to for '{name_or_emitter}', until the range exists!");
			struct_set(__buffered_target, name_or_emitter, new Coord2(newx, newy));
			return;
		}
		variable_struct_remove(__buffered_target, name_or_emitter);
		var diff = rng.maxco.clone2().minus(rng.minco);
		rng.minco.set(rng.baseminco.x + newx, rng.baseminco.y + newy);
		rng.maxco = rng.minco.clone2().plus(diff);
		part_emitter_region(system, emitter_get(name_or_emitter).emitter, rng.minco.x, rng.maxco.x, rng.minco.y, rng.maxco.y, rng.eshape, rng.edist);
	}

	/// @func	emitter_scale_to(name_or_emitter, instance)
	/// @desc	scales the emitter range to a specified object instance
	static emitter_scale_to = function(name_or_emitter, instance) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var rng = struct_get(__emitter_ranges, name_or_emitter);
		if (rng != undefined)
			rng.scale_to(instance);
	}
	
	/// @func	emitter_scale_to_factor(name_or_emitter, _xscale, _yscale)
	/// @desc	scales the emitter range to a specified factor in x and y
	static emitter_scale_to_factor = function(name_or_emitter, _xscale, _yscale) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var rng = struct_get(__emitter_ranges, name_or_emitter);
		if (rng != undefined)
			rng.scale_to_factor(_xscale, _yscale);
	}

	/// @func	emitter_get_range_min(name_or_emitter)
	/// @desc	Gets the min coordinates of an emitter as Coord2 or Coord2(-1,-1) if not found
	static emitter_get_range_min = function(name_or_emitter) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var rng = struct_get(__emitter_ranges, name_or_emitter);
		return (rng != undefined ? rng.minco : new Coord2(-1, -1));
	}

	/// @func	emitter_get_range_max(name_or_emitter)
	/// @desc	Gets the max coordinates of an emitter as Coord2 or Coord2(-1,-1) if not found
	static emitter_get_range_max = function(name_or_emitter) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var rng = struct_get(__emitter_ranges, name_or_emitter);
		return (rng != undefined ? rng.maxco : new Coord2(-1, -1));
	}

	/// @func	emitter_destroy(name_or_emitter)
	/// @desc	immediately destroy an emitter
	static emitter_destroy = function(name_or_emitter) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		if (variable_struct_exists(__emitters, name_or_emitter)) {
			var emitter = struct_get(__emitters, name_or_emitter).emitter;
			part_emitter_clear(system, emitter);
			part_emitter_destroy(system, emitter);
			variable_struct_remove(__emitters, name_or_emitter);
		}
		if (variable_struct_exists(__emitter_ranges, name_or_emitter)) {
			variable_struct_remove(__emitters, name_or_emitter);
		}
	}

	/// @func	cleanup()
	/// @desc	you MUST call this in the cleanup event of your controller!
	static cleanup = function() {
		var names = struct_get_names(__particle_types);
		var i = 0; repeat(array_length(names)) {
			if (variable_struct_exists(__particle_types, names[i]) && 
				struct_get   (__particle_types, names[i]) != undefined) {
				part_type_destroy(struct_get(__particle_types, names[i]));
				struct_set(__particle_types, names[i], undefined);
			}
			i++;
		}
		__particle_types = {};

		if (part_system_exists(system)) {
			names = struct_get_names(__emitters);
			i = 0; repeat(array_length(names)) {
				if (variable_struct_exists(__emitters, names[i]) && 
					struct_get(__emitters, names[i]) != undefined) {
					var emitter = struct_get(__emitters, names[i]).emitter;
					part_emitter_clear(system, emitter);
					part_emitter_destroy(system, emitter);
					struct_set(__emitters, names[i], undefined);
				}
				i++;
			}
			part_system_destroy(system);
		}
		
		__emitters = {};
		__emitter_ranges = {};
	}
	
	/// @func	__apply_buffering()
	static __apply_buffering = function(name) {
		var r = struct_get(__buffered_target, name);
		if (r != undefined) {
			emitter_move_range_to(name, r.x, r.y);
			if (DEBUG_LOG_PARTICLES) {
				if (variable_struct_exists(__buffered_target, name))
					vlog($"range_to buffering applied successfully");
				else
					dlog($"range_to buffering apply FAILED");
			}
		}
		r = struct_get(__buffered_delta, name);
		if (r != undefined) {
			emitter_move_range_by(name, r.x, r.y);
			if (DEBUG_LOG_PARTICLES) {
				if (variable_struct_exists(__buffered_delta, name))
					vlog($"range_by buffering applied successfully");
				else
					dlog($"range_by buffering apply FAILED");
			}
		}
	}
	
	/// @func	stream(name_or_emitter, particles_per_frame = 1, particle_name = undefined)
	/// @desc	start streaming particles at a specified rate
	static stream = function(name_or_emitter, particles_per_frame = 1, particle_name = undefined) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		__apply_buffering(name_or_emitter);
		var emi = emitter_get(name_or_emitter);
		part_emitter_stream(system, 
			emi.emitter, 
			particle_type_get(particle_name ?? emi.default_particle), 
			particles_per_frame);
	}
	
	/// @func	stream_at(xpos, ypos, name_or_emitter, particles_per_frame = 1, particle_name = undefined)
	/// @desc	start streaming particles at a specified rate and at a specified coordinate
	///			ATTENTION! This method will move the emitter range to the specified coordinates!
	static stream_at = function(xpos, ypos, name_or_emitter, particles_per_frame = 1, particle_name = undefined) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		__apply_buffering(name_or_emitter);
		emitter_move_range_to(name_or_emitter, xpos, ypos);
		stream(name_or_emitter, particles_per_frame, particle_name);
	}

	/// @func	stream_stop(name_or_emitter)
	/// @desc	stop streaming particles.
	///			ATTENTION! You must setup part_emitter_region again if this
	///			emitter is going to be reused in the future!
	static stream_stop = function(name_or_emitter) {
		if (!part_system_exists(system))
			return;
			
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var emi = emitter_get(name_or_emitter).emitter;
		if (emi != undefined) {
			part_emitter_clear(system, emi);
			var rng = struct_get(__emitter_ranges, name_or_emitter);
			if (rng != undefined)
				part_emitter_region(system, emi, rng.minco.x, rng.maxco.x, rng.minco.y, rng.maxco.y, rng.eshape, rng.edist);
		}
	}
	
	/// @func	burst(name_or_emitter, particle_count = 32, particle_name = undefined)
	/// @desc	one time particle explosion burst
	static burst = function(name_or_emitter, particle_count = 32, particle_name = undefined) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		var emi = emitter_get(name_or_emitter);
		__apply_buffering(name_or_emitter);
		part_emitter_burst(system, 
			emi.emitter, 
			particle_type_get(particle_name ?? emi.default_particle), 
			particle_count);
	}

	/// @func	burst_at(xpos, ypos, name_or_emitter, particle_count, particle_name)
	/// @desc	one time particle explosion burst at a specified coordinate
	///			ATTENTION! This method will move the emitter range to the specified coordinates!
	static burst_at = function(xpos, ypos, name_or_emitter, particle_count = 32, particle_name = undefined) {
		name_or_emitter = __resolve_emitter_name(name_or_emitter);
		__apply_buffering(name_or_emitter);
		emitter_move_range_to(name_or_emitter, xpos, ypos);
		burst(name_or_emitter, particle_count, particle_name);
	}

	/// @func	spawn_particles(xpos, ypos, particle_count, particle_name)
	/// @desc	spawn particles at a specified position without an emitter
	static spawn_particles = function(xpos, ypos, particle_count, particle_name) {
		part_particles_create(system, xpos, ypos,
			particle_type_get(particle_name), particle_count);
	}
}

function __emitter(part_emitter, default_particle_name = "") constructor {
	emitter = part_emitter;
	emitter_name = "";
	default_particle = default_particle_name;
}

function __emitter_range(name) constructor {
	ename = name;
	
	ctor		= undefined;
	center		= undefined;
	minco		= undefined;
	maxco		= undefined;
	baseminco	= undefined;
	basemaxco	= undefined;
	eshape		= undefined;
	edist		= undefined;
	
	static clone_from = function(_original) {
		ctor		= {
			minco: _original.ctor.minco.clone2(),
			maxco: _original.ctor.maxco.clone2()
		};
		center		= _original.center.clone2();
		minco		= _original.minco.clone2();
		maxco		= _original.maxco.clone2();
		baseminco	= _original.baseminco.clone2();
		basemaxco	= _original.basemaxco.clone2();
		eshape		= _original.eshape;
		edist		= _original.edist;
		return self;
	}
	
	/// @func with_values(xmin, xmax, ymin, ymax, shape, distribution)
	static with_values = function(xmin, xmax, ymin, ymax, shape, distribution) {
		ctor = {
			minco: new Coord2(xmin, ymin),
			maxco: new Coord2(xmax, ymax)
		};
		center = new Coord2((xmax - xmin) / 2, (ymax - ymin) / 2);
		minco = new Coord2(xmin, ymin);
		maxco = new Coord2(xmax, ymax);
		baseminco = minco.clone2();
		basemaxco = maxco.clone2();
		eshape = shape;
		edist = distribution;
		return self;
	}
	
	/// @func		scale_to(_instance)
	static scale_to = function(_instance) {
		minco.set(ctor.minco.x * _instance.image_xscale, ctor.minco.y * _instance.image_yscale);
		maxco.set(ctor.maxco.x * _instance.image_xscale, ctor.maxco.y * _instance.image_yscale);
		center.set((maxco.x - minco.x) / 2, (maxco.y - minco.y) / 2);
		baseminco.set(minco.x, minco.y);
		basemaxco.set(maxco.x, maxco.y);
	}

	/// @func	scale_to_factor(_xscale, _yscale)
	static scale_to_factor = function(_xscale, _yscale) {
		minco.set(ctor.minco.x * _xscale, ctor.minco.y * _yscale);
		maxco.set(ctor.maxco.x * _xscale, ctor.maxco.y * _yscale);
		center.set((maxco.x - minco.x) / 2, (maxco.y - minco.y) / 2);
		baseminco.set(minco.x, minco.y);
		basemaxco.set(maxco.x, maxco.y);		
	}
	
	toString = function() {
		return $"{minco} - {maxco}";
	}
}
