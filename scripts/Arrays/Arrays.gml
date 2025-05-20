/*
    Helper functions for arrays
*/

/// @func		array_create_2d(sizex, sizey, initial_value = 0)
/// @desc	Create a 2-dimensional array and fill it with a specified initial value
function array_create_2d(sizex, sizey, initial_value = 0) {
	var rv = array_create(sizex);
	for (var i = 0; i < sizex; i++)
		rv[@ i] = array_create(sizey, initial_value);
	return rv;
}

/// @func		array_create_3d(sizex, sizey, sizez, initial_value = 0)
/// @desc	Create a 3-dimensional array and fill it with a specified initial value
function array_create_3d(sizex, sizey, sizez, initial_value = 0) {
	var rv = array_create(sizex);
	for (var i = 0; i < sizex; i++) {
		var arr = array_create(sizey);
		rv[@ i] = arr;
		for (var j = 0; j < sizey; j++)
			arr[@ j] = array_create(sizez, initial_value);
	}
	return rv;
}

/// @func		array_copy_2d(array)
/// @desc	Copy any 2-dimensional array
function array_copy_2d(array) {
	if (!is_array(array)) return array;
	var rv = [];
	for (var i = 0, len = array_length(array); i < len; i++) {
		rv[@i] = [];
		array_copy(rv[@i],0,array[@i],0,array_length(array[@i]));
	}
	return rv;
}

/// @func		array_copy_3d(array)
/// @desc	Copy any 3-dimensional array
function array_copy_3d(array) {
	if (!is_array(array)) return array;
	var rv = [];
	for (var i = 0, len = array_length(array); i < len; i++) {
		var inner2 = [];
		var source2 = array[@i];
		for (var j = 0, len2 = array_length(source2); j < len2; j++) {
			inner2[@j] = []
			array_copy(inner2[@j],0,source2[@j],0,array_length(source2[@j]));
		}
		rv[@i] = inner2;
	}
	return rv;
}

/// @func		array_clear(array, with_value = undefined)
/// @desc	Clear the contents of the array to undefined or a specified default value
///					This function detects the dimensions of the array and can clear 1d, 2d, 3d arrays
///					recursively. If you do not want that and force inner arrays to be overwritten
///					(like resetting the 2nd dimension of an array back to empty arrays), set the 
///					recursive parameter to false.
/// @param {array}	array		The array to clear
/// @param {bool}	with_value	The value to set
/// @param {bool}	recursive	Detect sub-dimensions yes/no
/// @returns {array}		Cleaned array (same as input parameter, for chaining)
function array_clear(array, with_value = undefined, recursive = true) {
	var i = 0; repeat(array_length(array)) {
		var sub = array[@ i];
		if (recursive && is_array(sub))
			array_clear(sub, with_value, recursive);
		else
			array[@ i] = with_value;
		i++;
	}
	return array;
}

/// @func		array_shuffle_raptor(array)
/// @desc	Shuffles the given array, randomizing the position of its items
///					NOTE: GameMaker now offers internal array_shuffle and array_shuffle_ext methods!
///					So, this method is quite obsolete, but I keep it in here in case, you can't do
///					something you want to do with the internal methods.
/// @param {array} array	The array to shuffle
/// @returns {array}		Re-ordered array (same as input parameter, for chaining)
/// @obsolete
function array_shuffle_raptor(array) {
    var len = array_length(array),
        random_index = 0,
        value;

    while(len > 0){
		len--;
        random_index = irandom(len);
        
        value = array[@ len];
        array[len] = array[@ random_index];
        array[@ random_index] = value;
    }

	return array;
}

/// @func		array_pick_random(array, number = 1)
/// @desc	Picks any number of random entries of an array
///					TAKE CARE! If you set number higher than size of the array
///					a copy of the array is returned, containing simply all items
/// @returns		If number=1 the picked item is returned, otherwise an array of items
function array_pick_random(array, number = 1) {
	var rv = [];
	var len = array_length(array);
	if (number >= len) {
		rv = array_create(len);
		array_copy(rv,0,array,0,len);
	} else {
		var hit = [];
		var idx;
		repeat(number) {
			do {
				idx = irandom_range(0, len - 1);
			} until (!array_contains(hit, idx));
			array_push(hit, idx);
		}
		for (var i = 0, len = array_length(hit); i < len; i++) {
			idx = hit[@i];
			array_push(rv, array[@ idx]);
		}
	}
	return (number == 1 ? rv[@ 0] : rv);
}

/// @func		array_null_or_empty(array)
/// @desc	Returns whether the variable is undefined or an empty array
///					or not an array at all
function array_null_or_empty(array) {
	return (array == undefined || !is_array(array) || array_length(array) == 0);
}

/// @func		array_contains_recursive(array, value, recursive = true)
/// @desc	Searches the array for the specified value.
/// @param {array} array	The array to search
/// @param {any} value		The value to find
/// @returns {bool}			True, if value is contained in array, otherwise false
function array_contains_recursive(array, value, recursive = true) {
	if (array_null_or_empty(array))
		return false;
		
	var val;
	for (var i = 0, len = array_length(array); i < len; i++) {
		val = array[@ i];
		if (val == value ||
			(recursive && is_array(val) && array_contains_recursive(val, value, recursive)))
			return true;
	}
	return false;
}

/// @func		array_remove(array, value)
/// @desc	Removes the specified value from the array, if it exists.
///					If value is not part of the array, the attempt is silently ignored.
/// @param {array} array	The array to search
/// @param {any} value		The value to remove
/// @returns {bool}			True, if value was contained in array, otherwise false
function array_remove(array, value) {
	var idx = array_get_index(array, value);
	if (idx != -1) {
		array_delete(array, idx, 1);
		return true;
	}
	return false;
}