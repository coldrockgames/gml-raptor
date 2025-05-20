/// @description invoke callback
event_inherited();

TRY
	__invoke_async_file_callback(
		ds_map_find_value(async_load, "id"),
	    ds_map_find_value(async_load, "status")
	);
CATCH ENDTRY
