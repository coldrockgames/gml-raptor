/// @desc Controls GUI, Camera and Hotkeys
/*
	You can use a RoomController on its own or simply make it the parent
	of ONE of your other controller objects in the game.
	
	This object contains functionality for three main topics in a room:
	- GUI Control		Mouse Position translation from world to ui coordinates
	- Hotkey Control	Define global hotkeys for the entire room
	- Camera Control	Create cool Camera moves and effects
	
	GUI CONTROL
	-----------
	The GuiController is a passice object, that only does one single thing:
	Every step (exactly: in the BEGIN STEP event to make sure, coordinates are
	already updated when the controls enter their step events), 
	the mouse position is converted to GUI coordinates and stored
	in the global.__gui_mouse_x and global.__gui_mouse_y variables.
	These can also be accessed through the macros
	GUI_MOUSE_X and GUI_MOUSE_Y.
	
	Make sure to have a GuiController active in the room when using any control
	derived from _baseControl, as they rely on the existence of those globals.
	
	CAMERA CONTROL
	--------------
	This object allows a bit control over the camera by adding effects to it.
	There are flights to specific positions, rumble/screenshake and zoom effects.
	Note: A camera flight will maybe lead to unexpected results when the camera
	is following a specific instance in the viewport settings.

	HOTKEY CONTROL
	--------------
	tbd
	
	ROOM TRANSITION CONTROL
	-----------------------
	
*/

event_inherited();

#macro ROOMCONTROLLER			global.__room_controller
ROOMCONTROLLER = self;

/// @func onGameLoadFailed(_exception)
onGameLoadFailed = function(_exception) {
	elog($"** ERROR ** Game load failed: {_exception.message}");
}

// Set up world UI system
#macro UI_ROOT					global.__ui_root
__ui_root_control = instance_create(0, 0, layer, RaptorUiRootPanel);
UI_ROOT = __ui_root_control.control_tree;

// Set up particle systems
#macro PARTSYS					global.__room_particle_system
if (particle_layer_names == undefined || (is_string(particle_layer_names) && string_is_empty(particle_layer_names))) {
	PARTSYS = undefined;
} else {
	if (is_string(particle_layer_names)) {
		PARTSYS = new ParticleManager(particle_layer_names);
	} else if (is_array(particle_layer_names)) {
		PARTSYS = array_create(array_length(particle_layer_names));
		for (var i = 0; i < array_length(PARTSYS); i++)
			PARTSYS[@ i] = new ParticleManager(particle_layer_names[@ i], i);
	} else
		PARTSYS = undefined;
	
	if (PARTSYS != undefined)
		setup_particle_types();

}

// Resizes the app surface to the dimensions of this room's main viewport
if (adapt_app_surface && view_get_visible(0)) {
	surface_resize(application_surface,VIEW_WIDTH,VIEW_HEIGHT);
}

/*
	-------------------
		GUI CONTROL
	-------------------
*/
#region GUI CONTROL

/// @func set_gui_size(_gui_width, _gui_height)
/// @desc Set the gui to a new size. This will also rescale the UI_ROOT
set_gui_size = function(_gui_width, _gui_height) {
	display_set_gui_size(_gui_width, _gui_height);
	__ui_root_control.maximize_on_screen();
}
set_gui_size(VIEW_WIDTH, VIEW_HEIGHT);
//set_gui_size(CAM_WIDTH, CAM_HEIGHT);

#macro GUI_MOUSE_X_PREVIOUS		global.__gui_mouse_xprevious
#macro GUI_MOUSE_Y_PREVIOUS		global.__gui_mouse_yprevious
#macro GUI_MOUSE_X				global.__gui_mouse_x
#macro GUI_MOUSE_Y				global.__gui_mouse_y
#macro GUI_MOUSE_DELTA_X		global.__gui_mouse_xmove
#macro GUI_MOUSE_DELTA_Y		global.__gui_mouse_ymove
#macro GUI_MOUSE_HAS_MOVED		global.__gui_mouse_has_moved

#macro MOUSE_X_PREVIOUS			global.__world_mouse_xprevious
#macro MOUSE_Y_PREVIOUS			global.__world_mouse_yprevious
#macro MOUSE_X					mouse_x
#macro MOUSE_Y					mouse_y
#macro MOUSE_DELTA_X			global.__world_mouse_xmove
#macro MOUSE_DELTA_Y			global.__world_mouse_ymove
#macro MOUSE_HAS_MOVED			global.__world_mouse_has_moved

