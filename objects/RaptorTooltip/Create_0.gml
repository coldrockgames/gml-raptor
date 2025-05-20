/// @desc activate/deactivate functions

event_inherited();

// this variable holds the object for which the tooltip is shown
tooltip_parent = undefined;

__apply_autosize_alignment = function() {
}

__apply_post_positioning = function() {
}

__align_to_mouse = function() {
	if (draw_on_gui) {
		x = max(0, min(GUI_MOUSE_X + mouse_xoffset, UI_VIEW_WIDTH_SCALED - SELF_WIDTH ));
		y = max(0, min(GUI_MOUSE_Y + mouse_yoffset, UI_VIEW_HEIGHT_SCALED - SELF_HEIGHT));
	} else {
		x = max(0, min(mouse_x + mouse_xoffset, VIEW_WIDTH  - SELF_WIDTH));
		y = max(0, min(mouse_y + mouse_yoffset, VIEW_HEIGHT - SELF_HEIGHT));
	}
}

/// @func	activate(delay_frames = -1)
/// @desc	activate the tooltip to invoke func when shown 
activate = function() {
	vlog($"{MY_NAME}: Tooltip activated on '{name_of(tooltip_parent)}'");
	__align_to_mouse();
	visible = true;
}

/// @func	deactivate()
/// @desc	reset tooltip and hide
deactivate = function() {
	vlog($"{MY_NAME}: Tooltip deactivated on '{name_of(tooltip_parent)}'");
	visible = false;
	text = "";
	tooltip_parent = undefined;
	// force zero-text redraw for correct positioning when re-activated
	__draw_self();
	__callback = undefined;
}