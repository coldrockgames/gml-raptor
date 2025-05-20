/// @desc clear anim & state pools

pool_clear_all();
animation_clear_pool();
statemachine_clear_pool();
hide_popup();
collider_cleanup();

// if we are the last room in the chain
// then remove this room from the chain
if (__is_transit_back && array_last(__TRANSIT_ROOM_CHAIN) == room) {
	array_pop(__TRANSIT_ROOM_CHAIN);
	vlog($"{room_get_name(room)} removed from transit chain, length is now {array_length(__TRANSIT_ROOM_CHAIN)}");
}