#macro CTL_MOUSE_X_PREVIOUS		(SELF_DRAW_ON_GUI ? GUI_MOUSE_X_PREVIOUS : MOUSE_X_PREVIOUS)
#macro CTL_MOUSE_Y_PREVIOUS		(SELF_DRAW_ON_GUI ? GUI_MOUSE_Y_PREVIOUS : MOUSE_Y_PREVIOUS)
#macro CTL_MOUSE_X				(SELF_DRAW_ON_GUI ? GUI_MOUSE_X			 : MOUSE_X)
#macro CTL_MOUSE_Y				(SELF_DRAW_ON_GUI ? GUI_MOUSE_Y			 : MOUSE_Y)
#macro CTL_MOUSE_DELTA_X		(SELF_DRAW_ON_GUI ? GUI_MOUSE_DELTA_X	 : MOUSE_DELTA_X)
#macro CTL_MOUSE_DELTA_Y		(SELF_DRAW_ON_GUI ? GUI_MOUSE_DELTA_Y	 : MOUSE_DELTA_Y)
#macro CTL_MOUSE_HAS_MOVED		(SELF_DRAW_ON_GUI ? GUI_MOUSE_HAS_MOVED  : MOUSE_HAS_MOVED)

GUI_MOUSE_X = device_mouse_x_to_gui(0);
GUI_MOUSE_Y = device_mouse_y_to_gui(0);
MOUSE_X_PREVIOUS = mouse_x;
MOUSE_Y_PREVIOUS = mouse_y;

#macro WINDOW_SIZE_X			global.__window_size_x
#macro WINDOW_SIZE_Y			global.__window_size_y
#macro WINDOW_SIZE_DELTA_X		global.__window_size_xmove
#macro WINDOW_SIZE_DELTA_Y		global.__window_size_ymove
#macro WINDOW_SIZE_X_PREVIOUS	global.__window_size_xprevious
#macro WINDOW_SIZE_Y_PREVIOUS	global.__window_size_yprevious
#macro WINDOW_SIZE_HAS_CHANGED	global.__window_size_has_changed

WINDOW_SIZE_X					= window_get_width();
WINDOW_SIZE_Y					= window_get_height();
WINDOW_SIZE_DELTA_X				= 0;
WINDOW_SIZE_DELTA_Y				= 0;
WINDOW_SIZE_X_PREVIOUS			= WINDOW_SIZE_X;
WINDOW_SIZE_Y_PREVIOUS			= WINDOW_SIZE_Y;
WINDOW_SIZE_HAS_CHANGED			= false;

#macro CAM_X_PREVIOUS			global.__cam_x_previous
#macro CAM_Y_PREVIOUS			global.__cam_y_previous
#macro CAM_WIDTH_PREVIOUS		global.__cam_width_previous
#macro CAM_HEIGHT_PREVIOUS		global.__cam_height_previous
#macro CAM_HAS_SIZED			global.__cam_has_sized
#macro CAM_HAS_MOVED			global.__cam_has_moved
#macro CAM_HAS_CHANGED			global.__cam_has_changed

CAM_X_PREVIOUS					= CAM_LEFT_EDGE;
CAM_Y_PREVIOUS					= CAM_TOP_EDGE;
CAM_WIDTH_PREVIOUS				= CAM_WIDTH;
CAM_HEIGHT_PREVIOUS				= CAM_HEIGHT;
CAM_HAS_SIZED					= false;
CAM_HAS_MOVED					= false;
CAM_HAS_CHANGED					= false;

#macro GAME_SPEED				global.__game_speed
GAME_SPEED = 1;

#macro DELTA_TIME_SECS			global.__delta_time_secs
DELTA_TIME_SECS = 0;

#macro DELTA_TIME_SECS_REAL		global.__delta_time_secs_real
DELTA_TIME_SECS_REAL = 0;

#endregion

#region DRAW DEBUG FRAMES
__dbg_inst		= undefined;
__dbg_scale		= new Coord2();
__dbg_trans		= new Coord2();
__dbg_tl		= new Coord2();
__dbg_tr		= new Coord2();
__dbg_bl		= new Coord2();
__dbg_br		= new Coord2();	
__dbg_rot_tl	= new Coord2();
__dbg_rot_tr	= new Coord2();
__dbg_rot_bl	= new Coord2();
__dbg_rot_br	= new Coord2();
__dbg_angle		= 0;
__dbg_cos		= 0;
__dbg_sin		= 0;

