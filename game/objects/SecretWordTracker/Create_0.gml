/// @description DOCS INSIDE

/*
	This is a little helper object which allows you to "hide"
	secret key words or key combinations in your room.
	
	Just call "track_word" and give it a callback and the object
	will invoke this callback when the key combination (or entire word)
	is typed on the keyboard
*/

#macro SECRET_WORD_TRACKER		global.__secret_word_tracker
SECRET_WORD_TRACKER = self;

event_inherited();

tracked_string	= "";
secret_map		= {};
max_word_length = 0;
__laststr		= "";

__track_next_key = function() {
	if (keyboard_string == "")
		return;
	
	__laststr = keyboard_string;
	keyboard_string = "";
	tracked_string = string_last(tracked_string + __laststr, max_word_length);
	
	var words = struct_get_names(secret_map);
	for (var i = 0, len = array_length(words); i < len; i++) {
		var word = words[@i];
		var typed = string_last(tracked_string, string_length(word));
		var to_call = vsget(secret_map, typed);
		if (to_call != undefined) 
			to_call();
	}
}

clear = function() {
	tracked_string	= "";
	secret_map		= {};
	max_word_length = 0;
}

/// @function track_word(_word, _callback)
track_word = function(_word, _callback) {
	secret_map[$ _word] = _callback;
	
	max_word_length = 0;
	var names = struct_get_names(secret_map);
	for (var i = 0, len = array_length(names); i < len; i++) {
		max_word_length = max(max_word_length, string_length(names[@i]));		
	}
}

/// @function untrack_word(_word)
untrack_word = function(_word) {
	struct_remove(secret_map, _word);
}