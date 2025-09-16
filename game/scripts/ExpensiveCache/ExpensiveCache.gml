/*
    A simple cache for results of expensive functions to keep their result for n frames.
	
	Use it like this:
	* on class level define a variable like "mycache = new ExpensiveCache()"
	* by default the ttl (time to live) is 1, which means "only for this frame"
	* your expensive function should look like this:
	
	your_expensive_function = function() {
		if (mycache.is_valid())
			return mycache.return_value; // or just "return" if you don't have a value stored
			
		// ... do your expensive stuff ...
		
		return mycache.set(_return_value);  // or just .set() if you don't want to store a return value
	}
		
*/

/// @func	ExpensiveCache(_ttl = 1) constructor
/// @desc	Create a small cache holder for the result of expensive functions for
///			n frames.
function ExpensiveCache(_ttl = 1) constructor {
	ttl				= _ttl;
	valid			= false;
	alive_until		= GAME_FRAME + _ttl;
	return_value	= undefined;

	/// @func	is_valid() 
	/// @desc	Determine, whether this cache is valid
	static is_valid = function() {
		valid &= (GAME_FRAME - alive_until < ttl);
		return valid;
	}

	/// @func	set(_return_value = undefined) 
	/// @desc	Set the cache to be valid and assign a value
	///			This value is also returned to you, so you
	///			may use it as "return cache.set(val);" in your code
	static set = function(_return_value = undefined) {
		valid		 = true;
		return_value = _return_value;
		alive_until	 = GAME_FRAME + ttl;
		return return_value;
	}

	/// @func	get() 
	static get = function() {
		return return_value;
	}

	/// @func	invalidate() 
	/// @desc	Sets the cache to be invalid
	static invalidate = function() {
		valid		= false;
		alive_until	= GAME_FRAME - 1;
	}
	
}
