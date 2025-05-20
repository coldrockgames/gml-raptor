/*
    A simple logging subsystem with a RingBuffer and formatted log-output.
*/

#macro RAPTOR_LOGGER	global.__raptor_logger
#macro ENSURE_LOGGER	if (!variable_global_exists("__raptor_logger"))	global.__raptor_logger = new RaptorLogger();
ENSURE_LOGGER;

#macro __LOG_GAME_INIT_START	$"[--- RAPTOR INIT STARTING ---]"
#macro __LOG_GAME_INIT_FINISH	$"[--- RAPTOR INIT FINISHED ---]"

#macro vlog					RAPTOR_LOGGER.log_verbose
#macro dlog					RAPTOR_LOGGER.log_debug
#macro ilog					RAPTOR_LOGGER.log_info
#macro wlog					RAPTOR_LOGGER.log_warning
#macro elog					RAPTOR_LOGGER.log_error
#macro flog					RAPTOR_LOGGER.log_fatal
#macro mlog					RAPTOR_LOGGER.log_master

#macro LOG_LEVEL_0_VERBOSE	0
#macro LOG_LEVEL_1_DEBUG	1
#macro LOG_LEVEL_2_INFO		2
#macro LOG_LEVEL_3_WARNING	3
#macro LOG_LEVEL_4_ERROR	4
#macro LOG_LEVEL_5_FATAL	5

function RaptorLogger() constructor {

	__formatter = new RaptorSimpleFormatter();

	static set_formatter = function(_formatter) {
		__formatter = _formatter;
	}
	
	static get_log_buffer = function(_as_single_string = true) {
		var buf = __formatter.get_buffer_snapshot();
		if (_as_single_string) {
			return array_reduce(buf, function(current, next) {
				return string_concat(current, next, "\n");
			}, "");
		} else
			return buf;
	}
	
	/// @func set_log_level(_new_level)
	static set_log_level = function(_new_level) {
		__formatter.change_log_level(_new_level);
	}
	
	static log_verbose = function(_message) {
		__formatter.write_log(0, _message);
	}
	
	static log_debug = function(_message) {
		__formatter.write_log(1, _message);
	}

	static log_info = function(_message) {
		__formatter.write_log(2, _message);
	}
	
	static log_warning = function(_message) {
		__formatter.write_log(3, _message);
	}
	
	static log_error = function(_message) {
		__formatter.write_log(4, _message);
	}
	
	static log_fatal = function(_message) {
		__formatter.write_log(5, _message);
	}
	
	// the master log function is kind of a special way to print out a line *always*
	// no matter, what log level is set. Could be done with fatal also, but it is used
	// to print the game version to the log, which shall not be marked as fatal error.
	static log_master = function(_message) {
		__formatter.write_log(6, _message);
		if (_message == __LOG_GAME_INIT_FINISH)
			__formatter.activate_live_buffer();
	}

}