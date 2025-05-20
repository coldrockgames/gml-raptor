/*
    Versioned Struct Base Class
	
	ALL data files (profiles, settings, achievements, save games)
	MUST derive from this class to handle game updates and new versions to upgrade.
	
	When loaded, a compare is done between the "file_version" and the SAVE_GAME_VERSION.
	If the SAVE_GAME_VERSION is higher, the upgrade script will be called, if it exists.

	Make sure, you read the documentation at
	https://github.com/Grisgram/gml-raptor/wiki/Savegame-Versioning
*/

ENSURE_SAVEGAME;
ENSURE_LOGGER;

function VersionedDataStruct() constructor {
	construct(VersionedDataStruct);

	/// @func	on_game_loaded()
	/// @desc	This callback gets invoked, when a VersionedDataStruct
	///			has been loaded from a savegame (after all version upgrades)
	on_game_loaded = function() {}

	/// @func	get_names()
	/// @desc	Returns struct_get_names but cleaned from all
	///			raptor-internal members for construction, so
	///			the return value looks like a real "struct_get_names"
	static get_names = function() {
		var rv = struct_get_names(self);
		var i = 0;
		while (i < array_length(rv)) {
			if (is_any_of(rv[@i], __CONSTRUCTOR_NAME, __PARENT_CONSTRUCTOR_NAME, "on_game_loaded"))
				array_delete(rv, i, 1);
			else 
				i++;
		}
		return rv;
	}
	
	// only add the receiver if we get loaded from a savegame currently
	if (SAVEGAME_LOAD_IN_PROGRESS) {
		BROADCASTER.add_receiver(self, $"vds_{SUID}game_load_{address_of(self)}", __RAPTOR_BROADCAST_SAVEGAME_VERSION_CHECK, 
			function(bc) {
				var file_version = bc.data.file_version;
				if (SAVEGAME_FILE_VERSION > file_version) {
					for (var i = file_version + 1; i <= SAVEGAME_FILE_VERSION; i++) {
						var method_name = sprintf(SAVEGAME_UPGRADE_METHOD_PATTERN, i);
						if (vsget(self, method_name) != undefined) {
							ilog($"Upgrading struct {name_of(self)} to version {i}");
							invoke_if_exists(self, method_name);
						}
					}
				}
				return true; // remove the receiver, game load only happens once per instance lifetime
			}
		);
		BROADCASTER.add_receiver(self, $"vds_{SUID}game_load_finished_{address_of(self)}", 
			RAPTOR_SAVEGAME_ACTIVITY_BROADCAST_FILTER,
			function(bc) {
				switch(bc.title) {
					case __RAPTOR_BROADCAST_DATA_GAME_LOADED:
					case __RAPTOR_BROADCAST_GAME_LOADED:
						on_game_loaded();
						BROADCASTER.remove_owner(self);
						return true;
				}
			}
		);
	}	
}