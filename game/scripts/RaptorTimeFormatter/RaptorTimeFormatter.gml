/*
    short description here
*/

function RaptorTimeFormatter() : RaptorLogFormatterBase() constructor {

	format_event = function(_level, _message) {
		return $"{current_time}: {_level} {_message}";
	}

}