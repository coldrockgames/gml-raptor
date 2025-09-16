/*
    short_description_here
*/
function RaptorConsoleAppender() : RaptorLogAppenderBase() constructor {
	construct(RaptorConsoleAppender);

	push_line = function(_logline) {
		gml_pragma("forceinline");
		show_debug_message(_logline);
	}

}