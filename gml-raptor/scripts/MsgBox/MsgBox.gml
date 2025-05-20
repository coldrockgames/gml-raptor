/*
	MsgBox - Simple MessageBox implementation
	
	This script allows you to create Windows-Style MessageBoxes with a title, text, an optional icon
	and any number of buttons.
	Buttons are always bottom-aligned and centered.
	Window dimension is calculated automatically based on the text to display.
	LG() is fully supported for title and text. Just supply a string that starts with "=" like in any other
	text property.
	
*/

#macro ACTIVE_MESSAGE_BOX		global.__active_message_box

#macro __MSGBOX_HOTKEY_ENTER	"vk_enter"
#macro __MSGBOX_HOTKEY_ESCAPE	"vk_escape"
#macro __MSGBOX_HOTKEY_NONE		""


// init undefined on game load
ACTIVE_MESSAGE_BOX = undefined;

function __msgbox_button(obj, btn_text, cb, layer_name, react_on_key) constructor {
	object = obj;
	callback = cb;
	button_text = string_starts_with(btn_text, "=") ? LG(string_skip_start(btn_text, 1)) : btn_text;
	button_size = scribble_measure_text(button_text, MESSAGEBOX_FONT);
	button_pos	= 0;
	__layer_name = layer_name;
	__hotkey = react_on_key;
	__button = undefined;
	
	static create_instance = function(_in) {
		return
			_in.add_control(object, {
				startup_width: max(MESSAGEBOX_BUTTON_MIN_WIDTH, button_size.x),
				startup_height: max(MESSAGEBOX_BUTTON_MIN_HEIGHT, button_size.y),
				text: button_text,
				font_to_use: MESSAGEBOX_FONT,
				on_left_click: __msgbox_callback_wrapper,
				hotkey_left_click: __hotkey
			}).set_position(button_pos, 0).get_instance();
	}
}

// "self" is the button here - its called from the button
function __msgbox_callback_wrapper(sender) {
	with (sender) {
		vlog($"{MY_NAME}: Invoking callback.");
		var btnstruct = undefined;
		for (var i = 0; i < array_length(ACTIVE_MESSAGE_BOX.__buttons); i++) {
			if (eq(ACTIVE_MESSAGE_BOX.__buttons[i].__button, self)) {
				btnstruct = ACTIVE_MESSAGE_BOX.__buttons[i];
				break;
			}
		}
		ACTIVE_MESSAGE_BOX.close();
		if (btnstruct != undefined) {
			invoke_if_exists(btnstruct, "callback");
		} else
			elog($"* ERROR * Could not find MessageBox Button in __buttons array!");
	}
}

function __msgbox_x_button_default_callback() {
	var callback_to_use = undefined;
	if (ACTIVE_MESSAGE_BOX.x_button_uses_escape_callback) {
		var esc = ACTIVE_MESSAGE_BOX.__find_button_with_hotkey(__MSGBOX_HOTKEY_ESCAPE);
		if (esc != undefined && esc.callback != undefined) {
			vlog($"MessageBox closed through X-Button redirect to escape-key-callback.");
			callback_to_use = esc.callback;
		}
	} else if (ACTIVE_MESSAGE_BOX.x_button_callback != undefined) {
		vlog($"MessageBox closed through X-Button callback.");
		callback_to_use = ACTIVE_MESSAGE_BOX.x_button_callback;
	}
	ACTIVE_MESSAGE_BOX.close();
	if (callback_to_use != undefined)
		callback_to_use();
}

