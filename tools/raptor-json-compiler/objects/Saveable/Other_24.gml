/// @desc onGameSaving
/*
	Invoked before the data variable is written to the file.
	Use this event to store/map any data for the save file, like mapping instances to their id's only
*/
event_inherited();
__RAPTORDATA.is_enabled = is_enabled;
__RAPTORDATA.tooltip_text = tooltip_text;
__RAPTORDATA.auto_show_tooltip = auto_show_tooltip;
__RAPTORDATA.tooltip_object = is_null(tooltip_object) ? undefined : object_get_name(tooltip_object);

if (struct_exists(self, __POOL_SOURCE_NAME))	__RAPTORDATA[$ __POOL_SOURCE_NAME]	= self[$ __POOL_SOURCE_NAME];
if (struct_exists(self, __INTERFACES_NAME ))	__RAPTORDATA[$ __INTERFACES_NAME]	= self[$ __INTERFACES_NAME];
