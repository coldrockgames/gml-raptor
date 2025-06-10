/*
    short description here
*/

function RaptorSimpleFormatter() : RaptorLogFormatterBase() constructor {

	format_event = function(_level, _message) {
		return $"{_level} {_message}";
	}
	
}