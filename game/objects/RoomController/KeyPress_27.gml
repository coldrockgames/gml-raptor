/// @description leave room?
event_inherited();

if (GUI_POPUP_VISIBLE || !escape_leaves_room) exit;

// are we the last room in the chain?
if (!record_in_transit_chain || array_last(__TRANSIT_ROOM_CHAIN) == room) {
	__escape_was_pressed = true;
	transit_back();
}
