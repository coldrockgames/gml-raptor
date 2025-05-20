/*
    Configure the raptor logger in this file
*/

// The number of log lines to keep in the internal RingBuffer in case of a crash
// When using the Game_Exception_Handler, the buffered lines will be written to a crash log file
// and can be retrieved with the next start of the game
#macro LOG_BUFFER_SIZE					200

// Choose, which line formatter to use when writing a log
// Available are:
// - RaptorSimpleFormatter: Just prints the log level and the message 1:1 without additional information
// - RaptorFrameFormatter:  Precedes each log line with the current game frame number. Very useful for exact timing.
//                          With this formatter you can see the exact frame, when a line was written. This is the default.
// - RaptorTimeFormatter:   Instead of the game frame, this formatter precedes each line with the current_time, which is a
//							milliseconds value since the game was started. This is less exact than the RaptorFrameFormatter.
#macro LOG_FORMATTER					RaptorFrameFormatter

// The log level decides, which log lines will be printed to the log.
// A line must AT LEAST have the level specified here to be printed.
//
// The levels are: 0-Verbose, 1-Debug, 2-Info, 3-Warning, 4-Error, 5-Fatal
//
// !PLEASE NOTE! In the RingBuffer, ALL lines (excpect verbose) are stored in case of a crash and written 
// (encrypted with your FILE_CRYPT_KEY) to disk. If you report that crash log to your server, you have the FULL INFORMATION available!
// It's just the live log, you are filtering here (as an example, in a browser game, you only write Waring++ to the log
// if the user is live-watching the console)
//
// A note on verbose logging (level 0): This logs every single mouse_enter/leave event, each tooltip shown, everything!
// Turn it on in debug if you hunt a bug, but it's too much information for normal development
#macro LOG_LEVEL			LOG_LEVEL_1_DEBUG
#macro beta:LOG_LEVEL		LOG_LEVEL_2_INFO
#macro release:LOG_LEVEL	LOG_LEVEL_3_WARNING

// Raptor module logs
// In addition to the LOG_LEVEL, you can turn off some modules entirely from logging anything.
// Some of them log lots of lines in verbose and debug mode and need to be turned on only if you hunt a bug
// that _might_ be located in one of raptor's modules
#macro DEBUG_LOG_BROADCASTS				false
#macro DEBUG_LOG_OBJECT_POOLS			false
#macro DEBUG_LOG_LIST_POOLS				false
#macro DEBUG_LOG_STATEMACHINE			false
#macro DEBUG_LOG_RACE					false
#macro DEBUG_LOG_PARTICLES				false
#macro DEBUG_LOG_BINDINGS				false

// To avoid, that you "forget" to turn a module off, by default there's a set of these macros, where every log
// is disabled for release mode
#macro release:DEBUG_LOG_BROADCASTS		false
#macro release:DEBUG_LOG_OBJECT_POOLS	false
#macro release:DEBUG_LOG_LIST_POOLS		false
#macro release:DEBUG_LOG_STATEMACHINE	false
#macro release:DEBUG_LOG_RACE			false
#macro release:DEBUG_LOG_PARTICLES		false
#macro release:DEBUG_LOG_BINDINGS		false
