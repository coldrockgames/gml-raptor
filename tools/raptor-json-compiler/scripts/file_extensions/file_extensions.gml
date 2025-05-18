/*
    Definition of file extensions used by raptor
*/

#macro __RUNTIME_FILE_EXTENSIONS			{	\
	data_file:		".json",					\
	scriptor_file:	".scriptor",				\
	particle_file:	".particle",				\
}

#macro release:__RUNTIME_FILE_EXTENSIONS	{	\
	data_file:		".jx",						\
	scriptor_file:	".scx",						\
	particle_file:	".ptx",						\
}

#macro FILE_EXTENSIONS						global.__file_extensions
FILE_EXTENSIONS = __RUNTIME_FILE_EXTENSIONS;

#macro DATA_FILE_EXTENSION					FILE_EXTENSIONS.data_file
#macro SCRIPTOR_FILE_EXTENSION				FILE_EXTENSIONS.scriptor_file
#macro PARTICLE_FILE_EXTENSION				FILE_EXTENSIONS.particle_file

