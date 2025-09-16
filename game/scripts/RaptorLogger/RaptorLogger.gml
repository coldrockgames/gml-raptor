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
	construct(RaptorLogger);
	
	__formatter = new RaptorSimpleFormatter();

	/// @func	game_starting()
	/// @desc	Invoked by GameStarter when a game starts
	static game_starting = function() {
		for (var i = 0, len = array_length(RaptorLogger.appenders.instances); i < len; i++) {
			var a = RaptorLogger.appenders.instances[@i];
			a.game_starting();
		}
	}

	/// @func	shutdown() 
	/// @desc	Shutdown the logging system
	static shutdown = function() {
		for (var i = 0, len = array_length(RaptorLogger.appenders.instances); i < len; i++) 
			RaptorLogger.appenders.instances[@i].shutdown();
	}
	
	/// @func	set_formatter(_formatter)
	static set_formatter = function(_formatter) {
		__formatter = _formatter;
	}

	#region appender logic
	static appenders = {
		appender_count: 1,
		instances: [ new RaptorConsoleAppender() ]
	};

	/// @func	add_appender(_appender)
	static add_appender = function(_appender) {
		var type_known = false;
		for (var i = 0, len = array_length(RaptorLogger.appenders.instances); i < len; i++) {
			type_known |= (name_of(_appender, false) == name_of(RaptorLogger.appenders.instances[@i], false));
		}
		if (type_known) {
			wlog($"** WARNING ** {MY_CLASS_NAME} ignored attempt to add multiple '{name_of(_appender, false)}' appenders");
			return;
		}
		

		array_push(RaptorLogger.appenders.instances, _appender);
		RaptorLogger.appenders.appender_count = array_length(RaptorLogger.appenders.instances);
		dlog($"{MY_CLASS_NAME} added '{name_of(_appender, false)}' appender");
	}

	/// @func	remove_appender(_type)
	/// @desc	Remove the appender of the specified type.
	///			NOTE: supply the TYPENAME here (like UdpAppender),
	///			NOT as string, and NOT as instance (like new UdpAppender())
	///			Correct: RAPTOR_LOGGER.remove_appender(UdpAppender)
	///			Wrong:   RAPTOR_LOGGER.remove_appender("UdpAppender")
	///			Wrong:   RAPTOR_LOGGER.remove_appender(new UdpAppender())
	static remove_appender = function(_type) {
		if (RaptorLogger.appenders.appender_count > 1) {
			for (var i = 0, len = array_length(RaptorLogger.appenders.instances); i < len; i++) {
				var a = RaptorLogger.appenders.instances[@i];
				if (is_child_class_of(a, _type)) {
					if (!is_child_class_of(a, RaptorConsoleAppender)) {
						a.shutdown();
						array_delete(RaptorLogger.appenders.instances, i, 1);
						RaptorLogger.appenders.appender_count = array_length(RaptorLogger.appenders.instances);
						dlog($"{MY_CLASS_NAME} removed log appender '{name_of(a, false)}'");
					} else
						wlog($"** WARNING ** {MY_CLASS_NAME} ignored attempt to remove 'RaptorConsoleAppender' as this is a permanent appender");
					return;
				}
			}
			wlog($"** WARNING ** {MY_CLASS_NAME} could not remove '{name_of(a, false)}' as it does not exist");
		} else
			wlog($"** WARNING ** {MY_CLASS_NAME} ignored the attempt to remove the last log appender");
	}

	#endregion

	/// @func	get_log_buffer(_as_single_string = true) 
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
		dlog($"{MY_CLASS_NAME} changing log level from {__formatter.__log_level} to {_new_level}");
		__formatter.change_log_level(_new_level);
	}

	/// @func	get_log_level() 
	static get_log_level = function() {
		return __formatter.__log_level;
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