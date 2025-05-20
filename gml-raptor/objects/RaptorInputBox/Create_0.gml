/// @desc DOCS inside!

event_inherited();

/*
	IMPORTANT!
	Right beneath this comment block you find the array variable forbidden_characters.
	Add (array_push) any characters you want to be forbidden to this array, best from outside,
	not by modifying the source code of this control (library updates would nullify your modifications).
	
	By default, those characters are forbidden: CR/LF, TAB and BACKSPACE and internal control characters.
	The Inputbox will react normally on keypress of BACKSPACE, but it will not allow to ADD
	a backspace character to the string (that's an important difference!)
	
*/

allowed_characters_numbers  = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
forbidden_characters		= [chr(13), chr(10), chr(8), chr(127), "[", "]", "\"", "\\"];
forbidden_characters_file	= ["<", ">", "|", "?", "*", ":", "/"];
forbidden_characters_path	= ["<", ">", "|", "?", "*"];
forbidden_filenames = [ 
	"CON", "PRN", "AUX", "NUL", 
	"COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", 
    "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9" 
];

cursor_pos = 0;
selection_length = 0;
selected_text = "";

__last_selection_length = 0;
__selection_rect = new Rectangle();
__selection_start = 0;

__cursor_frame = 0;
__cursor_visible = true;
__last_cursor_visible = false;

__RAPTORDATA.has_focus = false;

__cursor_x = 0;
__cursor_y = 0;
__cursor_height = 0;
__first_draw = true;
__first_cursor_draw = true;
__backup_text_color = THEME_CONTROL_TEXT;
__backup_text_color_mouse_over = THEME_CONTROL_TEXT;

__key_repeat_frame = 0;
__wait_for_key_repeat = false;
__repeat_interval_mode = false;
__repeating_key = undefined;

if (tab_index == -1) tab_index = instance_number(RaptorInputBox) - 1;

enum character_filter {
	none, allowed, forbidden, filename, pathname, numbers
}

__contains_character = function(_str, _array) {
	for (var i = 0, len = array_length(_array); i < len; i++) {
		if (string_count_char(_str, _array[@i]) > 0) 
			return true;
	}
	
return false;
}

/// @func	is_valid_filename(_str)
is_valid_filename = function(_str) {
	return 
		!array_contains(forbidden_filenames, string_upper(file_get_filename(_str, false))) &&
		!string_contains(_str, "..") &&
		!__contains_character(_str, forbidden_characters_file);
}

/// @func	is_valid_pathname(_str)
is_valid_pathname = function(_str) {
	if (is_valid_filename(_str)) {
		return 
			(!string_starts_with(_str, "\\") || string_starts_with(_str, "\\\\")) &&
			!string_ends_with(_str, "\\") && (string_count_char(_str, ":") <= 1);
	}
	return true;
}

/// @func	set_focus(from_tab = false)
/// @desc	Set input focus to this
set_focus = function(from_tab = false) {
	if (__RAPTORDATA.has_focus || !is_enabled || 
		(get_window() != undefined && !get_window().is_focus_window())) 
		return;
	
	with (RaptorInputBox) lose_focus();
	vlog($"{MY_NAME}: tab index {tab_index} got focus");
	keyboard_string = "";
	__RAPTORDATA.has_focus = true;
	__backup_text_color = text_color;
	__backup_text_color_mouse_over = text_color_mouse_over;
	animated_text_color = text_color_focus;
	text_color = text_color_focus;
	text_color_mouse_over = text_color_focus;
	if (from_tab) set_cursor_pos(string_length(text));
	selection_length = 0;
	__last_selection_length = -1;
	if (select_all_on_focus) {
		__draw_cursor();
		select_all();
	}
	force_redraw(false);
	__invoke_got_focus();
}

/// @func	lose_focus()
/// @desc	Remove input focus from this
lose_focus = function() {
	if (!__RAPTORDATA.has_focus) 
		return;
	
	vlog($"{MY_NAME}: tab index {tab_index} lost focus");
	__RAPTORDATA.has_focus = false;
	selection_length = 0;
	__last_selection_length = -1;
	text_color = __backup_text_color;
	text_color_mouse_over = __backup_text_color_mouse_over;
	animated_text_color = text_color;
	force_redraw(false);
	__invoke_lost_focus();
}

/// @func	select_all()
/// @desc	Select all the text in the inputbox
select_all = function() {
	selection_start = string_length(text);
	selection_length = -string_length(text);
	cursor_pos = selection_start;
	set_cursor_pos(string_length(text), true);
}

