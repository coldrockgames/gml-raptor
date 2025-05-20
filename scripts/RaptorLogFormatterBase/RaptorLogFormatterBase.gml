/*
    base class to format a log line
*/

function RaptorLogFormatterBase() constructor {

	__log_levels	= ["V", "D", "I", "W", "E", "F", "!"];
	__init_buffer	= new RingBuffer(LOG_BUFFER_SIZE, "");
	__buffer		= new RingBuffer(LOG_BUFFER_SIZE, "");
	__logline		= "";
	
	__log_level		= LOG_LEVEL;
	
	__active_buffer	= __init_buffer;
	
	// this function needs to be implemented by each formatter
	format_event = function(_level, _message) {}

	static write_log = function(_level, _message) {
		if (_level > 0 || __log_level == 0) {
			__logline = format_event(__log_levels[@_level], _message);
			__active_buffer.add(__logline);
			if (_level >= __log_level) show_debug_message(__logline);
		}
	}

	// change the loglevel at runtime
	static change_log_level = function(_new_level) {
		__log_level = _new_level;
	}

	static get_buffer_snapshot = function() {
		return array_concat(__init_buffer.snapshot(), __buffer.snapshot());
	}

	static activate_live_buffer = function() {
		dlog($"Logger live buffer activated");
		__active_buffer = __buffer;
	}

}