__draw_bbox_rotated = function() {
	__dbg_scale.set(UI_VIEW_TO_CAM_FACTOR_X, UI_VIEW_TO_CAM_FACTOR_Y);
	
	for (var i = 0; i < instance_count; i++;) {
		__dbg_inst = instance_id[i];

		if (!__dbg_inst.visible || __dbg_inst.sprite_index < 0 || eq(__dbg_inst, __ui_root_control))
			continue;

		with(__dbg_inst) {
			draw_set_color(
				vsget(self, "mouse_is_over", false) ? 
				vsget(self, __RAPTOR_DEBUG_FRAME_COLOR_OVER_STR, c_fuchsia) :
				vsget(self, __RAPTOR_DEBUG_FRAME_COLOR_STR, c_green)
			);
				
			if (SELF_DRAW_ON_GUI)
				translate_gui_to_world(x, y, other.__dbg_trans);
			else 
				other.__dbg_trans.set(x, y);
			
			if (DEBUG_SHOW_OBJECT_DEPTH)
				draw_text(x - sprite_xoffset + 4, y - sprite_yoffset + 4, string(depth));
		}
		
		if (DEBUG_SHOW_OBJECT_FRAMES) {		
			__dbg_tl.set(-__dbg_inst.sprite_xoffset * __dbg_scale.x, -__dbg_inst.sprite_yoffset * __dbg_scale.y);
			__dbg_tr.set(__dbg_tl.x + (__dbg_inst.sprite_width - 1) * __dbg_scale.x, __dbg_tl.y);
			__dbg_bl.set(__dbg_tl.x, __dbg_tl.y + (__dbg_inst.sprite_height - 1) * __dbg_scale.y);
			__dbg_br.set(__dbg_tr.x, __dbg_bl.y);

			__dbg_angle		= degtorad(-__dbg_inst.image_angle);
			__dbg_cos		= cos(__dbg_angle);
			__dbg_sin		= sin(__dbg_angle);

			__dbg_rot_tl.set(
				__dbg_trans.x + (__dbg_tl.x * __dbg_cos - __dbg_tl.y * __dbg_sin),
				__dbg_trans.y + (__dbg_tl.x * __dbg_sin + __dbg_tl.y * __dbg_cos)
			);

			__dbg_rot_tr.set(
				__dbg_trans.x + (__dbg_tr.x * __dbg_cos - __dbg_tr.y * __dbg_sin),
				__dbg_trans.y + (__dbg_tr.x * __dbg_sin + __dbg_tr.y * __dbg_cos)
			);

			__dbg_rot_bl.set(
				__dbg_trans.x + (__dbg_bl.x * __dbg_cos - __dbg_bl.y * __dbg_sin),
				__dbg_trans.y + (__dbg_bl.x * __dbg_sin + __dbg_bl.y * __dbg_cos)
			);

			__dbg_rot_br.set(
				__dbg_trans.x + (__dbg_br.x * __dbg_cos - __dbg_br.y * __dbg_sin),
				__dbg_trans.y + (__dbg_br.x * __dbg_sin + __dbg_br.y * __dbg_cos)
			);

			draw_primitive_begin(pr_linestrip);
			draw_vertex(__dbg_rot_tl.x, __dbg_rot_tl.y);
			draw_vertex(__dbg_rot_tr.x, __dbg_rot_tr.y);
			draw_vertex(__dbg_rot_br.x, __dbg_rot_br.y);
			draw_vertex(__dbg_rot_bl.x, __dbg_rot_bl.y);
			draw_vertex(__dbg_rot_tl.x, __dbg_rot_tl.y);
			draw_primitive_end();
		}
	}
	draw_set_color(c_white);
}
	
#endregion

/*
	----------------------
		CAMERA CONTROL
	----------------------
*/
#region CAMERA CONTROL

CAM_MIN_X	= 0;
CAM_MIN_Y	= 0;
CAM_MAX_X	= room_width;
CAM_MAX_Y	= room_height;

