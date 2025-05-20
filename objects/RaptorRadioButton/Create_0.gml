/// @desc uncheck_all method

// Inherit the parent event
event_inherited();

__auto_change_checked = false;

uncheck_all_but_me = function() {
	with (RaptorRadioButton) {
		if (radio_group_name == other.radio_group_name) set_checked(eq(self, other));
		__set_default_image();
	}
}
