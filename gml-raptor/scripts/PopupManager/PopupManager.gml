/*
	Handles popup messages through layer visibility
*/
#macro GUI_POPUP_VISIBLE		global.__popup_visible
#macro GUI_POPUP_LAYER_GROUP	global.__popup_layer_group
#macro GUI_POPUP_MIN_DEPTH		global.__popup_group_min_depth

// Use this macro in all controls events that shall not react when a popup is open
// Code it like this (first line of event): if (__HIDDEN_BEHIND_POPUP) exit;

GUI_POPUP_VISIBLE = false;
GUI_POPUP_LAYER_GROUP = undefined;

/// @func							show_popup(_layer_group_name = "popup_")
/// @desc						shows all popup layers
/// @param {string="popup_"} _layer_group_name	starts_with for layers to show
function show_popup(_layer_group_name = "popup_*") {
	if (!GUI_POPUP_VISIBLE) {
		dlog($"Showing popup view '{_layer_group_name}'");
		var depth_range = layer_set_all_visible(_layer_group_name, true);
		GUI_POPUP_LAYER_GROUP = _layer_group_name;
		GUI_POPUP_VISIBLE = true;
		GUI_POPUP_MIN_DEPTH = depth_range[0];
		BROADCASTER.send(self, __RAPTOR_BROADCAST_POPUP_SHOWN, { layer_group_name: _layer_group_name });
	} else 
		wlog($"** WARNING ** Attempt to show popup '{_layer_group_name}' ignored, a popup '{GUI_POPUP_LAYER_GROUP}' is already visible");
}

/// @func				hide_popup()
/// @desc			hides all popup layers shown through show_popup
function hide_popup() {
	vlog($"Attempting to hide popup '{GUI_POPUP_LAYER_GROUP}'");
	if (GUI_POPUP_VISIBLE) {
		dlog($"Hiding popup view '{GUI_POPUP_LAYER_GROUP}'");
		layer_set_all_visible(GUI_POPUP_LAYER_GROUP, false);
		var _layer_group_name = GUI_POPUP_LAYER_GROUP;
		GUI_POPUP_LAYER_GROUP = undefined;
		GUI_POPUP_VISIBLE = false;
		GUI_POPUP_MIN_DEPTH = DEPTH_BOTTOM_MOST;
		BROADCASTER.send(self, __RAPTOR_BROADCAST_POPUP_HIDDEN, { layer_group_name: _layer_group_name });
	}
}

