/// @desc unset global variable

if (ROOMCONTROLLER == self) ROOMCONTROLLER = undefined;
if (PARTSYS != undefined) {
	if (is_array(PARTSYS)) {
		for (var i = 0; i < array_length(PARTSYS); i++) {
			var ps = PARTSYS[@ i];
			ps.cleanup();
		}
	} else
		PARTSYS.cleanup();
}

if (__ui_root_control != undefined) {
	UI_ROOT.clear();
	instance_destroy(__ui_root_control);
}

event_inherited();
