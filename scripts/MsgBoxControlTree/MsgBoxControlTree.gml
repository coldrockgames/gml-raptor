/*
    The ControlTree for MessageboxWindows
*/

function MsgBoxControlTree(_control = undefined) : ControlTree(_control) constructor {
	construct(MsgBoxControlTree);
	
	add_control(Panel, {
			startup_height: ACTIVE_MESSAGE_BOX.__get_max_button_height() + 2 * MESSAGEBOX_INNER_MARGIN
		})
		.set_margin(MESSAGEBOX_INNER_MARGIN, 0, MESSAGEBOX_INNER_MARGIN, MESSAGEBOX_INNER_MARGIN)
		.set_dock(dock.bottom)
		.add_control(Panel, {
				startup_height: ACTIVE_MESSAGE_BOX.__get_max_button_height()
			})
			.set_name("panButtons")
			.set_align(fa_middle, fa_center)
			.step_out()
		.step_out()
	.add_control(Panel)
		.set_dock(dock.fill)
		.set_name("panContent")
		.set_padding_all(MESSAGEBOX_INNER_MARGIN)
		.add_control(MESSAGEBOX_TEXT_LABEL, { 
				text: ACTIVE_MESSAGE_BOX.text,
				font_to_use: MESSAGEBOX_FONT,
				scribble_text_align: "[fa_top][fa_center]"
			})
			.set_dock(dock.fill)
			.set_name("lblText")
			.step_out()
		.step_out()
	.build()
;
}