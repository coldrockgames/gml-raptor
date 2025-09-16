/*

	Object pools are a way to avoid creating hundreds or even thousands of objects over
	and over again.
	You request an object from a pool and return it to the pool when you no longer need it.
	So, new instances are only created, when no free instances in the pool exist.
	
	You create a pool by simply specifying (or using the first time) a name.
	Each pool can in theory hold any object, but it is recommended that you set up "theme pools",
	like "Bullets", "Explosions", ... because you then have a finer control over destroyed objects
	when you clear/delete a pool.

	Activation/Deactivation events (callbacks)
	------------------------------------------
	If you want your pooled instances to get informed when they got activated or are about
	to become deactivated, you can declare these instance variable functions:
	onPoolActivate   = function() {...}
	onPoolDeactivate = function() {...}
	
	The object pool will invoke those members, if they exist after activation and
	before deactivation respectively.

	(c)2022 coldrock.games, @grisgram at github
*/

#macro __POOL_SOURCE_NAME				"__object_pool_name"
#macro __POOL_ACTIVATE_RAPTOR_NAME		"__raptor_onPoolActivate"
#macro __POOL_DEACTIVATE_RAPTOR_NAME	"__raptor_onPoolDeactivate"
#macro __POOL_ACTIVATE_NAME				"onPoolActivate"
#macro __POOL_DEACTIVATE_NAME			"onPoolDeactivate"

#macro __OBJECT_POOLS					global.__object_pools
__OBJECT_POOLS = {};

function __get_pool_list(pool_name) {
	if (!struct_exists(__OBJECT_POOLS, pool_name)) {
		if (DEBUG_LOG_OBJECT_POOLS)
			dlog($"Creating new object pool '{pool_name}'");
		struct_set(__OBJECT_POOLS, pool_name, []);
	}
	
	return __OBJECT_POOLS[$ pool_name];
}

/// @func	pool_get_instance(pool_name, object, layer_name_or_depth_if_new, _init_struct = undefined)
/// @desc	Gets (or creates) an instance for the specified pool.
///			NOTE: To return an instance later to a pool, it must have been created with this function!
///			In the rare case, you need to manually assign an already existing instance
///			to a pool, use the function pool_assign_instance(...)
///			The optional _struct will be applied as struct_join_into(...) of the activated object,
///			in the same as init structs work on newly created instances.
///			In addition, it is sent as argument to onPoolActivate (which gets called ALWAYS,
///			no matter if this is a fresh instance or resurrected from a pool),
///			so you can see, which data has been applied to the instance.
/// @returns {instance}
function pool_get_instance(pool_name, object, layer_name_or_depth_if_new, _struct = undefined) {
	var pool = __get_pool_list(pool_name);
	var i = 0; repeat(array_length(pool)) {
		var rv = pool[@i];
		if (rv != undefined && rv.object_index == object) {
			if (DEBUG_LOG_OBJECT_POOLS)
				vlog($"Found instance of '{object_get_name(object)}' in pool '{pool_name}'");
			instance_activate_object(rv);
			var xp = vsget(self, "x", 0) ?? 0;
			var yp = vsget(self, "y", 0) ?? 0;
			with(rv) {
				x = xp;
				y = yp;
			}
			pool[@i] = undefined;
			__pool_invoke_activate(rv, _struct);
			return rv;
		}
		i++;
	}
	
	if (DEBUG_LOG_OBJECT_POOLS)
		vlog($"Creating new instance of '{object_get_name(object)}' in pool '{pool_name}'");
	var xp = vsget(self, "x", 0) ?? 0;
	var yp = vsget(self, "y", 0) ?? 0;
	var rv = instance_create(xp, yp, layer_name_or_depth_if_new, object);
	struct_set(rv, __POOL_SOURCE_NAME, pool_name);
	__pool_invoke_activate(rv, _struct);
	return rv;
}

