/*
    Logs only the log level and the message, no additional info
*/

function RaptorSimpleFormatter() : RaptorLogFormatterBase() constructor {
	construct(RaptorSimpleFormatter);
	
	format_event = function(_level, _message) {
		gml_pragma("forceinline");
		return $"{_level} {_message}";
	}
	
}