/// @func	select_word()
select_word = function() {
	// scan to the left and right for word-breakers, then select the region
	static is_in_word = function(char) {
		if (char == undefined)
			return false;
			
		var o = ord(char);
		return 
			(o >= ord("A") && o <= ord("Z")) ||
			(o >= ord("a") && o <= ord("z")) ||
			(o >= ord("0") && o <= ord("9")) ||
			(o == ord("_")) ||
			(o >= 128 && o <= 165); // Umlauts and standard special characters
	}
	var left = cursor_pos + 1;
	var right = cursor_pos + 1;
	if (!is_in_word(__char_at(left))) {
		// first line exit if we are on a non-word character
		// then select only this character
		selection_start = left;
		selection_length = 1;
	} else {
		while (is_in_word(__char_at(left))) left--;
		while (is_in_word(__char_at(right))) right++;
		set_cursor_pos(right - 1);
		selection_start = left + 1;
		selection_length = -max(1, right - left - 1);
	}
}

/// @func	__char_at(pos)
__char_at = function(pos) {
	if (pos > 0 && pos <= string_length(text))
		return string_copy(text, pos, 1);
	return undefined;
}

/// @func	__reset_cursor_blink()
/// @desc	ensure, cursor stays visible
__reset_cursor_blink = function() {
	__cursor_frame = 0;
	__cursor_visible = true;
	__last_cursor_visible = false;
}

/// @func	set_cursor_pos(pos)
/// @desc	set the cursor at character pos and ensure cursor is instantly visible
/// @param {int} pos 			
/// @param {bool=false} force_extend_selection 			
set_cursor_pos = function(pos, force_extend_selection = false) {
	if ((keyboard_check(vk_shift) && !keyboard_check(vk_insert)) || force_extend_selection)
		selection_length -= (pos - cursor_pos);
	else
		selection_length = 0;
	cursor_pos = clamp(pos, 0, string_length(text));
	__reset_cursor_blink();
}

/// @func	__start_wait_for_key_repeat(key)
/// @param {constant} key
__start_wait_for_key_repeat = function(key) {
	if (!__wait_for_key_repeat || key != __repeating_key) {
		__wait_for_key_repeat = true;
		__repeat_interval_mode = false;
		__key_repeat_frame = 0;
		__repeating_key = key;
	}
}

/// @func	__stop_wait_for_key_repeat
__stop_wait_for_key_repeat = function() {
	__wait_for_key_repeat = false;
	__repeat_interval_mode = false;
	__key_repeat_frame = 0;
	__repeating_key = undefined;
}

__invoke_got_focus = function() {
	if (on_got_focus != undefined)
		on_got_focus(self);
}

__invoke_lost_focus = function() {
	if (on_lost_focus != undefined)
		on_lost_focus(self);
}

/// @func	__invoke_text_changed(old_text, new_text)
__invoke_text_changed = function(old_text, new_text) {
	if (on_text_changed != undefined && old_text != new_text)
		on_text_changed(self, old_text, new_text);	
}

/// @func	scribble_add_text_effects(scribbletext)
/// @desc	called when a scribble element is created to allow adding custom effects.
///			overwrite (redefine) in child controls
/// @param {struct} scribbletext
scribble_add_text_effects = function(scribbletext) {
	// We do not add any effects but we use this callback to set the cursor pos
	// to the end of the string, if called first time
	if (__first_draw) {
		__first_draw = false;
		cursor_pos = string_length(text);
	}
}

/// @func	__create_scribble_object(align, str)
/// @desc	tweaking the internal function of base for password char
///			so that scribble always draws only *** without knowing the real text
/// @param {string} align			
/// @param {string} str			
__create_scribble_object = function(align, str, test_only = false) {
	var sbc, bb;
	var max_chars = string_length(str);
	
	do {
		var pw = !string_is_empty(password_char);
		var scstr = (pw ? string_repeat(string_copy(password_char,1,1), max_chars) : string_copy(str, 1, max_chars));
		sbc = scribble(string_concat(align, scstr), MY_NAME)
				.starting_format(
					font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
					animated_text_color)
				.outline(outline_color)
				.shadow(shadow_color, shadow_alpha);

		bb = sbc.get_bbox();
		if (!pw && !test_only) text = scstr;
		max_chars--;
	} until (autosize || max_chars <= 1 || bb.width <= nine_slice_data.width);
	cursor_pos = clamp(cursor_pos, 0, string_length(text));
		
	return sbc;
}

