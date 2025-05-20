/// @desc event
event_inherited();

partsys_index			= __RAPTORDATA.partsys_index		;
follow_instance			= __RAPTORDATA.follow_instance		;
follow_offset			= __RAPTORDATA.follow_offset		;
scale_with_instance		= __RAPTORDATA.scale_with_instance	;
emitter_name			= __RAPTORDATA.emitter_name			;
stream_with_clone		= __RAPTORDATA.stream_with_clone	;
stream_on_create		= __RAPTORDATA.stream_on_create		;
stream_start_delay		= __RAPTORDATA.stream_start_delay	;
stream_particle_name	= __RAPTORDATA.stream_particle_name	;
stream_particle_count	= __RAPTORDATA.stream_particle_count;
burst_particle_name		= __RAPTORDATA.burst_particle_name	;
burst_particle_count	= __RAPTORDATA.burst_particle_count	;

// reassign the private member
__my_emitter			= emitter_name;
