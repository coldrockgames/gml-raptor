/*
    Logs the time in millis since game start
*/

function RaptorTimeFormatter() : RaptorLogFormatterBase() constructor {
	construct(RaptorTimeFormatter);
	
	format_event = function(_level, _message) {
		gml_pragma("forceinline");
		return $"{current_time}: {_level} {_message}";
	}

}