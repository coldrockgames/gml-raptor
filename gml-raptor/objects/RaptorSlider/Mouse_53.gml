/// @desc grab knob

if (__LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

check_mouse_over_knob();

__knob_grabbed = __mouse_over_knob;
if (__knob_grabbed || mouse_is_over)
	__SLIDER_IN_FOCUS = self;
