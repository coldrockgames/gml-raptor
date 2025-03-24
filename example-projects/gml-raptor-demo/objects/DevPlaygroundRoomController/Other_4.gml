/// @description 
event_inherited();

SPN.set_content_object(MultiPanel);

create_virtual_room(0, 0, ROOM_WIDTH + 100, ROOM_HEIGHT + 100, "test_vroom");

set_camera_to_virtual_room("test_vroom");
