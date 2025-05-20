/// @description event
event_inherited();

var label_struct = {
	text: "[scale,1.5][ci_accent]UTE - raptor Unit Test Engine",
	text_color: THEME_CONTROL_BRIGHT,
	text_color_mouse_over: THEME_CONTROL_BRIGHT,
	draw_color: THEME_CONTROL_TEXT,
	draw_color_mouse_over: THEME_CONTROL_TEXT,
	font_to_use: "fntUnitTest",
	scribble_text_align: "[fa_top][fa_left]",
};

UI_ROOT
	.clear_children()
	.add_control(Panel, {sprite_index: spr1pxWhite128, startup_height:144})
		.set_padding_all(12)
		.set_dock(dock.top)
		.add_control(Label, struct_join(label_struct, {	text: "[scale,1.5][ci_accent]UTE - raptor Unit Test Engine", }))
		.set_position(48, 32)
		.add_control(Label, struct_join(label_struct, {	text: "[scale,1.5]Discovered Test Suites", }))
		.set_position(48, 84)
		.add_control(Label, struct_join(label_struct, {	text: "[scale,1.5]Detailled Test Results", }))
		.set_position(840, 84)
		.step_out()
	.add_control(ScrollPanel, { 
			startup_width:1096, 
			startup_height: 936, 
			wheel_scroll_lines: 6, 
			mouse_drag_mode: mouse_drag.right,
			mouse_drag_multiplier: 4.0,
		})
		.set_dock(dock.right)
		.step_out()
		.get_instance()
		.set_content_object(UnitTestResultsViewer, {
			detail_mode: true, 
			startup_width: 1070, 
			startup_height:912,
		})
		.get_parent_tree()
	.add_control(ScrollPanel, { 
			startup_width:824, 
			startup_height: 936, 
			wheel_scroll_lines: 6, 
			mouse_drag_mode: mouse_drag.right,
			mouse_drag_multiplier: 4.0,
		})
		.set_dock(dock.fill)
		.step_out()
		.get_instance()
		.set_content_object(UnitTestResultsViewer, { 
			detail_mode: false,
			startup_width: 798, 
			startup_height:912,
		})
		.get_parent_tree()
	.step_out()
.build();


__RUN_UNIT_TESTS;
