/// @desc Store mouse/window coordinates

/*
	BEGIN STEP: Calculate new positions of mouse and window and all
*/

// ---------- MOUSE ----------
GUI_MOUSE_X_PREVIOUS = GUI_MOUSE_X;
GUI_MOUSE_Y_PREVIOUS = GUI_MOUSE_Y;
GUI_MOUSE_X			 = device_mouse_x_to_gui(0) / UI_SCALE;
GUI_MOUSE_Y			 = device_mouse_y_to_gui(0) / UI_SCALE;
GUI_MOUSE_DELTA_X	 = GUI_MOUSE_X - GUI_MOUSE_X_PREVIOUS;
GUI_MOUSE_DELTA_Y	 = GUI_MOUSE_Y - GUI_MOUSE_Y_PREVIOUS;
GUI_MOUSE_HAS_MOVED  = GUI_MOUSE_DELTA_X != 0 || GUI_MOUSE_DELTA_Y != 0;

MOUSE_DELTA_X	 = MOUSE_X - MOUSE_X_PREVIOUS;
MOUSE_DELTA_Y	 = MOUSE_Y - MOUSE_Y_PREVIOUS;
MOUSE_HAS_MOVED  = MOUSE_DELTA_X != 0 || MOUSE_DELTA_Y != 0;
MOUSE_X_PREVIOUS = MOUSE_X;
MOUSE_Y_PREVIOUS = MOUSE_Y;

// ---------- WINDOW ----------
if (WATCH_FOR_WINDOW_SIZE_CHANGE) {
	if (GAME_FRAME % 6 == 0) {
		WINDOW_SIZE_X_PREVIOUS = WINDOW_SIZE_X;
		WINDOW_SIZE_Y_PREVIOUS = WINDOW_SIZE_Y;
		WINDOW_SIZE_X = window_get_width();
		WINDOW_SIZE_Y = window_get_height();

		WINDOW_SIZE_DELTA_X = WINDOW_SIZE_X - WINDOW_SIZE_X_PREVIOUS;
		WINDOW_SIZE_DELTA_Y = WINDOW_SIZE_Y - WINDOW_SIZE_Y_PREVIOUS;

		// true for 1 frame only - catch the broadcast or check every step
		WINDOW_SIZE_HAS_CHANGED = WINDOW_SIZE_DELTA_X != 0 || WINDOW_SIZE_DELTA_Y != 0;
		if (WINDOW_SIZE_HAS_CHANGED) SEND_WINDOW_BROADCAST;
	} else
		WINDOW_SIZE_HAS_CHANGED = false;
}

// Camera update
__cam_left			= CAM_LEFT_EDGE;
__cam_top			= CAM_TOP_EDGE;
__cam_width			= CAM_WIDTH;
__cam_height		= CAM_HEIGHT;

CAM_HAS_MOVED		= (CAM_X_PREVIOUS != __cam_left || CAM_Y_PREVIOUS != __cam_top);
CAM_HAS_SIZED		= (CAM_WIDTH_PREVIOUS != __cam_width || CAM_HEIGHT_PREVIOUS != __cam_height);
CAM_HAS_CHANGED		= (CAM_HAS_MOVED || CAM_HAS_SIZED);

CAM_X_PREVIOUS		= __cam_left;
CAM_Y_PREVIOUS		= __cam_top;
CAM_WIDTH_PREVIOUS	= __cam_width;
CAM_HEIGHT_PREVIOUS	= __cam_height;

DELTA_TIME_SECS_REAL	= delta_time / 1000000;
DELTA_TIME_SECS			= DELTA_TIME_SECS_REAL * GAME_SPEED;