/// @func	draw_scribble_text()
/// @desc	draw the text - redefine for additional text effects
draw_scribble_text = function() {
	if (string_length(text) > max_length) {
		text = string_copy(text, 1, max_length);
		force_redraw();
		__draw_self();
		return;
	}
	if (__RAPTORDATA.has_focus) {
		if (selection_length != __last_selection_length) {
			__last_selection_length = selection_length;
			if (selection_length != 0) {
				var startpos = cursor_pos;
				var endpos = cursor_pos + selection_length;
				if (startpos > endpos) {
					var exc = startpos;
					startpos = endpos;
					endpos = exc;
				}
				var substr = string_copy(text, 1, startpos);
				var xleft = __create_scribble_object("[fa_left]", substr, true).get_width();
				__selection_start = startpos + 1;
				selected_text = string_copy(text, __selection_start, abs(selection_length));
				var xwidth = min(nine_slice_data.width, __create_scribble_object("[fa_left]", selected_text, true).get_width() - 1);
				var bbox = __scribble_text.get_bbox(__text_x, __text_y);
				var txstart = bbox.left;
				__selection_rect.set(txstart + xleft, bbox.top, xwidth, min(__cursor_height, __scribble_text.get_height()));
			} else 
				__selection_rect.set(0,0,0,0);
		}
		if (selection_length != 0) {
			draw_set_color(text_color_focus);
			draw_set_alpha(0.25);
			draw_rectangle(__selection_rect.left, __selection_rect.top, __selection_rect.get_right(), __selection_rect.get_bottom(), false);
			draw_set_alpha(1);
			draw_set_color(c_white);
		}
	}
	__scribble_text.draw(__text_x, __text_y);
}

/// @func	__draw_cursor()
__draw_cursor = function() {
	if (__first_cursor_draw || (__RAPTORDATA.has_focus && __cursor_visible && is_topmost(x, y))) {
		if (__first_cursor_draw || __last_cursor_visible != __cursor_visible) {
			__first_cursor_draw = false;
			// make draw calculations only once, if visible changed in last frame
			__last_cursor_visible = __cursor_visible;
			var scrib = (text == "" ? __create_scribble_object(scribble_text_align, "A", true) : __scribble_text);
			__cursor_height = min(scrib.get_height(), scrib.get_bbox().height);
			var bbox = __scribble_text.get_bbox(__text_x, __text_y);
			var ybox = scrib.get_bbox(__text_x, __text_y);
			__cursor_y = ybox.top;
			if (cursor_pos == 0) {
				__cursor_x = bbox.left;
			} else if (cursor_pos == string_length(text)) {
				__cursor_x = bbox.right;
			} else {
				var substr = string_copy(text, 1, cursor_pos);
				var scrib = __create_scribble_object("[fa_left]", substr, true);
				var subbox = scrib.get_bbox(__text_x, __text_y);
				__cursor_x = bbox.left + subbox.width - 1;
			}
		}
		draw_set_color(text_color);
		draw_line_width(__cursor_x, __cursor_y, __cursor_x, __cursor_y + __cursor_height, TEXT_CURSOR_WIDTH);
		draw_set_color(c_white);
	}
}

/// @func	__set_cursor_pos_from_click()
/// @desc	set cursor pos inside text after left click
/// @param {bool=false} force_extend_selection 			
__set_cursor_pos_from_click = function(force_extend_selection = false) {
	var full_box = __scribble_text.get_bbox(__text_x, __text_y);
	var mousepos = mouse_x;
	var topleft = new Coord2(full_box.left, full_box.top);
	var boxwidth = full_box.width;
	if (draw_on_gui) {
		mousepos = GUI_MOUSE_X;
		translate_world_to_gui_abs(topleft.x, topleft.y, topleft);
		boxwidth = translate_world_to_gui_abs(boxwidth, 0).x;
	}

	var xinside = mousepos - topleft.x;
	if (xinside < 0) {
		set_cursor_pos(0, force_extend_selection);
		return;
	}
	
	if (xinside > boxwidth) {
		set_cursor_pos(string_length(text), force_extend_selection);
		return;
	}
	
	var i = 1; repeat(string_length(text)) {
		var substr = string_copy(text, 1, i);
		i++;
		var scrib = scribble(string_concat("[fa_left]", substr)).starting_format(
				font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, text_color);
		var bbox = scrib.get_bbox(topleft.x, topleft.y);
		var box_inside = bbox.right - topleft.x;
		if (box_inside >= xinside)
			break;
	}
	set_cursor_pos(clamp(i - 2, 0, string_length(text)), force_extend_selection);
}

__draw_instance = function(_force = false) {
	__basecontrol_draw_instance(_force);
	if (!visible || image_number < 2) return;
	
	if (__RAPTORDATA.has_focus)
		draw_sprite_ext(sprite_index, 1, x, y, image_xscale, image_yscale, image_angle, border_color_focus, image_alpha);
}