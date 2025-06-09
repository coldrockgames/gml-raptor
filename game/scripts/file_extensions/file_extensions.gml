/*
    Definition of file extensions used by raptor
*/

#macro __RUNTIME_FILE_EXTENSIONS			{	\
	data_file:		".json",					\
	particle_file:	".particle",				\
}

#macro FILE_EXTENSIONS						global.__file_extensions
FILE_EXTENSIONS = __RUNTIME_FILE_EXTENSIONS;

#macro DATA_FILE_EXTENSION					FILE_EXTENSIONS.data_file
#macro PARTICLE_FILE_EXTENSION				FILE_EXTENSIONS.particle_file