__current_cam_action	= undefined;
__cam_left				= CAM_LEFT_EDGE;
__cam_top				= CAM_TOP_EDGE;
__cam_width				= CAM_WIDTH;
__cam_height			= CAM_HEIGHT;

__screen_shaking		= false;
/// @func	screen_shake(frames, xinstensity, yintensity, camera_index = 0)
/// @desc	lets rumble! NOTE: Ignored, if already rumbling!
screen_shake = function(frames, xinstensity, yintensity, camera_index = 0) {
	if (__screen_shaking) {
		dlog($"Screen_shake ignored. Already shaking!");
		return undefined;
	}
	__screen_shaking = true;
	var a = new camera_action_data(camera_index, frames, __camera_action_screen_shake);
	a.no_delta		= {dx:0, dy:0}; // delta watcher if cam target moves while we animate
	a.xintensity	= xinstensity;
	a.yintensity	= yintensity
	a.xshake		= 0;
	a.yshake		= 0;
	a.xrumble		= 0;
	a.yrumble		= 0;
	camera_set_view_target(view_camera[camera_index], noone);
	a.__internal_finished_callback = function() {ROOMCONTROLLER.__screen_shaking = false;};
	// Return the action to our caller
	return a; 
}

/// @func	camera_zoom_to(frames, new_width, enqueue_if_running = true, camera_index = 0)
/// @desc	zoom the camera animated by X pixels
camera_zoom_to = function(frames, new_width, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_zoom, enqueue_if_running, true);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative	= false; // not-relative tells the action to use a.new_width for calculation
	a.new_width	= new_width;
	// Return the action to our caller
	return a; 
}

/// @func	camera_zoom_by(frames, width_delta, min_width, max_width, enqueue_if_running = true, camera_index = 0)
/// @desc	zoom the camera animated by X pixels
camera_zoom_by = function(frames, width_delta, min_width, max_width, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_zoom, enqueue_if_running, true);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= true; // relative tells the action to use a.new_width for calculation
	a.min_width		= min_width;
	a.max_width		= max_width;
	a.width_delta	= width_delta;
	// Return the action to our caller
	return a; 
}

/// @func	camera_move_to(frames, target_x, target_y, enqueue_if_running = true, camera_align = cam_align.top_left, camera_index = 0)
/// @desc	move the camera animated to a specified position with an optional alignment.
///			The cam_align enum can be used to specify a different alignment than
///			the default of top_left. For instance, if you specify align.middle_center here,
///			this function works like a kind of "look at that point", as the CENTER of the view
///			will be at target_x, target_y coordinates.
camera_move_to = function(frames, target_x, target_y, enqueue_if_running = true, camera_align = cam_align.top_left, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_move, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= false; // not-relative tells the action to use a.target* for calculation
	a.target_x		= target_x;
	a.target_y		= target_y;
	a.camera_align	= camera_align;
	// Return the action to our caller
	return a; 
}

/// @func	camera_move_by(frames, distance_x, distance_y, enqueue_if_running = true, camera_index = 0)
/// @desc	move the camera animated by a specified distance
camera_move_by = function(frames, distance_x, distance_y, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_move, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= true; // relative tells the action to use a.distance* for calculation
	a.distance_x	= distance_x;
	a.distance_y	= distance_y;
	// Return the action to our caller
	return a; 
}

/// @func	camera_look_at(frames, target_x, target_y, enqueue_if_running = true, camera_index = 0)
/// @desc	move the camera animated so that target_x and target_y are in the center of the screen when finished.
camera_look_at = function(frames, target_x, target_y, enqueue_if_running = true, camera_index = 0) {
	return camera_move_to(frames, target_x, target_y, enqueue_if_running, cam_align.middle_center, camera_index);
}

/// @func	camera_bump_x(frames, distance_x, enqueue_if_running = true, camera_index = 0)
/// @desc	A bump animation horizontal
camera_bump_x = function(frames, distance_x, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_bump, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= true; // relative tells the action to use a.distance* for calculation
	a.distance_x	= -distance_x;
	a.distance_y	= 0;
	a.set_anim_curve(acBounce);
	// Return the action to our caller
	return a;
}

/// @func	camera_bump_y(frames, distance_x, enqueue_if_running = true, camera_index = 0)
/// @desc	A bump animation vertical
camera_bump_y = function(frames, distance_y, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_bump, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= true; // relative tells the action to use a.distance* for calculation
	a.distance_x	= 0;
	a.distance_y	= -distance_y;
	a.set_anim_curve(acBounce);
	// Return the action to our caller
	return a;
}

