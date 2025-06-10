/*
    A bindable struct
	
	This is a small convenience class, more or less an empty struct, which only
	consists of a (private) __raptor_binder member and a __raptor_parent member.
	
	The binder is only initialized, when you invoke the binder() method, so no
	memory overhead compared to a regular struct, but it is bindable when you need it.
	
*/

/// @func Bindable(_parent)
function Bindable(_parent = undefined) constructor {
	construct(Bindable);
	
	__raptor_parent = _parent;
	__raptor_binder = undefined;
	
	/// @func binder_initialized()
	/// @desc Checks, whether a binder has been created in this instance
	static binder_initialized = function() {
		return __raptor_binder != undefined;
	}
	
	/// @func binder()
	/// @desc Gets the PropertyBinder for this struct. Initialized on first access
	static binder = function() {
		__raptor_binder = __raptor_binder ?? new PropertyBinder(self, __raptor_parent);
		return __raptor_binder;
	}
	
	/// @func parent()
	/// @desc return the parent of this binder, to keep navigating
	///				 in the builder pattern
	static parent = function() {
		return __raptor_parent;
	}
	
	toString = function() {
		return string_concat("Bindable ",
			(__raptor_binder != undefined ? __raptor_binder.toString() : "<not initialized>"),
		);
	}
	
}