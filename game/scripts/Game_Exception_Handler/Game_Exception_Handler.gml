/*
    If you have set USE_CRASHDUMP_HANDLER in your Game_Configuration file to true,
	this function will be called when you encounter an unhandled exception in your game.
	Instead of the default error window from yoyo, the crash will be written to the filename
	set in the CRASH_DUMP_FILENAME constant.
	
	By default, raptor has USE_CRASHDUMP_HANDLER set to false for the default-Configuration, but for all
	other configurations (BETA, RELEASE) this is true by default.
	
	If file encryption is active, the dump will be encrypted.
	You don't want to make your crash dumps publicly visible. Those files are normally used to be
	transferred to your server at next startup, where you can decrypt them before sending.
*/

#macro USE_CRASHDUMP_HANDLER			false
#macro beta:USE_CRASHDUMP_HANDLER		!IS_CONSOLE
#macro release:USE_CRASHDUMP_HANDLER	!IS_CONSOLE
#macro CRASH_DUMP_FILENAME				$"{GAME_FILE_PREFIX}_crashdump.bin"

function Game_Exception_Handler(_unhandled) {
	try {
		var error = string_concat(
			RAPTOR_LOGGER.get_log_buffer(), 
			"\n[--- CRASH POINT ---]\n",
			string(_unhandled)
		);
		// We already left the game loop here, async file access no longer possible
		// This function never gets called on consoles, so all is good
		file_write_text_file(CRASH_DUMP_FILENAME, error, FILE_CRYPT_KEY);
		flog($"Crash dump written to disk!");
	} catch (_ignored) { 
		flog($"Crash dump could not be written to disk!");
	}
}
