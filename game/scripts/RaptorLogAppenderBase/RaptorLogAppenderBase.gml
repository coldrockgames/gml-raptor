/*
    A log appender is a class that finally pushes a formatted log line to 
	its destination (like the console, the network, a file, ...)
*/

function RaptorLogAppenderBase() constructor {
	construct(RaptorLogAppenderBase);

	/// @func	push_line(_line)
	/// @desc	Push the log line to its destination
	push_line = function(_line) {
	}

	/// @func	game_starting()
	/// @desc	Invoked by GameStarter when a game starts
	game_starting = function() {
	}

	/// @func	shutdown()
	/// @desc	Shutdown/Stop this appender
	shutdown = function() {
	}

}