/*
	Configure the (Ra)ndom (C)ontent (E)ngine with the parameters below.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// A sub folder in your working_directory (included files)
// where all race table *.json files are stored.
// Set it to "" if you store your race files in included 
// files root.
#macro	RACE_ROOT_FOLDER			"race/"

// By default, race will just forward the race data struct to any dropped item.
// Sometimes you might want to modify some attributes at runtime, and in this case
// you would modify ALL instances of those items, because the data struct exists only
// once in the race table.
// if you need to actively work with modified attributes, set this to true, to receive
// a deep copy of the race struct on each dropped instance.
// this flag is false by default for performance and memory usage optimization.
#macro RACE_LOOT_DATA_DEEP_COPY		false

// By default, each file loaded through Race will be put into a local cache, so 
// additional loads of the file cause no physical drive access.
// However, in some very big games with maybe hundreds of loot files, this might 
// become a memory issue and you might want to turn global caching off in this case
// and implement your own pre-load strategy.
#macro RACE_CACHE_FILE_DEFAULT		true
