/*
	LinqArray - Utility struct/class to work with arrays in a Linq style
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// one-liner return functions
#macro ifun function(item,data) { return 
#macro efun ;}

function LinqArray(size = 0, initial_value = undefined) constructor {
	construct(LinqArray);
	
	array = array_create(size, initial_value);

	/// @func get_array()
	/// @desc get the entire array. Alternatively you can access .array directly
	static get_array = function() {
		return array;
	}

	/// @func get_index_in_range()
	/// @desc get an index in range of the array
	static get_index_in_range = function(index) {
		var len = length();
		while (index < 0) index += len;
		if (index >= len) index %= len;
		return index;
	}

	/// @func get()
	/// @desc get the item at position index
	static get = function(index) {
		if (length() == 0) 
			return undefined;
		var idx = get_index_in_range(index);
		return array[@ idx];
	}

	/// @func length()
	/// @desc get the length of the array
	static length = function() {
		return array_length(array);
	}
	
	/// @func clear(with_value = undefined)
	/// @desc clear the entire array with a value
	static clear = function(with_value = undefined) {
		var i = 0; repeat(length()) {
			array[@ i] = with_value;
			i++;
		}
		return self;
	}
	
	/// @func sort(sort_type_or_function)
	/// @desc sort the array. true/false for ascending/descending or a comparator function. see official docs at
	///              https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FVariable_Functions%2Farray_sort.htm
	static sort = function(sort_type_or_function) {
		array_sort(array, sort_type_or_function);
		return self;
	}
	
	/// @func reverse()
	/// @desc reverse the array
	static reverse = function() {
		var len = length();
		var val;
		var i = 0; repeat(floor(len / 2)) {
			val = array[@ i];
			array[@ i] = array[@ len - i - 1];
			i++;
			array[@ len - i] = val;
		}
		return self;
	}
	
	/// @func shuffle()
	/// @desc randomly shuffle an array. more passes = more randomization but also more run time
	static shuffle = function() {
		var len = length(), 
			random_index = 0,
			value;
		while(len != 0){
			len--;
			random_index = irandom(len);
		
			value = array[@ len];
			array[@ len] = array[@ random_index];
			array[@ random_index] = value;
		}
		return self;
	}
	
	/// @func insert(index, values)
	/// @desc insert values at position index into the array. multiple arguments allowed. see official docs at
	///              https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FVariable_Functions%2Farray_insert.htm
	static insert = function(index, values) {
		var i = 1; repeat(argument_count - 1) {
			array_insert(array, index + i - 1, argument[i]);
			i++;
		}
		return self;
	}
	
	/// @func push(values)
	/// @desc push values at the end into the array. multiple arguments allowed. see official docs at
	///             https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FVariable_Functions%2Farray_push.htm
	static push = function(values) {
		var i = 0; repeat(argument_count) {
			array_push(array, argument[i]);
			i++;
		}
		return self;
	}
	
	/// @func pop()
	/// @desc get the last value of the array and reduce its size by 1. see official docs at
	///              https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FVariable_Functions%2Farray_pop.htm
	static pop = function() {
		return array_pop(array);
	}
	
	/// @func remove(index, count = 1)
	/// @desc remove count items at position index from that array an reduce its size. see official docs at
	///              https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FVariable_Functions%2Farray_delete.htm
	static remove = function(index, count = 1) {
		array_delete(array, index, count);
		return self;
	}
	
	/// @func equals(other_array)
	/// @param {array or LinqArray} other_array
	/// @desc checks if the contents OR the reference equals to the other_array. see official docs at
	///              https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FVariable_Functions%2Farray_equals.htm
	static equals = function(other_array) {
		var comp = is_array(other_array) ? other_array : other_array.array;
		return array == comp || array_equals(array, comp);
	}
	
	/// @func first_index_of(value)
	/// @desc get the first index of the specified value or undefined, if it is not contained in the array
	static first_index_of = function(value) {
		var i = 0; repeat(length()) {
			if (array[@ i] == value) 
				return i;
			i++;
		}
		return undefined;
	}

	/// @func last_index_of(value)
	/// @desc get the lst index (this is the first index, counting backwards from the end of the array)
	///				 of the specified value or undefined, if it is not contained in the array
	static last_index_of = function(value) {
		var len = length();
		var i = len - 1; repeat(len) {
			if (array[i--] == value) return i + 1;
		}
		return undefined;
	}
	
	/// @func contains(value)
	/// @desc True, if the specified value is contained in the array
	static contains = function(value) {
		return first_index_of(value) != undefined;
	}
	
	/// @func clone()
	/// @desc get a new LinqArray containing a (snap) deep copy of this LinqArray
	static clone = function() {
		var rv = new LinqArray();
		rv.array = deep_copy(array);
		return rv;
	}
	
	/// @func minval(accessor_function = undefined, data = undefined)
	/// @desc Find the lowest value. if accessor_function is undefined, values are compared directly, otherwise
	///				 the return value of the accessor_function on both values is compared.
	///				 Use the accessor if you array contains structs and you want to find the lowest value of one of the
	///				 struct members.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the accessor_function, if specified
	///				 Example: Your array contains structs like {name:"abc", "age":33}
	///				 To find the minimum age your accessor looks like function acc(item) {return item.age;}
	static minval = function(accessor_function = undefined, data = undefined) {
		var rv = 0;
		var first_check = true;
		
		var i = 0; repeat(length()) {
			var val = (accessor_function == undefined ? array[i] : accessor_function(array[i], data));
			if (first_check || val < rv) 
				rv = val;
			first_check = false;
			i++;
		}
		return rv;
	}
	
	/// @func maxval(accessor_function = undefined, data = undefined)
	/// @desc Find the highest value. if accessor_function is undefined, values are compared directly, otherwise
	///				 the return value of the accessor_function on both values is compared.
	///				 Use the accessor if you array contains structs and you want to find the highest value of one of the
	///				 struct members.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the accessor_function, if specified
	///				 Example: Your array contains structs like {name:"abc", "age":33}
	///				 To find the maximum age your accessor looks like function acc(item) {return item.age;}
	static maxval = function(accessor_function = undefined, data = undefined) {
		var rv = 0;
		var first_check = true;
		
		var i = 0; repeat(length()) {
			var val = (accessor_function == undefined ? array[i] : accessor_function(array[i], data));
			if (first_check || val > rv) 
				rv = val;
			first_check = false;
			i++;
		}
		return rv;
	}
	
	/// @func sum(accessor_function = undefined, data = undefined)
	/// @desc Sum all values. if accessor_function is undefined, values are calculated directly, otherwise
	///				 the return value of the accessor_function is calculated.
	///				 Use the accessor if you array contains structs and you want to find the average value of one of the
	///				 struct members.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the accessor_function, if specified
	///				 Example: Your array contains structs like {name:"abc", "age":33}
	///				 To find the total age your accessor looks like function acc(item) {return item.age;}
	static sum = function(accessor_function = undefined, data = undefined) {
		var rv = 0;
		
		var i = 0; repeat(length()) {
			rv += (accessor_function == undefined ? array[i] : accessor_function(array[i], data));
			i++;
		}
			
		return rv;
	}

	/// @func avg(accessor_function = undefined, data = undefined)
	/// @desc Find the average value. if accessor_function is undefined, values are calculated directly, otherwise
	///				 the return value of the accessor_function is calculated.
	///				 Use the accessor if you array contains structs and you want to find the average value of one of the
	///				 struct members.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the accessor_function, if specified
	///				 Example: Your array contains structs like {name:"abc", "age":33}
	///				 To find the average age your accessor looks like function acc(item) {return item.age;}
	static avg = function(accessor_function = undefined, data = undefined) {
		return sum(accessor_function, data) / length();
	}

	/// @func where(condition_function, data = undefined)
	/// @desc Perform a Linq-Where query on the array and return a new LinqArray containing the filtered data
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static where = function(condition_function, data = undefined) {
		var rv = new LinqArray();
		var i = 0; repeat(length()) {
			if (condition_function(array[i], data)) 
				rv.push(array[i]);
			i++;
		}
		return rv;
	}
	
	/// @func is_any(condition_function, data = undefined)
	/// @desc True, if the condition_function returned true on an item
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static is_any = function(condition_function, data = undefined) {
		var i = 0; repeat(length()) {
			if (condition_function(array[i], data)) 
				return true;
			i++;
		}
				
		return false;
	}
	
	/// @func are_all(condition_function, data = undefined)
	/// @desc True, if the condition_function returned true on an item
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static are_all = function(condition_function, data = undefined) {
		var i = 0; repeat(length()) {
			if (!condition_function(array[i], data)) 
				return false;
			i++;
		}
		return true;
	}

	/// @func count(condition_function, data = undefined)
	/// @desc counts the occurrences where condition_function returns true
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static count = function(condition_function, data = undefined) {
		var rv = 0;
		var i = 0; repeat(length()) {
			if (condition_function(array[i], data)) rv++;
			i++;
		}
		return rv;
	}

	/// @func select(selector_function, data = undefined)
	/// @desc Get a new LinqArray containing all returns values from the selector.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the selector_function, if specified
	///				 Example: You can select only the "age" from an array of structs {name:"abc", age:33}
	///				 with a selector function(item) {return item.age}
	static select = function(selector_function, data = undefined) {
		var rv = new LinqArray(length());
		var i = 0; repeat(length()) {
			rv.array[@ i] = selector_function(array[i], data);
			i++;
		}
		return rv;
	}

	/// @func do_foreach(iterator_function, data = undefined)
	/// @desc Calls the iterator function for each item in the array
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the iterator_function, if specified
	static do_foreach = function(iterator_function, data = undefined) {
		var i = 0; repeat(length()) {
			iterator_function(array[@ i], data);
			i++;
		}
		return self;
	}

	/// @func remove_all(values)
	/// @desc remove all specified values from the array. multiple arguments allowed
	static remove_all = function(values) {
		var i = 0;
		var found = false;
		var a, val;
		while (i < length()) {
			val = array[@ i];
			found = false;
			a = 0; repeat(argument_count) {
				if (array[@ i] == argument[@ a]) {
					found = true;
					break;
				}
				a++;
			}
			if (found) 
				array_delete(array, i, 1);
			else
				i++;
		}
		return self;
	}

	/// @func remove_where(condition_function, data = undefined)
	/// @desc remove all where the condition_function returns true
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static remove_where = function(condition_function, data = undefined) {
		var i = 0;
		while (i < length()) {
			if (condition_function(array[i], data)) 
				array_delete(array, i, 1);
			else
				i++;
		}
		return self;
	}

	/// @func skip(count)
	/// @desc skip the first count entries
	static skip = function(count) {
		if (count <= 0) return self;
		var copy = array_create(length() - count);
		array_copy(copy, 0, array, count, length() - count);
		return LinqArray_create_from(copy);
	}

	/// @func skip_while(condition_function, data = undefined)
	/// @desc skip entries while condition_function returns true
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static skip_while = function(condition_function, data = undefined) {
		var i = 0;
		var len = length();
		while (i < len && condition_function(array[i], data)) i++;
		return skip(i);
	}

	/// @func skip_until(condition_function, data = undefined)
	/// @desc skip entries until condition_function returns true
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static skip_until = function(condition_function, data = undefined) {
		var i = 0;
		var len = length();
		while (i < len && !condition_function(array[i], data)) i++;
		return skip(i);
	}

	/// @func take(count)
	/// @desc take the first count entries
	static take = function(count) {
		if (count <= 0) return new LinqArray();
		var copy = array_create(count);
		array_copy(copy, 0, array, 0, count);
		return LinqArray_create_from(copy);
	}

	/// @func take_while(condition_function, data = undefined)
	/// @desc take entries while condition_function returns true
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static take_while = function(condition_function, data = undefined) {
		var i = 0;
		var len = length();
		while (i < len && condition_function(array[i], data)) i++;
		return take(i);
	}

	/// @func take_until(condition_function, data = undefined)
	/// @desc take entries until condition_function returns true
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static take_until = function(condition_function, data = undefined) {
		var i = 0;
		var len = length();
		while (i < len && !condition_function(array[i], data)) i++;
		return take(i);
	}

	/// @func take_random(count, ensure_unique = true)
	/// @desc returns a LinqArray containing count random entries of this LinqArray.
	///				 if ensure_unique = true (the default) no duplicates will be contained in the result
	///				 NOTE: If the length of this array is less than or equal to count, this method, simply
	///				 returns self, thus maybe ignoring the ensure_unique value (if currently duplicates are contained)
	static take_random = function(count, ensure_unique = true) {
		var len = length() - 1;
		if (len < count) 
			return self;
			
		var rv = new LinqArray(count);
		var i = 0;
		var val;
		while (i < count) {
			val = array[irandom_range(0, len)];
			if (!ensure_unique || !rv.contains(val)) {
				rv.array[@ i] = val;
				i++;
			}
		}
		return rv;
	}

	/// @func first_or_default(condition_function = undefined, data = undefined)
	/// @desc if no condition_function specified returns the first entry in the array or undefined if array_length == 0.
	///				 if a condition_function is specified, returns the first item where the function returns true, or undefined
	///				 if it never returns true.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static first_or_default = function(condition_function = undefined, data = undefined) {
		var len = length();
		if (condition_function == undefined) {
			return len > 0 ? array[0] : undefined;
		} else {
			var i = 0;
			while (i < len && !condition_function(array[i], data)) i++;
			return (i < len ? array[i] : undefined);
		}
	}
	
	/// @func last_or_default(condition_function = undefined, data = undefined)
	/// @desc if no condition_function specified returns the last entry in the array or undefined if array_length == 0.
	///				 if a condition_function is specified, returns the first item counting backwards from the end of the array,
	///				 where the function returns true, or undefined, if it never returns true.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the condition_function, if specified
	static last_or_default = function(condition_function = undefined, data = undefined) {
		var len = length();
		if (condition_function == undefined) {
			return len > 0 ? array[len - 1] : undefined;
		} else {
			var i = len - 1;
			while (i >= 0 && !condition_function(array[i], data)) i--;
			return (i >= 0 ? array[i] : undefined);
		}
	}

	/// @func distinct(distinct_function = undefined, data = undefined)
	/// @desc returns a new LinqArray containing only unique values. If no distinct_function is specified,
	///				 values are compared directly, otherwise the distinct_function must return the value that makes an item distinct.
	///				 NOTE: The second (optional) parameter "data" will be passed as second parameter to the distinct_function, if specified
	///				 Example: struct{name:"abc",age:33} distinct_function(item) {return item.age}
	static distinct = function(distinct_function = undefined, data = undefined) {
		var dist = new LinqArray();
		var rv = new LinqArray();
		var val;
		var i = 0; repeat(length()) {
			val = array[i];
			i++;
			if (distinct_function == undefined) {
				if (!rv.contains(val)) {
					rv.push(val);
				}
			} else {
				var disval = distinct_function(val, data);
				if (!dist.contains(disval)) {
					dist.push(disval);
					rv.push(val);
				}
			}
		}
		return rv;
	}

	/// @func intersect(other_array)
	/// @desc removes all items that are not contained in other_array
	static intersect = function(other_array) {
		if (is_array(other_array)) other_array = LinqArray_create_from(other_array);
		var i = 0;
		while (i < length()) {
			if (!other_array.contains(array[i])) 
				remove(i, 1);
			else
				i++;
		}
		return self;
	}

	/// @func intersect(other_array)
	/// @desc same as intersect, but returns a NEW LinqArray, not modifying this current one
	static intersect_new = function(other_array) {
		var rv = clone();
		if (is_array(other_array)) other_array = LinqArray_create_from(other_array);
		var i = 0;
		while (i < rv.length()) {
			if (!other_array.contains(array[i])) 
				rv.remove(i, 1);
			else
				i++;
		}
		return rv;
	}

	/// @func minus(other_array)
	/// @desc removes all items that are contained in other_array
	static minus = function(other_array) {
		if (is_array(other_array)) other_array = LinqArray_create_from(other_array);
		var i = 0;
		while (i < length()) {
			if (other_array.contains(array[i])) 
				remove(i, 1);
			else
				i++;
		}
		return self;
	}

	/// @func minus(other_array)
	/// @desc same as minus, but returns a NEW LinqArray, not modifying this current one
	static minus_new = function(other_array) {
		var rv = clone();
		if (is_array(other_array)) other_array = LinqArray_create_from(other_array);
		var i = 0;
		while (i < rv.length()) {
			if (other_array.contains(array[i])) 
				rv.remove(i, 1);
			else
				i++;
		}
		return rv;
	}

	/// @func union(other_array)
	/// @desc integrates other_array into this one, avoiding duplicates
	/// @param {array|LinqArray} other_array Must be an array or LinqArray
	static union = function(other_array) {
		var val;
		if (is_array(other_array)) {
			var i = 0; repeat(array_length(other_array)) {
				val = other_array[i];
				if (!contains(val)) push(val);
				i++;
			}
		} else {
			var i = 0; repeat(other_array.length()) {
				val = other_array.array[i];
				if (!contains(val)) push(val);
				i++;
			}			
		}
		return self;
	}

	/// @func union_new(other_array)
	/// @desc same as union, but returns a NEW LinqArray, not modifying this current one
	/// @param {array|LinqArray} other_array Must be an array or LinqArray
	static union_new = function(other_array) {
		var rv = clone();
		var val;
		if (is_array(other_array)) {
			var i = 0; repeat(array_length(other_array)) {
				val = other_array[i];
				if (!rv.contains(val)) rv.push(val);
				i++;
			}
		} else {
			var i = 0; repeat(other_array.length()) {
				val = other_array.array[i];
				if (!rv.contains(val)) rv.push(val);
				i++;
			}			
		}
		return rv;
	}

	/// @func toString
	/// @desc a json-compatible string representation
	toString = function() {
		return SnapToJSON(array);
	}

}

/// @func					LinqArray_create_from(array)
/// @desc				create a LinqArray with an existing array
/// @param {array} array
/// @returns {LinqArray}		
function LinqArray_create_from(array) {
	var rv = new LinqArray();
	rv.array = array;
	return rv;
}