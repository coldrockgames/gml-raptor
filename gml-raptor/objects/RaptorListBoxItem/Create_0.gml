/// @desc click and data
event_inherited();

itemdata = itemdata ?? { selected: false }; // a temp struct before we get real data (for set_selected)

__backup_draw_color = draw_color;
__backup_text_color	= text_color;

set_selected = function(_selected) {
	draw_color = (_selected ? draw_color_mouse_over : __backup_draw_color);
	text_color = (_selected ? text_color_mouse_over : __backup_text_color);

	animated_draw_color = draw_color;
	animated_text_color = text_color;

	if (itemdata.selected != _selected) {
		__animate_draw_color(draw_color);
		__animate_text_color(text_color);
	}

}
set_selected(itemdata.selected);

on_left_click = function() {
	array_foreach(panel.myitems, function(it) { it.set_selected(false); it.itemdata.selected = false; });
	set_selected(true);
	panel.listbox.__item_clicked(itemdata);
}

assign_data = function(_itemdata) {
	itemdata = _itemdata;
	text = _itemdata.get_display_string();
	tooltip_text = (_itemdata.shortened ? _itemdata.displaymember : "");
	set_selected(_itemdata.selected);
}