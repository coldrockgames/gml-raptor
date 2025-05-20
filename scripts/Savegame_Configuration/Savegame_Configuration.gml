/*
    Configure the savegame system with the parameters below.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// The folder in the user profile/game_name folder, where savegames shall be placed.
// DO NOT DELETE THE MACRO! If you want no subfolder, set it to "" (an empty string) instead.
#macro SAVEGAME_FOLDER					"saves/"

// The current version of the savegame files.
// If a loaded file has a lower version than this, the upgrade methods will be called on
// each object, one versions at a time
#macro SAVEGAME_FILE_VERSION			1

// Every Saveable object can offer method(s) to be performed, when a lower version of a savegame
// is loaded to convert to the new current format.
// If an object does not offer such a method, it's fine, then it is silently ignored.
// Upgrade always happens incremental:
// Imagine, you load a savegame version 1 and the current version is 4, then savegame will invoke
// savegame_upgrade_v2, savegame_upgrade_v3, savegame_upgrade_v4 in order, so you always need only
// to code the "delta to the previous version" in your method and supply defaults/new data there.
// NOTE: The upgrade methods are called on the newly created object, just BEFORE onGameLoading,
// UserEvent15 and onGameLoaded are invoked.
// Make sure to place these methods in the CREATE event of your object, so the method is known
// when the object is created!
#macro SAVEGAME_UPGRADE_METHOD_PATTERN	"savegame_upgrade_v{0}"