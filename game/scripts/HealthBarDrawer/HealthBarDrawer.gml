/*
    easy health bar drawing
	
	Using all at default, the health bar will be drawn:
	- Left anchored (standard horizontal health bar)
	- Start with current=max_value (an xp-bar would likely start empty)
	- will draw a 1px wide black border
	- will draw with a 75% opague black background color (background slightly visible behind)
	- will have max_color = c_green and min_color = c_red (normal health colors)
	- will draw the current value as text in the center of the bar with default font
	  (set the "font" member to any font to change this or set draw_current to false to disable)
	
	You can change all those parameters - the member names are:
	backcol
	mincol
	maxcol
	anchor (0 = left, 1 = right, 2 = top, 3 = bottom)
	showback true/false
	showborder true/false
	font  for text
	font_color	  text draw color
	font_y_correction	you can add a pixel offset to move text in y - necessary for underlength of some fonts
						default = 2 (which is approx 10% of a common font size used in health bars)
	draw_current  if true (default) the current_value will be drawn as text in the center
	draw_max	  if true (default false), the text will be drawn as "current/max" (like 18/20)
	              setting draw_max to true also forces draw_current.

	You can query the currently displayed values through these members:
	current_value
	max_value
	value_percent   (holds the current % of max_value)
*/

/// @func		HealthBarDrawer(_max_value = 100, _font = undefined, start_filled = true, _anchor = 0)
/// @desc	Utility to make drawing a healthbar less painful by providing common defaults
/// @param {int}	_max_value maximum value
/// @param {font}	_font font to use when drawing text
/// @param {bool}	start_filled true (default) to have current_value == max_value, if false, current_value = 0
/// @param {int}	_direction Where the bar is "anchored" (0 = left, 1 = right, 2 = top, 3 = bottom)
function HealthBarDrawer(_max_value = 100, _font = undefined, start_filled = true, _anchor = 0) constructor {
	construct(HealthBarDrawer);

	update((start_filled ? _max_value : 0), _max_value);
	
	anchor = _anchor;
	mincol = c_red;
	maxcol = c_green;
	showback = true;
	showborder = true;
	backcol = $C0000000;

	font = _font;
	font_color = c_white;
	font_y_correction = 2;
	draw_current = true;
	draw_max = false;

	__prev_current = -1;
	__prev_max = -1;
	__prev_strx = -1;
	__prev_stry = -1;
	__prev_string = "";

	/// @func		is_empty()
	/// @desc	true if current_value == 0
	static is_empty = function() {
		return current_value == 0;
	}

	/// @func		is_full()
	/// @desc	true if current_value == max_value
	static is_full = function() {
		return current_value == max_value;
	}

	/// @func		update(new_current = undefined, new_max = undefined)
	/// @desc	update all values incl value_percent
	static update = function(new_current = undefined, new_max = undefined) {
		if (new_current != undefined) current_value = new_current;
		if (new_max != undefined) max_value = new_max;
		
		current_value = clamp(current_value, 0, max_value);
		value_percent = (current_value / max_value) * 100;
	}

	/// @func		draw(x1,y1,x2,y2)
	/// @desc	draw at the specified coordinates
	static draw = function(x1,y1,x2,y2) {
		draw_healthbar(x1, y1, x2, y2, value_percent, backcol, mincol, maxcol, anchor, showback, showborder);
		if (font != undefined && (draw_max || draw_current)) {
			draw_set_font(font);
			if (__prev_current != current_value || __prev_max != max_value) {
				__prev_string = string_format_number_left(floor(current_value));
				if (draw_max) __prev_string = string_concat(__prev_string, "/", max_value);
				__prev_current = current_value;
				__prev_max = max_value;
				__prev_strx = string_width(__prev_string) / 2;
				__prev_stry = string_height(__prev_string) / 2;
			} 
			draw_set_color(font_color);
			draw_text(x1 - __prev_strx + (x2 - x1) / 2, y1 - __prev_stry + font_y_correction + (y2 - y1) / 2, __prev_string);
			draw_set_color(c_white);
		}
	}
}