/// @func	MessageBox(window_object, layer_name, message_title, message_text)
/// @desc	create a new messagebox window with a specified window object
function MessageBox(window_object, layer_name, message_title, message_text) constructor {
	
	if (!is_child_of(window_object, MessageBoxWindow)) {
		elog($"** ERROR ** Invalid Window Object for MessageBox. MUST be a child of MessageBoxWindow!");
	}
	title	= string_starts_with(message_title, "=") ? LG(message_title) : message_title;
	text	= string_starts_with(message_text, "=")  ? LG(message_text)  : message_text;
	window	= undefined;
	x_button_uses_escape_callback = true;
	
	__window_object = window_object;
	__layer_name = layer_name;
	__buttons = [];
	__prev_messagebox = undefined;

	/// @func	__find_button_with_hotkey(hotkey)
	/// @desc	find the button that uses a specific hotkey
	static __find_button_with_hotkey = function(hotkey) {
		for (var i = 0, len = array_length(__buttons); i < len; i++) {
			if (__buttons[i].__hotkey == hotkey) {
				return __buttons[i];
			}
		}
		return undefined;
	}

	static __get_max_button_height = function() {
		var rv = 0;
		for (var i = 0, len = array_length(__buttons); i < len; i++) {
			rv = max(rv, __buttons[@i].button_size.y);
		}
		return rv;
	}

	/// @func	show()
	static show = function() {
		dlog($"Showing MessageBox");
		__prev_messagebox = ACTIVE_MESSAGE_BOX;
		ACTIVE_MESSAGE_BOX = self;
		
		var text_size = scribble_measure_text(text, MESSAGEBOX_FONT);
		var wintitle = title;
		var wintext = text;
		var max_button_height = __get_max_button_height();
		var button_total_width = 0;
		for (var i = 0, len = array_length(__buttons); i < len; i++) {
			__buttons[@i].button_pos = button_total_width;
			button_total_width += 
				max(MESSAGEBOX_BUTTON_MIN_WIDTH, __buttons[@i].button_size.x) + MESSAGEBOX_BUTTON_SPACE;
		}
		// remove the distance_between after the last button, then we have total width of all buttons
		button_total_width -= MESSAGEBOX_BUTTON_SPACE;
		
		var atdepth = layer_exists(layer_get_id(MESSAGEBOX_LAYER)) ? MESSAGEBOX_LAYER : 0;
		window = instance_create(0, 0, atdepth, __window_object, {
			title: wintitle,
			font_to_use: MESSAGEBOX_TITLE_FONT
		});
		
		var extra_size = 2 * MESSAGEBOX_INNER_MARGIN;
		window.set_client_area(
			max(button_total_width, text_size.x) + extra_size,
			text_size.y + 1.5 * extra_size + max_button_height
		);

		with(window) {
			x = max(0, UI_VIEW_CENTER_X - SELF_CENTER_X);
			y = UI_VIEW_CENTER_Y - SELF_CENTER_Y - UI_VIEW_HEIGHT / 6;
			y = min(max(y, 0), UI_VIEW_HEIGHT - sprite_height);
			force_redraw();
			run_delayed(self, 1, function() { 
				// tweak to avoid button rubberbanding part 2
				control_tree.get_element("panButtons").control_tree.control.visible = true;
				control_tree.layout(true); 
			});
		}
		
		if (__find_button_with_hotkey(__MSGBOX_HOTKEY_ESCAPE) == undefined)
			window.get_x_button().hotkey_left_click = __MSGBOX_HOTKEY_ESCAPE;
		
		var panel = window.control_tree.get_element("panButtons").control_tree;
		for (var i = 0; i < array_length(__buttons); i++) 
			__buttons[@i].__button = __buttons[@i].create_instance(panel);
		panel.control.set_client_area(button_total_width, max_button_height);
		panel.control.visible = false; // tweak to avoid button rubberbanding part 1
		
		show_popup(MESSAGEBOX_LAYER);
		BROADCASTER.send(self, __RAPTOR_BROADCAST_MSGBOX_OPENED);
		return self;
	}

	/// @func	close()
	static close = function() {
		window.close();
		ACTIVE_MESSAGE_BOX = __prev_messagebox;
		BROADCASTER.send(self, __RAPTOR_BROADCAST_MSGBOX_CLOSED);
		dlog($"MessageBox closed");
		if (ACTIVE_MESSAGE_BOX == undefined)
			hide_popup();
	}
	
	/// @func	add_button(button_object, button_text, on_click_callback, hotkey = "")
	/// @desc	add any custom button to the window
	static add_button = function(button_object, button_text, on_click_callback, hotkey = "") {
		if (hotkey != "") {
			// If the same hotkey is used multiple times, remove it from existing button (last one wins)
			var existing = __find_button_with_hotkey(hotkey);
			if (existing != undefined) existing.hotkey = "";
		}
		array_push(__buttons, new __msgbox_button(button_object, button_text, on_click_callback, __layer_name, hotkey));
		return self;
	}
	
	/// @func	add_yes(on_yes_callback, hotkey = "")
	/// @desc	add a yes-button to the window
	static add_yes = function(on_yes_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/yes", on_yes_callback, hotkey);
	}
	/// @func	add_no(on_no_callback, hotkey = "")
	/// @desc	add a no-button to the window
	static add_no = function(on_no_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/no", on_no_callback, hotkey);
	}
	/// @func	add_ok(on_ok_callback, hotkey = "")
	/// @desc	add an ok-button to the window
	static add_ok = function(on_ok_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/ok", on_ok_callback, hotkey);
	}
	/// @func	add_cancel(on_cancel_callback, hotkey = "")
	/// @desc	add a cancel-button to the window
	static add_cancel = function(on_cancel_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/cancel", on_cancel_callback, hotkey);
	}
	/// @func	add_continue(on_continue_callback, hotkey = "")
	/// @desc	add a continue-button to the window
	static add_continue = function(on_continue_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/continue", on_continue_callback, hotkey);
	}
	/// @func	add_retry(on_retry_callback, hotkey = "")
	/// @desc	add a retry-button to the window
	static add_retry = function(on_retry_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/retry", on_retry_callback, hotkey);
	}
	/// @func	add_ignore(on_ignore_callback, hotkey = "")
	/// @desc	add an ignore-button to the window
	static add_ignore = function(on_ignore_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/ignore", on_ignore_callback, hotkey);
	}
	/// @func	add_save(on_save_callback, hotkey = "")
	/// @desc	add a save-button to the window
	static add_save = function(on_save_callback, hotkey = "") {
		return add_button(MESSAGEBOX_BUTTON, "=global_words/buttons/save", on_save_callback, hotkey);
	}
	
}
