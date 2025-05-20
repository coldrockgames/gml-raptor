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

#macro __RAPTOR_EXPENSIVE_CACHE		global.__raptor_expensive_cache
__RAPTOR_EXPENSIVE_CACHE = {};

/// @func ExpensiveCache(_ttl = 1) constructor
/// @desc	Create a small cache holder for the result of expensive functions for
///					n frames.
function ExpensiveCache(_ttl = 1) constructor {
	ttl				= _ttl;
	valid			= false;
	alive_until		= GAME_FRAME + _ttl;
	return_value	= undefined;
	
	static is_valid = function() {
		valid &= (GAME_FRAME - alive_until < ttl);
		return valid;
	}
	
	static set = function(_return_value = undefined) {
		valid		 = true;
		return_value = _return_value;
		alive_until	 = GAME_FRAME + ttl;
		return return_value;
	}
	
	static get = function() {
		return return_value;
	}
	
}
