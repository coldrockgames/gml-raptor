/// @func msg_show_ok(title, text, ok_callback = undefined)
function msg_show_ok(title, text, ok_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_ok(ok_callback, __MSGBOX_HOTKEY_ENTER);
	msg.x_button_uses_escape_callback = false;
	msg.x_button_callback = ok_callback;
	return msg.show();
}

/// @func msg_show_ok_cancel(title, text, ok_callback = undefined, cancel_callback = undefined)
function msg_show_ok_cancel(title, text, ok_callback = undefined, cancel_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_ok(ok_callback, __MSGBOX_HOTKEY_ENTER);
	msg.add_cancel(cancel_callback, __MSGBOX_HOTKEY_ESCAPE);
	return msg.show();
}

/// @func msg_show_yes_no(title, text, yes_callback = undefined, no_callback = undefined)
function msg_show_yes_no(title, text, yes_callback = undefined, no_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_yes(yes_callback, __MSGBOX_HOTKEY_ENTER);
	msg.add_no(no_callback, __MSGBOX_HOTKEY_ESCAPE);
	return msg.show();
}

/// @func msg_show_yes_no_cancel(title, text, yes_callback = undefined, no_callback = undefined, cancel_callback = undefined)
function msg_show_yes_no_cancel(title, text, yes_callback = undefined, no_callback = undefined, cancel_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_yes(yes_callback, __MSGBOX_HOTKEY_ENTER);
	msg.add_no(no_callback, __MSGBOX_HOTKEY_NONE);
	msg.add_cancel(cancel_callback, __MSGBOX_HOTKEY_ESCAPE);
	return msg.show();
}

/// @func msg_show_retry_ignore(title, text, retry_callback = undefined, ignore_callback = undefined)
function msg_show_retry_ignore(title, text, retry_callback = undefined, ignore_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_retry(retry_callback, __MSGBOX_HOTKEY_NONE);
	msg.add_ignore(ignore_callback, __MSGBOX_HOTKEY_NONE);
	return msg.show();
}

/// @func msg_show_save_cancel(title, text, save_callback = undefined, cancel_callback = undefined)
function msg_show_save_cancel(title, text, save_callback = undefined, cancel_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_save(save_callback, __MSGBOX_HOTKEY_ENTER);
	msg.add_cancel(cancel_callback, __MSGBOX_HOTKEY_ESCAPE);
	return msg.show();
}

function __get_default_msgbox(title, text) {
	return new MessageBox(MESSAGEBOX_WINDOW, MESSAGEBOX_LAYER, LG_resolve(title), LG_resolve(text));
}