#endregion

/*
	----------------------
	  TRANSITION CONTROL
	----------------------
*/
#region TRANSITION CONTROL
#macro ACTIVE_TRANSITION			global.__active_transition
#macro TRANSITION_RUNNING			global.__transition_running

#macro __TRANSIT_ROOM_CHAIN			global.__transit_room_chain
#macro __ACTIVE_TRANSITION_STEP		global.__active_transition_step

if (!variable_global_exists("__active_transition"))		 ACTIVE_TRANSITION		  = undefined;
if (!variable_global_exists("__transition_running"))	 TRANSITION_RUNNING		  = false;
if (!variable_global_exists("__transit_room_chain"))	 __TRANSIT_ROOM_CHAIN	  = [];
if (!variable_global_exists("__active_transition_step")) __ACTIVE_TRANSITION_STEP = -1; 
// __ACTIVE_TRANSITION_STEP 0 = out, 1 = in and -1 means inactive

enter_transition		= ACTIVE_TRANSITION;
__is_transit_back		= false;
__escape_was_pressed	= false;

if (record_in_transit_chain && array_last(__TRANSIT_ROOM_CHAIN) != room) {
	array_push(__TRANSIT_ROOM_CHAIN, room);
	vlog($"{ROOM_NAME} recorded in transit chain, length is now {array_length(__TRANSIT_ROOM_CHAIN)}");
}

/// @func	transit(_transition, skip_if_another_running = false)
/// @desc	Perform an animated transition to another room
///			See RoomTransitions script for more info
transit = function(_transition, skip_if_another_running = false) {
	if (skip_if_another_running && TRANSITION_RUNNING) {
		wlog($"** WARNING ** Transition ignored, another one is running");
		return;
	}
	
	ilog($"Starting transit to '{room_get_name(_transition.target_room)}'");
	
	ACTIVE_TRANSITION		 = _transition;
	__ACTIVE_TRANSITION_STEP = 0;
	TRANSITION_RUNNING = true;
}

/// @func	transit_back()
/// @desc	Transit back one room in the transit chain.
///			If the chain is empty, game might exit.
///			In either way, "onLeaveRoom" is invoked with a 
///			transition_data struct.
transit_back = function() {
	__is_transit_back = true;
	var leave_struct = {
		escape_pressed: __escape_was_pressed,
		target_room: undefined, 
		transition: undefined, 
		cancel: false
	};
	__escape_was_pressed = false; // reset this in case of a cancel
	
	if (record_in_transit_chain && array_last(__TRANSIT_ROOM_CHAIN) == room)
		array_pop(__TRANSIT_ROOM_CHAIN); // This is our room, ignore it
	
	if (array_length(__TRANSIT_ROOM_CHAIN) > 0) {
		var target = array_pop(__TRANSIT_ROOM_CHAIN); // Go to this one
		leave_struct.target_room = target;
		vlog($"Transit back from {ROOM_NAME} targets {room_get_name(target)}");
		onTransitBack(leave_struct);
		if (!leave_struct.cancel) {
			vlog($"Transit back to targets {room_get_name(target)} starting");
			if (leave_struct.transition != undefined) {
				// in case the user redirected, update the target room
				leave_struct.transition.target_room = leave_struct.target_room;
				transit(leave_struct.transition);
			} else 
				room_goto(leave_struct.target_room);
		} else {
			vlog($"Transit back to {room_get_name(target)} aborted, staying in this room");
			// re-push the chain
			array_push(__TRANSIT_ROOM_CHAIN, target);
			array_push(__TRANSIT_ROOM_CHAIN, room);
		}
	} else {
		vlog($"Transit back from {ROOM_NAME} is end of chain, preparing game exit");
		leave_struct.target_room = undefined;
		onTransitBack(leave_struct);
		if (!leave_struct.cancel)
			EXIT_GAME;
	}
}

/// @func	onTransitFinished()
/// @desc	Invoked when a transition to this room is finished.
///			Override (redefine) to execute code when a room is no longer animating
///			NOTE: If this room has been entered through the savegame system
///			and a transition was specified to enter the room when loading,
///			this _data member has been enriched by a "was_loading = true"
///			member. With this, you can always distinguish between a "normal"
///			enter of the room or an enter caused by game load.
onTransitFinished = function(_data) {
}

