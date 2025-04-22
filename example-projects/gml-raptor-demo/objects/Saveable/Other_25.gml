/// @desc onGameLoaded
/*
	The data variable has already been published with the loaded data.
	Use this event to restore all needed values from data (like instances).
*/
event_inherited();
is_enabled			= __RAPTORDATA.is_enabled;
tooltip_text		= __RAPTORDATA.tooltip_text;
auto_show_tooltip	= __RAPTORDATA.auto_show_tooltip;
tooltip_object		= is_null(__RAPTORDATA.tooltip_object) ? undefined : asset_get_index(__RAPTORDATA.tooltip_object);

if (struct_exists(__RAPTORDATA, __POOL_SOURCE_NAME))	self[$ __POOL_SOURCE_NAME]	= __RAPTORDATA[$ __POOL_SOURCE_NAME];
if (struct_exists(__RAPTORDATA, __INTERFACES_NAME ))	self[$ __INTERFACES_NAME]	= __RAPTORDATA[$ __INTERFACES_NAME];
