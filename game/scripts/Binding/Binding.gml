/*
    holds one single bound property and its state.
	
	Allow a callback to be invoked when the bound value changes.
	This callback receives 2 arguments: new_value, old_value
*/

function __Binding(
	_prefix				= "",
	_myself				= undefined, 
	_my_property		= "", 
	_source_instance	= undefined, 
	_source_property	= "", 
	_converter			= undefined,
	_on_value_changed	= undefined) constructor {
	construct(__Binding);

	group_len			= 1;
	group_binding		= is_array(_my_property) || is_array(_source_property);
	if (group_binding) {
		if (!is_array(_my_property) || !is_array(_source_property))
			throw("Group binding requires both property arguments to be arrays.");
		var mylen = array_length(_my_property);
		var srlen = array_length(_source_property);
		if ((mylen == 0 && srlen == 0) || (mylen != 0 && srlen != 0 && mylen != srlen))
			throw("Group binding arrays must either match size or _source_property must be an empty array");
		if (mylen == 0) {
			_my_property = array_create(srlen);
			array_copy(_my_property, 0, _source_property, 0, srlen);
		} else if (srlen == 0) {
			_source_property = array_create(mylen);
			array_copy(_source_property, 0, _my_property, 0, mylen);
		}
		group_len = max(mylen, srlen); // whichever is > 0
	} else {
		_my_property = [ _my_property ];
		_source_property = [ _source_property ];
	}

	key = $"{_prefix}_{name_of(_myself)}.{_my_property}.{name_of(_source_instance)}";
	
	target_instance		= _myself;
	target_property		= _my_property;
	source_instance		= _source_instance;
	source_property		= _source_property;

	converter			= _converter;
	on_value_changed	= _on_value_changed;

	// when binding is set up, a change occurs from "undefined"->"initial value"
	// This flag prevents a "on_value_changed" from being invoked during set up.
	__first_change		= true;
	__value_buf			= undefined; // Buffers the old value for on_value_changed callback

	BINDINGS.add(self);

	if (DEBUG_LOG_BINDINGS)
		dlog($"{_prefix}_binding created: {name_of(target_instance ?? self)}.{target_property ?? source_property} is bound to {name_of(source_instance)}.{source_property}");
	
	__new_value = array_create(group_len, undefined);
	__old_value = array_create(group_len, undefined);
	__sp_runner = undefined;
	static update_binding = function() {
		for (var i = 0, len = array_length(source_property); i < len; i++) {
			__sp_runner = source_property[@i];
			__new_value[@i] = (converter != undefined ? 
				converter(__sp_runner, source_instance[$ __sp_runner], source_instance) : 
				source_instance[$ __sp_runner]);

			if (__new_value[@i] != __old_value[@i]) {
				target_instance[$ target_property[@i]] = __new_value[@i];
				__value_buf = __old_value[@i];
				__old_value[@i] = __new_value[@i];
				if (!__first_change && on_value_changed != undefined)
					on_value_changed(__sp_runner, __new_value[@i], __value_buf, source_instance);
				__first_change = false;
			}
		}
	}

	static unbind = function() {
		var cnt = BINDINGS.remove_where(function(bnd, key) { 
			return bnd.key == key; }, key);
		if (DEBUG_LOG_BINDINGS)
			dlog($"{cnt} Binding(s) removed: {name_of(target_instance ?? self)}.{target_property ?? source_property} from {name_of(source_instance)}.{source_property}");
	}
	
	toString = function() {
		return $"{name_of(source_instance)}.{source_property} -> {name_of(target_instance)}.{target_property}";
	}
}

function PushBinding(
	_myself				= undefined, 
	_my_property		= "", 
	_source_instance	= undefined, 
	_source_property	= "", 
	_converter			= undefined,
	_on_value_changed	= undefined,
	_prefix				= "push") : __Binding(
		_prefix, _myself, _my_property, _source_instance, _source_property, _converter, _on_value_changed) constructor {
	construct(PushBinding);
}
	
function PullBinding(
	_myself				= undefined, 
	_my_property		= "", 
	_source_instance	= undefined, 
	_source_property	= "", 
	_converter			= undefined,
	_on_value_changed	= undefined,
	_prefix				= "pull") : __Binding(
		_prefix,
		_myself, _my_property, 
		_source_instance, _source_property, 
		_converter, _on_value_changed) constructor {
	construct(PullBinding);
}
	
function WatcherBinding(
	_source_instance	= undefined, 
	_source_property	= undefined, 
	_on_value_changed	= undefined,
	_prefix				= "watcher") : 
	PushBinding(_source_instance, _source_property, _source_instance, _source_property,, _on_value_changed, _prefix) constructor {
	construct(WatcherBinding);
		
	static update_binding = function() {
		for (var i = 0, len = array_length(source_property); i < len; i++) {
			__sp_runner = source_property[@i];
			__new_value[@i] = source_instance[$ __sp_runner];

			if (__new_value[@i] != __old_value[@i]) {
				__value_buf = __old_value[@i];
				__old_value[@i] = __new_value[@i];
				if (on_value_changed != undefined)
					on_value_changed(__sp_runner, __new_value[@i], __value_buf, source_instance);
				__first_change = false;
			}
		}
	}
}