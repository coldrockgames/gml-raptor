/// @desc release knob

if (__LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

if (__SLIDER_IN_FOCUS == self)
	__SLIDER_IN_FOCUS = undefined;
	
__knob_grabbed = false;
check_mouse_over_knob();

