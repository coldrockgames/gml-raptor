/*
    Holds one entry of the HighScoreTable.
	
	You can derive from this class to create your
	own custom entries but make sure, that the original
	properties (ID, Name, Score, Time, Created) are still accessible.
	
	NOTE: The "Created" field is set automatically to utc_now when
	the constructor gets called, you don't need to set it manually.
	
	Default properties for an entry:
	-------------------------------------------------
	ID			Optional. Can be used to store a 
				unique player id (like a guid) if 
				your the player is connected to some
				account in your game.
				
	Name		Player's name
	
	Score		The points the player reached
	
	Time		The duration of the game (in milliseconds)
	
	Created		Creation time of this entry
*/

function HighScoreEntry(_name, _score, _time, _id = undefined) constructor {
	
	data = {
		ID		: _id,
		Name	: _name,
		Score	: _score,
		Time	: _time,
	}
	
	var tmptz = date_get_timezone();
	date_set_timezone(timezone_utc);
	data.Created = date_current_datetime();
	date_set_timezone(tmptz);

	/// @func		format_time(_time)
	/// @desc	Formats the time of the entry to a common format hh:mm:ss.iii
	/// @param {bool=true} with_hours	Include "00:" a place for the hours in the string
	static format_time = function(with_hours = true) {
		if (data.Time == undefined) 
			return string_concat((with_hours ? "00:" : ""), "00:00.000");
		
		var ms = frac(data.Time / 1000) * 1000;
		var secs = data.Time div 1000;
		var mins = secs div 60;
		secs -= 60 * mins;
		var hrs = mins div 60;
		if (with_hours)
			mins -= 60 * hrs;
		return string_concat(
			(with_hours ? string_concat(string_replace_all(string_format(hrs, 2, 0), " ", "0"), ":") : ""), 
			string_concat(string_replace_all(string_format(mins, 2, 0), " ", "0"), ":"), 
			string_concat(string_replace_all(string_format(secs, 2, 0), " ", "0"), "."), 
			string_replace_all(string_format(ms, 3, 0), " ", "0"));
	}

}
