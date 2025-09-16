/*
    Short utility class to measure time.
	
	Starts automatically when constructed, but offers a .restart() method to reset
	Use the .millis() or .micros() methods to get the elapsed time since start.
	If you want to immediately also write the time to the log on debug level (dlog),
	use .checkpoint(). It also returns the time (in microseconds), it
	just creates the log in addition for you.
	(The "name" you set in the constructor is part of the log line).
*/

/// @func	StopWatch(_name = "StopWatch")
function StopWatch(_name = "StopWatch") constructor {
	
	tstart		= get_timer();
	name		= _name;

	__created	= tstart;
	__micros	= 0;
	__logtime	= 0;
	__unit		= "µs";

	/// @func	restart()
	static restart = function() {
		tstart = get_timer();
		return self;
	}

	/// @func	millis()
	/// @desc	Get the elapsed milliseconds since the watch has been started
	static millis = function() {
		return (get_timer() - tstart) / 1000;
	}

	/// @func	micros()
	/// @desc	Get the elapsed microseconds since the watch has been started
	static micros = function() {
		return (get_timer() - tstart);
	}

	/// @func	total(_as_string = true)
	/// @desc	Returns the elapsed time since this instance has been created.
	///			This value is not affected by restarts or other operations.
	///			If _as_string is true, the value looks like "146µs" if the elapsed
	///			time is less than 1000µs, otherwise it's "35.62ms" as milliseconds.
	///			If _as_string is false, the total time in microseconds is returned
	///			as a real value.
	static total = function(_as_string = true) {
		__micros	= (get_timer() - __created);
		
		if (_as_string) {
			__logtime	= __micros;
			__unit		= "µs";
		
			if (__micros > 1000) {
				__unit = "ms";
				__logtime = __micros / 1000;
			}
		
			return $"{__logtime}{__unit}";
			
		} else
			return __micros;
	}

	/// @func	checkpoint(_action = "checkpoint reached after", _restart_after = true)
	/// @desc	Prints a check point to the log. The elapsed time is printed in microseconds
	///			while the value is less than 1000, then it is converted to milliseconds.
	///			This function always returns the elapsed microseconds since the last checkpoint.
	static checkpoint = function(_action = "checkpoint reached after", _restart_after = true) {
		__micros	= (get_timer() - tstart);
		__logtime	= __micros;
		__unit		= "µs";
		
		if (__micros > 1000) {
			__unit = "ms";
			__logtime = __micros / 1000;
		}
		
		dlog($"{name} {_action} {__logtime}{__unit}");
		if (_restart_after) restart();
		return __micros;
	}
	
}
