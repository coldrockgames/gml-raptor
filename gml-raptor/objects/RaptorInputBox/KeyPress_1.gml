/// @desc Cursor control & add text

if (!__RAPTORDATA.has_focus || __LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

__cut_selection = function() {
	if (selection_length == 0)
		return "";
	var txbefore = text;
	var rv = string_copy(text, __selection_start, abs(selection_length));
	text = string_concat(string_copy(text, 1, __selection_start - 1),
		   string_copy(text, __selection_start + abs(selection_length), 
					   string_length(text) - __selection_start - string_length(selected_text) + 1));
	set_cursor_pos(max(0, __selection_start - 1));
	selected_text = "";
	selection_length = 0;
	__invoke_text_changed(txbefore, text);
	return rv;
}

__backspace_char = function() {
	if (cursor_pos == 0 && selection_length == 0)
		return;
		
	if (selection_length == 0) {
		var txbefore = text;
		text = string_concat(string_copy(text, 1, cursor_pos - 1), 
			   string_copy(text, cursor_pos + 1, string_length(text) - cursor_pos));
		set_cursor_pos(cursor_pos - 1);
		__invoke_text_changed(txbefore, text);
	} else
		__cut_selection();
}

__delete_char = function() {
	if (cursor_pos == string_length(text) && selection_length == 0)
		return;
		
	if (selection_length == 0) {
		var txbefore = text;
		text = string_concat(string_copy(text, 1, cursor_pos),
			   string_copy(text, cursor_pos + 2, string_length(text) - cursor_pos));
		__invoke_text_changed(txbefore, text);
	} else
		__cut_selection();
}

__filter_character = function( _char) {
	if (!array_contains(forbidden_characters, _char) ||
		(_char == "\\" && input_filter == character_filter.pathname)) {
		switch (input_filter) {
			case character_filter.none:
				return _char;
			case character_filter.allowed:
				if (string_contains(filtered_characters, _char))
					return _char;
				break;
			case character_filter.forbidden:
				if (!string_contains(filtered_characters, _char))
					return _char;
				break;
			case character_filter.filename:
				if (!array_contains(forbidden_characters_file, _char))
					return _char;
				break;
			case character_filter.pathname:
				if (!array_contains(forbidden_characters_path, _char))
					return _char;
				break;
			case character_filter.numbers:
				if (array_contains(allowed_characters_numbers, _char))
					return _char;
				break;
		}
	}
	return "";
}

__add_text = function() {
	if (keyboard_string == "")
		return;
		
	__cut_selection();
	if (string_length(text) >= max_length)
		return;

	var finalstring = "";
	var i = 0; repeat(string_length(keyboard_string)) {
		finalstring = string_concat(finalstring, __filter_character(string_copy(keyboard_string, ++i, 1)));
	}
	
	if (finalstring != "") {
		var txbefore = text;
		var cb = finalstring;
		text = string_concat(string_copy(text, 1, cursor_pos), cb,
			string_copy(text, cursor_pos + 1, string_length(text) - cursor_pos - string_length(cb) + 1));
		cursor_pos = clamp(cursor_pos + string_length(cb), 1, string_length(text));
		__reset_cursor_blink();
		__invoke_text_changed(txbefore, text);
	}
	keyboard_string = "";
}

__copy_text = function() {
	if (os_type != os_windows || selection_length == 0)
		return;
	
	if (string_is_empty(password_char))
		clipboard_set_text(selected_text);
	else
		clipboard_set_text("-- You shall not try to make a password visible through Ctrl-C! ;) --");
}

__paste_text = function() {
	if (os_type != os_windows || !clipboard_has_text())
		return;
		
	__cut_selection();
	var txbefore = text;
	var cb = clipboard_get_text();
	text = string_concat(string_copy(text, 1, cursor_pos), cb,
		string_copy(text, cursor_pos + 1, string_length(text) - cursor_pos));
	if (string_length(text) >= max_length)
		text = string_copy(text, 1, max_length);
	set_cursor_pos(min(max_length, cursor_pos + string_length(cb)));
	__invoke_text_changed(txbefore, text);
}

__cut_text = function() {
	if (os_type != os_windows || selection_length == 0)
		return;
	
	var cut = __cut_selection();
	if (string_is_empty(password_char))
		clipboard_set_text(cut);
	else
		clipboard_set_text("-- You shall not try to make a password visible through Ctrl-X! ;) --");
}

__find_next_input_box = function(shift_tab = false) {
	if (__TEXT_NAV_TAB_LOCK != 0)
		return;

	__TEXT_NAV_TAB_LOCK = id;
	__stop_wait_for_key_repeat();
	lose_focus();
	var look_for_tab_index = tab_index + (shift_tab ? -1 : 1);
	var closest_tab_index_so_far = -2;
	var closest_candidate = undefined;
	var lowest_candidate = undefined;
	var lowest_tab_index_so_far = -2;
	with (RaptorInputBox) {
		if (eq(self, other) || !is_enabled || __INSTANCE_UNREACHABLE)
			continue;
		
		if (tab_index == look_for_tab_index) {
			set_focus();
			return;
		}
		
		if (shift_tab) {
			if (tab_index > look_for_tab_index &&	
			   (lowest_tab_index_so_far == -2 || tab_index > lowest_tab_index_so_far)) {
					lowest_tab_index_so_far = tab_index;
					lowest_candidate = self;
			}
		
			if (tab_index < look_for_tab_index &&
			   (closest_tab_index_so_far == -2 || tab_index > closest_tab_index_so_far)) {
				   closest_tab_index_so_far = tab_index;
				   closest_candidate = self;
			}
		} else {
			if (tab_index < look_for_tab_index &&	
			   (lowest_tab_index_so_far == -2 || tab_index < lowest_tab_index_so_far)) {
					lowest_tab_index_so_far = tab_index;
					lowest_candidate = self;
			}
		
			if (tab_index > look_for_tab_index &&
			   (closest_tab_index_so_far == -2 || tab_index < closest_tab_index_so_far)) {
				   closest_tab_index_so_far = tab_index;
				   closest_candidate = self;
			}
		}
	}
	
	if      (closest_candidate != undefined) with (closest_candidate) set_focus(true);
	else if (lowest_candidate  != undefined) with (lowest_candidate)  set_focus(true);
}

__do_key_action = function() {
	if (!__RAPTORDATA.has_focus) 
		return;
	
	keyboard_string = string_copy(keyboard_string, string_length(keyboard_string), 1);
	
	if (keyboard_check(vk_tab))
		__find_next_input_box(keyboard_check(vk_shift));
	else if (keyboard_check(vk_backspace))
		__backspace_char();
	else if (keyboard_check(vk_shift) && keyboard_check(vk_delete))
		__cut_text();
	else if (keyboard_check(vk_delete))
		__delete_char();
	else if (keyboard_check(vk_home) || keyboard_check(vk_pageup))
		set_cursor_pos(0);
	else if (keyboard_check(vk_end) || keyboard_check(vk_pagedown))
		set_cursor_pos(string_length(text));
	else if (keyboard_check(vk_left))
		set_cursor_pos(max(0, cursor_pos - 1));
	else if (keyboard_check(vk_right))
		set_cursor_pos(min(string_length(text), cursor_pos + 1));
	else if (keyboard_check(vk_control) && keyboard_check(ord("A")))
		select_all();
	else if (keyboard_check(vk_control) && keyboard_check(ord("X")))
		__cut_text();
	else if (keyboard_check(vk_control) && keyboard_check(ord("C")))
		__copy_text();
	else if (keyboard_check(vk_control) && keyboard_check(ord("V")))
		__paste_text();
	else if (keyboard_check(vk_control) && keyboard_check(vk_insert))
		__copy_text();
	else if (keyboard_check(vk_shift)   && keyboard_check(vk_insert))
		__paste_text();
	else if (keyboard_string != "")
		__add_text();

	keyboard_string = "";
	__start_wait_for_key_repeat(keyboard_key);
}

if (__RAPTORDATA.has_focus && __TEXT_NAV_TAB_LOCK == 0)
	__do_key_action();