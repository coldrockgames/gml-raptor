/*
    Short utility class to measure time.
	
	Starts automatically when constructed, but offers a .restart() method to reset
	Use the .millis() or .micros() methods to get the elapsed time since start.
	If you want to immediately also write the time to the log on debug level (dlog),
	use .log_millis() or .log_micros() respectively. Those also return the time, they
	just create the log in addition for you.
	(The "name" you set in the constructor is part of the log line).
*/

/// @func	StopWatch(_name = "StopWatch")
function StopWatch(_name = "StopWatch") constructor {
	
	tstart	= get_timer();
	name	= _name;

	/// @func	restart()
	static restart = function() {
		tstart = get_timer();
		return self;
	}

	/// @func	millis()
	static millis = function() {
		return (get_timer() - tstart) / 1000;
	}

	/// @func	micros()
	static micros = function() {
		return (get_timer() - tstart);
	}
	
	/// @func	log_millis(_action = "elapsed")
	/// @desc	Logs the time with an optional action (like "stopwatch <elapsed> 000ms")
	static log_millis = function(_action = "elapsed") {
		var rv = (get_timer() - tstart) / 1000;
		dlog($"{name} {_action} {rv}ms");
		return rv;
	}

	/// @func	log_micros(_action = "elapsed")
	/// @desc	Logs the time with an optional action (like "stopwatch <elapsed> 000µs")
	static log_micros = function(_action = "elapsed") {
		var rv = (get_timer() - tstart);
		dlog($"{name} {_action} {rv}µs");
		return rv;
	}
}
