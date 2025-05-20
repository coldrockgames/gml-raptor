/// @desc set up drawer
event_inherited();
gui_mouse		= new GuiMouseTranslator();
mouse_is_over	= false;

#region DRAW functionality
__backupx = 0;
__backupy = 0;

__draw_self = function() {
	gml_pragma("forceinline");
	draw_self();
}

__draw_self_at = function(_x, _y) {
	__backupx = x;
	__backupy = y;
	x = _x;
	y = _y;
	__draw_self();
	x = __backupx;
	y = __backupy;
}

__draw = function() {
	if (is_enabled && (outline_always || 
			(outline_on_mouse_over && mouse_is_over && 
			(!protect_ui_events || is_topmost(CTL_MOUSE_X, CTL_MOUSE_Y)))
		))
		outliner.draw_sprite_outline();
	else
		__draw_self();
}

outliner		= new OutlineDrawer(0, self, __draw_self_at, use_bbox_of_sprite);
#endregion