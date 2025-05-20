/// @desc tooltip management
active_tooltip = undefined;

event_inherited();

/// @func	__activate_tooltip()
/// @desc	start the tooltip countdown onMouseEnter
__activate_tooltip = function() {
	if (!auto_show_tooltip || tooltip_text == "" || active_tooltip != undefined || is_null(tooltip_object))
		return;

	active_tooltip = tooltip_show(tooltip_object, LG_resolve(tooltip_text), self);
}

/// @func	__deactivate_tooltip()
/// @desc	deactivate the tooltip on the control
__deactivate_tooltip = function() {
	tooltip_hide(active_tooltip);
	active_tooltip = undefined;
}
