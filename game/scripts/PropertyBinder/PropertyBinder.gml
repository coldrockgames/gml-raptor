/*
    The binder is instantiated in every _raptorBase as "binder".
	You can bind *any* property or value of the instance to *any* source, even struct sources, not only instances!
	A binder can bind any number of properties, you do NOT need multiple instances per object.
	If the data-types do not match (like binding "text" to the x-position of some object),
	a "ValueConverter" function may be supplied.
	
	This function receives the value as argument and must return the converted/formatted value,
	so that the binding target can accept it.
	
	About the _parent constructor parameter:
	You can use this, to "tweak" the return value of the "parent()" function.
	By default, the parent is the same as "myself", but in cases, where this PropertyBinder is
	bound to a Bindable() struct, you might want to return the instance holding the Bindable, and
	not just the Bindable. Like parent.parent. 
*/

#macro BINDINGS	global.__BINDINGS
BINDINGS		= new ListPool("BINDINGS");

#macro STRING_TO_NUMBER_CONVERTER	function(_value) { return real(_value); }
#macro NUMBER_TO_STRING_CONVERTER	function(_value) { return string(_value); }

function PropertyBinder(_myself = undefined, _parent = undefined) constructor {
	construct(PropertyBinder);
	
	__source_bindings = {};
	__bindings = {};
	
	__parent = _parent ?? _myself; 
	
	myself = _myself;
	
	/// @func bind_pull(_my_property, _source_instance, _source_property, _converter = undefined, _on_value_changed = undefined)
	/// @desc Bind my property to RECEIVE the value from _source_instance._source_property
	///				 ("pull" the value)
	static bind_pull = function(_my_property, _source_instance, _source_property, 
						   _converter = undefined, _on_value_changed = undefined) {
		var bnd = new PullBinding(
			myself, _my_property, 
			_source_instance, _source_property, 
			_converter,
			_on_value_changed);
		
		__bindings[$ bnd.key] = bnd;
		if (vsget(_source_instance, "binder") != undefined)
			_source_instance.binder.__source_bindings[$ bnd.key] = bnd;
		return self;
	}
	
	/// @func bind_push(_my_property, _target_instance, _target_property, _converter = undefined, _on_value_changed = undefined)
	/// @desc Bind my property to SET the value of _target_instance._target_property
	///				 ("push" the value).
	///				 This function is especially useful, if you want to push one of your instance
	///			     properties to a struct, that does not have a "binder" member and therefore can't
	///				 pull bindings.
	static bind_push = function(_my_property, _target_instance, _target_property, 
						   _converter = undefined, _on_value_changed = undefined) {
		var bnd = new PushBinding(
			_target_instance, _target_property, 
			myself, _my_property, 
			_converter,
			_on_value_changed);
		
		__source_bindings[$ bnd.key] = bnd;
		if (vsget(_target_instance, "binder") != undefined && !is_method(_target_instance.binder))
			_target_instance.binder.__bindings[$ bnd.key] = bnd;
		return self;
	}
	
	/// @func bind_watcher(_my_property, _on_value_changed)
	/// @desc Binds only a function on value change to a property. This is useful, if you
	///				 do not want to mirror the bound value to any other member, but just get informed,
	///				 when the watched value changes. The callback receives two arguments:
	///				 (new_value, old_value)
	static bind_watcher = function(_my_property, _on_value_changed) {
		var bnd = new WatcherBinding(myself, _my_property, _on_value_changed);
		__source_bindings[$ bnd.key] = bnd;
		return self;
	}
	
	/// @func unbind(_my_property, key)
	static unbind = function(_my_property, key) {
		for (var i = 0; i < 2; i++) {
			var pre = (i == 0 ? "push" : "pull");
			var bnd = vsget(__bindings, key);
			if (bnd != undefined) {
				if (vsget(bnd.source_instance, "binder") != undefined && !is_method(bnd.source_instance.binder)) {
					if (DEBUG_LOG_BINDINGS)
						dlog($"Removing remote source-binding from {name_of(bnd.source_instance)}.{_my_property}");
					variable_struct_remove(bnd.source_instance.binder.__source_bindings, key);
				}
				variable_struct_remove(__bindings, key);
				with(bnd) unbind();
			}
			var src = vsget(__source_bindings, key);
			if (src != undefined) {
				if (vsget(src.target_instance, "binder") != undefined && !is_method(src.target_instance.binder)) {
					if (DEBUG_LOG_BINDINGS)
						dlog($"Removing local source-binding from {name_of(src.target_instance)}.{_my_property}");
					variable_struct_remove(src.target_instance.binder.__source_bindings, key);
				}
				variable_struct_remove(__source_bindings, key);
				with(src) unbind();
			}
		}
		return self;
	}
	
	/// @func unbind_source()
	/// @desc Unbind me, where this is the SOURCE (inverse direction)
	static unbind_source = function() {
		var names = struct_get_names(__source_bindings);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var key = names[@i];
			var src = __source_bindings[$ key];
			if (vsget(src, "target_instance") != undefined &&
				vsget(src.target_instance, "binder") != undefined && 
				!is_method(src.target_instance.binder)) {
				with(src.target_instance)
					if (vsget(binder.__bindings, key) != undefined)
						binder.unbind(binder.__bindings[$ key].target_property, key);
					else if (vsget(binder.__source_bindings, key) != undefined)
						binder.unbind(binder.__source_bindings[$ key].target_property, key);
			} else
				with(src) unbind(); // struct push binding
			variable_struct_remove(__source_bindings, key);
		}
	}
	
	/// @func unbind_all()
	static unbind_all = function() {
		unbind_source();
		var names = struct_get_names(__bindings);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var key = names[@i];
			unbind(__bindings[$ key].target_property, key);
		}
		return self;
	}
	
	/// @func parent()
	/// @desc return the parent of this binder, to keep navigating
	///				 in the builder pattern
	static parent = function() {
		return __parent;
	}
	
	toString = function() {
		return string_concat(
			"PropertyBinder ", name_of(myself), " <-> ", name_of(__parent)
		);
	}
}
