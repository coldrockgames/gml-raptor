/// @desc event

enum listbox_sort {
	none, ascending, descending
}

enum listbox_style {
	dropdown, listview
}

if (list_style == listbox_style.listview) {
	min_height = 0;
	startup_height = 0;
	autosize = false;
}

event_inherited();

down_arrow_sprite ??= sprDefaultListBoxArrow;

mypanel = undefined;

#region __listboxitem internal class
function __ListBoxItem(_listbox, _displaymember, _valuemember, _index) constructor {
	listbox			= _listbox;
	displaymember	= _displaymember;
	displaystring	= _displaymember;
	valuemember		= _valuemember;
	index			= _index;
	
	selected		= false;
	shortened		= false;
	measured		= false;
	static measure = function() {
		if (measured) return;
		measured = true;
		
		var max_len = listbox.nine_slice_data.width;
		var len = new Coord2();
		displaymember = LG_resolve(displaymember);
		displaystring = displaymember;
		scribble_measure_text(displaystring,,len);
		while (displaystring != "" && len.x > max_len) {
			shortened = true;
			displaystring = string_skip_end(displaystring, 1);
			scribble_measure_text(string_concat(displaystring, "..."),, len);
			if (len.x <= max_len) {
				displaystring = string_concat(displaystring, "...");
				break;
			}
		}
	}
	
	static get_display_string = function() {
		if (!measured) measure();
		return displaystring;
	}
	
	static suicide = function() {
		listbox = undefined;
	}
	
	toString = function() {
		return displaymember;
	}
}
#endregion

#region item functions

/// @func add_item(_displaymember, _valuemember)
/// @desc	Adds a new item to the list
add_item = function(_displaymember, _valuemember) {
	close_list();
	var idx = array_length(items);
	array_push(items, new __ListBoxItem(self, _displaymember, _valuemember, idx));
}

/// @func remove_item_by_value(_valuemember)
/// @desc Removes an item by its value from the list
remove_item_by_value = function(_valuemember) {
	var idx = -1;
	
	for (var i = 0, len = array_length(items); i < len; i++) {
		if (items[@i].valuemember == _valuemember) {
			items[@i].suicide();
			idx = i;
			break;
		}
	}
	
	if (idx != -1) {
		close_list();
		array_delete(items, idx, 1);
		if (selected_index >= idx) selected_index--;
	}
}

/// @func remove_item_by_name(_displaymember)
/// @desc Removes an item by its name from the list
remove_item_by_name = function(_displaymember) {
	var idx = -1;
	
	for (var i = 0, len = array_length(items); i < len; i++) {
		if (items[@i].displaymember == _displaymember) {
			items[@i].suicide();
			idx = i;
			break;
		}
	}
	
	if (idx != -1) {
		close_list();
		array_delete(items, idx, 1);
		if (selected_index >= idx) selected_index--;
	}
}

/// @func get_selected_value()
/// @desc Gets the valuemember of the selected item or undefined, if nothing is selected
get_selected_value = function() {
	if (selected_index != -1)
		return items[@selected_index].valuemember;
	return undefined;
}

/// @func get_selected_item()
/// @desc Gets the valuemember of the selected item or undefined, if nothing is selected
get_selected_item = function() {
	if (selected_index != -1)
		return items[@selected_index];
	return undefined;
}

/// @func clear_items()
/// @desc Clear all items from the listbox and set selected_index to -1.
///				 NOTE: This will NEVER trigger the on_item_selected callback!
clear_items = function() {
	for (var i = 0, len = array_length(items); i < len; i++) 
		items[@i].suicide();
	items = [];
	selected_index = -1;
}

__item_clicked = function(_item) {
	array_foreach(items, function(it) { it.selected = false; });
	if (_item != undefined) {
		text = (list_style == listbox_style.dropdown ? _item.get_display_string() : "");
		tooltip_text = (_item.shortened ? _item.displaymember : "");
		selected_index = _item.index;
		_item.selected = true;
		invoke_if_exists(self, "on_item_selected", _item.valuemember, _item.displaymember);
	}
	close_list();
}

#endregion

#region open/close functionality

is_open = false;
open_list = function() {
	if (is_open) return;
	
	invoke_if_exists(self, "on_list_opening");
	
	var len = array_length(items ?? []);
	if (len > 0) {
		vlog($"{MY_NAME} opening list panel with {len} item(s)");
		
		is_open = true;
		mypanel = instance_create(x, y, depth - 1, RaptorListBoxPanel);
		mypanel.attach_to(self);
		
		invoke_if_exists(self, "on_list_opened");
	}
}

close_list = function() {
	if (!is_open || list_style == listbox_style.listview) return;
	is_open = false;
	
	vlog($"{MY_NAME} closing list panel");
	if (mypanel != undefined) {
		mypanel.close();
		mypanel = undefined;
	}
	invoke_if_exists(self, "on_list_closed");
}

/// @func toggle_open_state()
toggle_open_state = function() {
	if (is_open) close_list(); else open_list();
}

/// @func mouse_over_list_or_panel()
mouse_over_list_or_panel = function() {
	var overpanel = false;
	if (mypanel != undefined) {
		with(mypanel)
			overpanel = point_in_rectangle(CTL_MOUSE_X, CTL_MOUSE_Y,
				SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, SELF_VIEW_RIGHT_EDGE, SELF_VIEW_BOTTOM_EDGE);
	}
	return (mouse_is_over || overpanel);
}

#endregion

// analyze design-time items
if (array_length(items ?? []) > 0) {
	var newitems = items;
	items = [];
	vlog($"{MY_NAME} adding {array_length(newitems)} design time items to list");
	var sa;
	for (var i = 0, len = array_length(newitems); i < len; i++) {
		var it = string(newitems[@i] ?? "<null>");
		if (string_contains(it, ":")) {
			sa = string_split(it, ":", false, 1);
			add_item(sa[1], sa[0]);
		} else {
			add_item(it, i);
			dlog($"Design time Listbox item '{it}' does not follow the \"value:text\" pattern! Added with value {i}");
		}
	}
	
	if (selected_index > -1 && array_length(items) > selected_index)
		__item_clicked(items[@ selected_index]);
}

if (list_style == listbox_style.listview) {
	scale_sprite_to(sprite_width, 0);
	open_list();
}

__draw_instance = function(_force = false) {
	__basecontrol_draw_instance(_force);
	
	if (!visible || list_style == listbox_style.listview) return;
	
	draw_sprite_ext(down_arrow_sprite, 0, 
		SELF_VIEW_RIGHT_EDGE, 
		SELF_VIEW_CENTER_Y,
		1, 1, image_angle,
		mouse_is_over ? draw_color_mouse_over : draw_color,
		image_alpha);
}