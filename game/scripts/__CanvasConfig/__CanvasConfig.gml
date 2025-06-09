/*
	Whether newly created Canvas instances should automatically write to cache upon calling .Finish()
*/
#macro __CANVAS_AUTO_WRITE_TO_CACHE true

/*
	The mode of operation for how Canvas surface depth is determined upon creation
	0: Depends on what surface_get_depth_disable() returns at the time
	1: Forces surface depth disable to be false
	2: Forces surface depth disable to be true
*/
#macro __CANVAS_SURFACE_DEPTH_MODE 0

/* 
	Whether to enable the garbage collector or not.
*/

#macro __CANVAS_ENABLE_GARBAGE_COLLECTOR true