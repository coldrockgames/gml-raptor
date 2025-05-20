/*
    Configure command line argument analysis here
	
	SWITCH_IDENTIFIERS:
		Any argument that starts with one of the characters will be considered a switch
		and can be retrieved/evaluated through the .has_switch(...) function of ARGS
		
	OPTION_IDENTIFIER:
		A special prefix that is analyzed first (to avoid conflicts with the "-" switch)
		and can be retrieved/evaluated through the .has_option(...) function of ARGS
		
	COMMAND_IDENTIFIER:
		A seperator character, that can be used in arguments like "out=file.txt" and "in=c:\dev\file.txt"
		If the argument contains this character, it will be split by the FIRST OCCURENCE of one of the
		COMMAND_IDENTIFIERS and can be retrieved/evaluated through the .has_command(...) function of ARGS
		
*/

#macro ARGS_SWITCH_ENABLED			"+"
#macro ARGS_SWITCH_DISABLED			"-"
#macro ARGS_SWITCH_NEUTRAL			"/"
#macro ARGS_SWITCH_IDENTIFIERS		$"{ARGS_SWITCH_ENABLED}{ARGS_SWITCH_DISABLED}{ARGS_SWITCH_NEUTRAL}"
#macro ARGS_OPTION_IDENTIFIER		"--"
#macro ARGS_COMMAND_IDENTIFIERS		[ ":", "=" ]


/*
	ARGS is a global variable which holds the analysis of the commandline when the game was started.
	If you plan to use this from global context (i.e. in a code line in a script outside of any function),
	you can never be sure, that the "ARGS = new CommandlineArgs();" has already been run, so you should
	force initialization through "ENSURE_ARGS;" first, before you access ARGS
*/

#macro ARGS						global.__ARGS
ARGS = new CommandlineArgs();
#macro ENSURE_ARGS				if (!variable_global_exists("__ARGS")) ARGS = new CommandlineArgs();