/// @func	onTransitBack(_transition_data)
/// @desc	Invoked, when the "transit_back" method is called
onTransitBack = function(_transition_data) {
	// Example reaction:
	// If you want to stay in this room
	// _transition_data.cancel = true;
	// ...or supply a transition to the target room
	// _transition_data.transition = new FadeTransition(_transition_data.target_room, 20, 20);
	// ...or do nothing of the above to have a simple room_goto fired to the target room
}

#endregion

/*
	----------------------
	 VIRTUAL ROOM CONTROL
	----------------------
*/
#region VIRTUAL ROOM CONTROL
__virtual_rooms = {};

/// @func	virtual_room_exists(_name)
/// @desc	Checks if a virtual room with the given name exists.
virtual_room_exists = function(_name) {
	return virtual_room_get(_name) != undefined;
}

/// @func	virtual_room_get(_name)
/// @desc	Returns a virtual room with the given name.
///			(You may want to modify your virtual room at runtime.)
virtual_room_get = function(_name) {
	return __virtual_rooms[$ _name];
}

/// @func	virtual_room_is_active(_name)
/// @desc	Checks if a virtual room is currently active.
virtual_room_is_active = function(_name) {
	return VIRTUAL_ROOM != undefined && VIRTUAL_ROOM.name == _name;
}

/// @func	virtual_room_create(_name, _x, _y, _width, _height, _activate = false)
/// @desc	Creates and returns the new virtual room.
virtual_room_create = function(_name, _x, _y, _width, _height, _activate = false) {
	__virtual_rooms[$ _name] ??= new VirtualRoom(_name);
	return virtual_room_update(_name, _x, _y, _width, _height, _activate);
}


/// @func	virtual_room_update(_name, _x, _y, _width, _height, _activate = false)
/// @desc	Updates an existing virtual room.
virtual_room_update = function(_name, _x, _y, _width, _height, _activate = false) {
	if (!virtual_room_exists(_name)) {
		wlog($"** WARNING ** Virtual Room with the name '{_name}' does not exist!");
		return undefined;
	}
	
	var virtual_room = virtual_room_get(_name);
	
	virtual_room.left	= _x;
	virtual_room.top	= _y;
	virtual_room.width	= _width;
	virtual_room.height	= _height;
	
	if (_activate)
		virtual_room_activate(_name);
	else if (virtual_room_is_active(_name))
		__virtual_room_update_camera();
	
	return virtual_room;
}

/// @func	virtual_room_delete(_name)
/// @desc	Delets the given room if it is not currently active.
virtual_room_delete = function(_name) {
	if (!virtual_room_exists(_name)) {
		wlog($"** WARNING ** Virtual Room with the name '{_name}' is currently selected! You have to deselect it first in order to delete it.");
		return false;
	}
	
	struct_remove(__virtual_rooms, _name);
	return true;
}

/// @func	virtual_room_activate(_name)
/// @desc	Sets the camera min/max coordinates according to the given virtual room.
///			(The given virtual room is now active.)
virtual_room_activate = function(_name) {
	if (!virtual_room_exists(_name)) {
		wlog($"** WARNING ** Virtual Room with the name '{_name}' does not exist!");
		return false;
	}
	
	VIRTUAL_ROOM = virtual_room_get(_name);
	__virtual_room_update_camera();
	
	return true;
}

/// @func	virtual_room_deactivate()
/// @desc	Sets the camera min/max coordinates according to the physical room.
///			(No virtual room is now active.)
virtual_room_deactivate = function() {
	VIRTUAL_ROOM	= undefined;
	CAM_MIN_X		= 0;
	CAM_MIN_Y		= 0;
	CAM_MAX_X		= room_width;
	CAM_MAX_Y		= room_height;
}

__virtual_room_update_camera = function() {
	CAM_MIN_X = VIRTUAL_ROOM_LEFT_EDGE;
	CAM_MIN_Y = VIRTUAL_ROOM_TOP_EDGE;
	CAM_MAX_X = VIRTUAL_ROOM_RIGHT_EDGE;
	CAM_MAX_Y = VIRTUAL_ROOM_BOTTOM_EDGE;
}

#endregion