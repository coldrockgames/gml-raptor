/*
    Callbacks of the animation test controls
*/

function anim_test_rotate_checked_changed() {
	var checked = chkAnimTestRotate.checked;
	with(AnimTestObject)
		if (checked) start_rotating(); else stop_rotating();
}

function anim_test_start_click() {
	//PARTSYS.burst_at(600,1000,"emRocket", 8); return;
	with(AnimTestObject)
		start_running();
}

function anim_test_pause_click() {
	animation_pause_all(AnimTestObject);
}

function anim_test_resume_click() {
	animation_resume_all(AnimTestObject);
}

function anim_test_abort_click() {
	with(AnimTestObject)
		if (move_anim != undefined) with(move_anim) abort();
}

function anim_test_finish_click() {
	with(AnimTestObject)
		if (move_anim != undefined) with(move_anim) finish();
}