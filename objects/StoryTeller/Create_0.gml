/// @desc set up typist
event_inherited();

#macro STORY_TELLER_ANIMATIONS		global.__STORY_TELLER_ANIMATIONS
if (!variable_global_exists("__STORY_TELLER_ANIMATIONS"))
	STORY_TELLER_ANIMATIONS = {};

typist_active = false;
typist = undefined;

skip_to_end = function() {
	typist_active = false;
	STORY_TELLER_ANIMATIONS[$ MY_NAME] = true;
	invoke_completed();
}

already_animated = function() {
	return vsget(STORY_TELLER_ANIMATIONS, MY_NAME, false);
}

invoke_started = function() {
	if (on_typist_started != undefined)
		on_typist_started(self);
}

invoke_completed = function() {
	if (on_typist_completed != undefined)
		on_typist_completed(self);
}

restart = function() {
	ilog($"{MY_NAME} restarting story telling");
	STORY_TELLER_ANIMATIONS[$ MY_NAME] = false;
	typist = undefined;
	typist_active = false;
	force_redraw();
	__wait_for_start_delay();	
}

__wait_for_start_delay = function() {
	if (!already_animated() || !animate_only_once) {
		run_delayed(self, activation_delay, function() { typist_active = true; });
	} else
		invoke_completed();
}
__wait_for_start_delay();

/// @func					draw_scribble_text()
/// @desc				draw the text - redefine for additional text effects
draw_scribble_text = function() {
	if (typist_active) {
		if (__scribble_text != undefined)
			__scribble_text.draw(__text_x, __text_y, typist);
			
		if (animate_only_once && !already_animated() && typist.get_state() == 1) {
			skip_to_end();
		}
	} else if (already_animated())
		__scribble_text.draw(__text_x, __text_y);
}

/// @func					__create_scribble_object(align, str)
/// @desc				setup the initial object to work with
/// @param {string} align			
/// @param {string} str			
__create_scribble_object = function(align, str) {
	if (typist == undefined) {
		typist = scribble_typist(typist_line_mode);
		typist.in(chars_per_frame, smoothness);
		invoke_started();
	}
	// Feather ignore GM1041
	return scribble(string_concat(align, str), MY_NAME)
			.starting_format(
				font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
				animated_text_color)
			.outline(outline_color)
			.shadow(shadow_color, shadow_alpha);
}