/// @func	pool_return_instance(instance = self, _struct = undefined)
/// @desc	Returns a previously fetched instance back into its pool
///			An optional _struct may be supplied as parameter to the onPoolDeactivate callback.
function pool_return_instance(instance = self, _struct = undefined) {
	if (vsget(instance, __POOL_SOURCE_NAME) != undefined) {
		var pool_name = instance[$ __POOL_SOURCE_NAME];
		with (instance)
			if (DEBUG_LOG_OBJECT_POOLS)
				vlog($"Sending instance '{MY_NAME}' back to pool '{pool_name}'");
		__pool_invoke_deactivate(instance, _struct);
		var pool = __get_pool_list(pool_name);
		instance_deactivate_object(instance);
		var haveone = false;
		for (var i = 0, len = array_length(pool); i < len; i++) {
			if (pool[@i] == undefined || pool[@i] == instance) {
				pool[@i] = instance;
				haveone = true;
				break;
			}
		}
		
		if (!haveone)
			array_push(pool, instance);
		return;
	}
	elog($"** ERROR ** Tried to return instance to a pool, but this instance was not aquired from a pool!");
}

/// @func	pool_return_or_destroy(instance = self, _struct = undefined)
/// @desc	In highly dynamic games, it may occur, that you don't know whether a specific
///			instance has been aquired from a pool or not. In this case, this function is very handy,
///			because it checks, if it's possible to return it to its pool, or just destroy it.
function pool_return_or_destroy(instance = self, _struct = undefined) {
	if (pool_is_assigned(instance))
		pool_return_instance(instance, _struct);
	else
		instance_destroy(instance);
}

/// @func	pool_is_assigned(instance = self)
/// @desc	Checks, whether the instance has a pool assign (i.e. "pool_return_instance" may be used)
function pool_is_assigned(instance = self) {
	return (vsget(instance, __POOL_SOURCE_NAME) != undefined);
}

/// @func	pool_assign_instance(pool_name, instance)
/// @desc	Assign an instance to a pool so it can be returned to it.
/// @param {string} pool_name
/// @param {instance} instance
function pool_assign_instance(pool_name, instance) {
	struct_set(instance, __POOL_SOURCE_NAME, pool_name);
}

/// @func	pool_get_size(pool_name)
/// @desc	Gets current size of the pool
function pool_get_size(pool_name) {
	return array_length(__get_pool_list(pool_name));
}

/// @func	pool_clear(pool_name)
/// @desc	Clears a named pool and destroys all instances contained
/// @param {string} pool_name
function pool_clear(pool_name) {
	var pool = __get_pool_list(pool_name);
	var i = 0; repeat(array_length(pool)) {
		var inst = pool[@ i++];
		instance_activate_object(inst);
		instance_destroy(inst);
	}
	__OBJECT_POOLS[$ pool_name] = [];
}

/// @func	pool_dump_all()
/// @desc	Dumps the names and sizes of all registered pools to the log
function pool_dump_all() {
	var sb = new StringBuilder(512);
	var i = 0;
	sb.append_line($"[--- OBJECT POOLS DUMP START ---]");
	var names = struct_get_names(__OBJECT_POOLS);
	for (var i = 0, len = array_length(names); i < len; i++) {
		var name = names[@i];
		sb.append_line($"{array_length(__OBJECT_POOLS[$ name])} in pool {name}");
	}
	sb.append($"[--- OBJECT POOLS DUMP  END  ---]");
	var rv = sb.toString();
	ilog(rv);
	return rv;
}

/// @func	pool_clear_all()
/// @desc	Clear all pools. Use this when leaving the room.
///			NOTE: The ROOMCONTROLLER automatically does this for you in the RoomEnd event
function pool_clear_all() {
	__OBJECT_POOLS = {};
}

function __pool_invoke_activate(inst, _struct) {
	with (inst) {
		__statemachine_pause_all(self, false);
		invoke_if_exists(self, __POOL_ACTIVATE_RAPTOR_NAME);
		if (_struct != undefined) 
			struct_join_into(self, _struct);
		invoke_if_exists(self, __POOL_ACTIVATE_NAME, _struct);
	}
}

function __pool_invoke_deactivate(inst, _struct) {
	with (inst) {
		__statemachine_pause_all(self, true);
		animation_abort_all(self);
		BROADCASTER.remove_owner(inst);
		invoke_if_exists(self, __POOL_DEACTIVATE_RAPTOR_NAME);
		invoke_if_exists(self, __POOL_DEACTIVATE_NAME, _struct);
	}
}
