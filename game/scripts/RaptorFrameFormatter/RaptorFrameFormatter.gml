/*
    Logs the game frame
*/

function RaptorFrameFormatter() : RaptorLogFormatterBase() constructor {
	construct(RaptorFrameFormatter);
	
	format_event = function(_level, _message) {
		gml_pragma("forceinline");
		return $"{GAME_FRAME}: {_level} {_message}";
	}
}