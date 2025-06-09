/*
    Adds debug panels to gamemaker's debug view
*/

#macro __RAPTOR_DEBUG_VIEW_EDGE			4

#macro __RAPTOR_DEBUG_VIEW_WIDTH		300
#macro __RAPTOR_DEBUG_VIEW_HEIGHT		276

#macro __RAPTOR_DEBUG_CAM_VIEW_WIDTH	300
#macro __RAPTOR_DEBUG_CAM_VIEW_HEIGHT	276

function __raptor_debug_view_opened() {
	
	// Default debug view
	dlog("Creating 'raptor' debug view");
	global.__raptor_debug_view = dbg_view("raptor", DEBUG_VIEW_SHOW_RAPTOR_PANEL, 
		__RAPTOR_DEBUG_VIEW_EDGE, 
		WINDOW_SIZE_Y - __RAPTOR_DEBUG_VIEW_HEIGHT - __RAPTOR_DEBUG_VIEW_EDGE, 
		__RAPTOR_DEBUG_VIEW_WIDTH, 
		__RAPTOR_DEBUG_VIEW_HEIGHT
	);
	dbg_section("Object Frames", true);
	dbg_checkbox(ref_create(global, "__debug_show_object_frames"), "Object Frames"); 
	dbg_checkbox(ref_create(global, "__debug_show_object_depth"), "Depth");
	dbg_section("ListPools", true);
	dbg_text("Bindings:     "); dbg_same_line(); dbg_text(ref_create(BINDINGS, "__listcount"));
	dbg_text("Animations:   "); dbg_same_line(); dbg_text(ref_create(ANIMATIONS, "__listcount"));
	dbg_text("StateMachines:"); dbg_same_line(); dbg_text(ref_create(STATEMACHINES, "__listcount"));
	dbg_section("Broadcasts", true);
	dbg_text("Receivers:"); dbg_same_line(); dbg_text(ref_create(BROADCASTER, "__receivercount")); 
	dbg_same_line(); dbg_text(" | "); dbg_same_line();
	dbg_text("Sent:     "); dbg_same_line(); dbg_text(ref_create(global, "__raptor_broadcast_uid"));
	dbg_section("Mouse", true);
	dbg_text("World:"); dbg_same_line(); dbg_text(ref_create(global, "__world_mouse_xprevious")); dbg_same_line(); dbg_text("/"); dbg_same_line(); dbg_text(ref_create(global, "__world_mouse_yprevious"));
	dbg_text("UI   :"); dbg_same_line(); dbg_text(ref_create(global, "__gui_mouse_x"));	          dbg_same_line(); dbg_text("/"); dbg_same_line(); dbg_text(ref_create(global, "__gui_mouse_y"));

	// Debug camera view
	var DEBUG_CAM_BUTTON_SIZE	= 20
	
	dlog("Creating 'raptor-camera' debug view");
	global.__raptor_debug_cam_view = dbg_view("raptor-camera", DEBUG_VIEW_SHOW_CAMERA_PANEL, 
		__RAPTOR_DEBUG_VIEW_EDGE + __RAPTOR_DEBUG_VIEW_WIDTH + __RAPTOR_DEBUG_VIEW_EDGE, 
		WINDOW_SIZE_Y - __RAPTOR_DEBUG_CAM_VIEW_HEIGHT - __RAPTOR_DEBUG_VIEW_EDGE, 
		__RAPTOR_DEBUG_CAM_VIEW_WIDTH, 
		__RAPTOR_DEBUG_CAM_VIEW_HEIGHT
	);
	if (!variable_global_exists("__raptor_debug_cam_view_data"))
		global.__raptor_debug_cam_view_data = {
			left: CAM_LEFT_EDGE,
			top: CAM_TOP_EDGE,
			width: CAM_WIDTH,
			move_step: 100,
			zoom_step: 100,
			zoom_min_width: 640,
			zoom_max_width: 1920,
			respect_border: true,
			last_visible: false,
		};
	dbg_section("Camera Control", true);
	dbg_text("      Pos");
	dbg_text("     ");
	dbg_same_line(); dbg_button("^", function() { 
			ROOMCONTROLLER.camera_move_by(3, 0, -global.__raptor_debug_cam_view_data.move_step)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border); 
		}, DEBUG_CAM_BUTTON_SIZE, DEBUG_CAM_BUTTON_SIZE
	);
	dbg_same_line(); dbg_text("      Zoom");
	dbg_text(" ");
	dbg_same_line(); dbg_button("<", function() { 
			ROOMCONTROLLER.camera_move_by(3, -global.__raptor_debug_cam_view_data.move_step, 0)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border); 
		}, DEBUG_CAM_BUTTON_SIZE, DEBUG_CAM_BUTTON_SIZE
	);
	dbg_same_line(); dbg_button("o", function() {
			ROOMCONTROLLER.camera_move_to(3, global.__raptor_debug_cam_view_data.left, global.__raptor_debug_cam_view_data.top)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border);
			ROOMCONTROLLER.camera_zoom_to(3, global.__raptor_debug_cam_view_data.width)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border);
		}, DEBUG_CAM_BUTTON_SIZE, DEBUG_CAM_BUTTON_SIZE
	);
	dbg_same_line(); dbg_button(">", function() { 
			ROOMCONTROLLER.camera_move_by(3,  global.__raptor_debug_cam_view_data.move_step, 0)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border); 
		}, DEBUG_CAM_BUTTON_SIZE, DEBUG_CAM_BUTTON_SIZE
	);
	dbg_same_line(); dbg_text(" ");
	dbg_same_line(); dbg_button("+", function() { 
			ROOMCONTROLLER.camera_zoom_by(3, 
				-global.__raptor_debug_cam_view_data.zoom_step, 
				global.__raptor_debug_cam_view_data.zoom_min_width, 
				global.__raptor_debug_cam_view_data.zoom_max_width)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border);
		}, DEBUG_CAM_BUTTON_SIZE, DEBUG_CAM_BUTTON_SIZE
	);
	dbg_same_line(); dbg_button("-", function() { 
			ROOMCONTROLLER.camera_zoom_by(3,  global.__raptor_debug_cam_view_data.zoom_step, 500, 1900)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border); 
		}, DEBUG_CAM_BUTTON_SIZE, DEBUG_CAM_BUTTON_SIZE);
	dbg_text("     ");
	dbg_same_line(); dbg_button("v", function() { 
			ROOMCONTROLLER.camera_move_by(3, 0, global.__raptor_debug_cam_view_data.move_step)
				.set_stop_at_room_borders(global.__raptor_debug_cam_view_data.respect_border); 
		}, DEBUG_CAM_BUTTON_SIZE, DEBUG_CAM_BUTTON_SIZE);
	dbg_slider_int(ref_create(global.__raptor_debug_cam_view_data, "move_step"),        5,  500, "Camera Move Step", 5); dbg_same_line(); dbg_text("px");
	dbg_slider_int(ref_create(global.__raptor_debug_cam_view_data, "zoom_step"),        5,  500, "Camera Zoom Step", 5); dbg_same_line(); dbg_text("px");
	dbg_slider_int(ref_create(global.__raptor_debug_cam_view_data, "zoom_min_width"), 320, 3840, "Camera Min Width", 5); dbg_same_line(); dbg_text("px");
	dbg_slider_int(ref_create(global.__raptor_debug_cam_view_data, "zoom_max_width"), 320, 3840, "Camera Max Width", 5); dbg_same_line(); dbg_text("px");
	dbg_checkbox  (ref_create(global.__raptor_debug_cam_view_data, "respect_border"), "Respect Room Borders");	
}

function __raptor_debug_view_closed() {
	dlog("Deleting 'raptor' debug view");
	dbg_view_delete(global.__raptor_debug_view);
	dbg_view_delete(global.__raptor_debug_cam_view);
	ROOMCONTROLLER.camera_move_to(3, global.__raptor_debug_cam_view_data.left, global.__raptor_debug_cam_view_data.top);
	ROOMCONTROLLER.camera_zoom_to(3, global.__raptor_debug_cam_view_data.width);
}
