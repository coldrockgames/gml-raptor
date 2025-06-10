/*
    HighScoreTable class for GameMaker Studio 2.3+
	
	This class provides an easy way to manage highscore tables for your games.
	
	Highscore tables can be built upon one of these criterias (use the scoring enum):
	---------------------------------------------------------------------------------
	score_high		most points reached
	score_low		least points reached (like in "Hearts" card game where points are bad)
	time_low		Fastest player (for racing games)
	time_high		Longest survival
	
	The criteria you set when creating a table defines the sort order of the
	entries in the table.
	
	NOTE: "time" values are expected to be in milliseconds!
*/

enum scoring {
	score_high	= 0,
	score_low	= 1,
	time_high	= 2,
	time_low	= 3,
}

function HighScoreTable(_name = "Highscores", _max_entries = 10, _criteria = scoring.score_high) constructor {
	
	data = {
		name : _name,
		max_entries : _max_entries,
		criteria : _criteria,
		entries : array_create(_max_entries, undefined),
	}
	
	static assign_data = function(loaded_data) {
		data.name = struct_get(loaded_data, "name");
		data.max_entries = struct_get(loaded_data, "max_entries");
		data.criteria = loaded_data.criteria;
		for (var i = 0; i < array_length(loaded_data.entries); i++) {
			var le = loaded_data.entries[@ i].data;
			data.entries[@ i] = new HighScoreEntry(le.Name, le.Score, le.Time, le.ID);
			data.entries[@ i].data.Created = le.Created;
		}
	}
	
	/// @func		reset()
	/// @desc	Remove all entries and start over with a new array
	static reset = function() {
		data.entries = array_create(data.max_entries, undefined);	
	}

	static __is_better_than = function(value, better_than_entry) {
		switch (data.criteria) {
			case scoring.score_high:	return (value != undefined) && (value >= better_than_entry.data.Score);
			case scoring.score_low:		return (value != undefined) && (value <= better_than_entry.data.Score);
			case scoring.time_high:		return (value != undefined) && (value >= better_than_entry.data.Time);
			case scoring.time_low:		return (value != undefined) && (value <= better_than_entry.data.Time);
		}
	}

	/// @func		size()
	/// @desc	Gets the number of entries in the table (not the array size)
	static size = function() {
		for (var i = 0; i < array_length(data.entries); i++) {
			if (data.entries[@ i] == undefined)
				return i;
		}
		return array_length(data.entries);
	}

	/// @func		get_highscore_rank(_value)
	/// @desc	Returns the place in the highscore table for a specific
	///					score value. Which field is compared depends on the "scoring"
	///					of the table (score high/low, time high/low).
	///					If the supplied value is not good enough for a place in the
	///					highscore table, -1 is returned.
	///					NOTE: Ranks are 1-based, not 0-based. "1" is the first place!
	/// @param {real}	_value	The value to compare in the table
	/// @returns {int}	The place in the highscore table or -1, if no highscore.
	static get_highscore_rank = function(_value) {
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined || __is_better_than(_value, entry))
				return i + 1;
		}
		return -1;
	}

	
	/// @func		register_highscore(_name, _score, _time, _id = undefined)
	/// @desc	Add a new entry to the highscore table.
	///					The added entry is returned or undefined, if the 
	///					score or time was not good enough for the table.
	/// @param {string} _name	The name of the player
	/// @param {int} _score	The points reached.
	/// @param {int} _time	The running time of the game. Expected to be in milliseconds.
	/// @param {any} _id	Optional value if you have some unique player ids in your game.
	/// @returns {HighScoreEntry} The entry generated or undefined, if this was not a highscore.
	static register_highscore = function(_name, _score = undefined, _time = undefined, _id = undefined) {
		var val;
		switch (data.criteria) {
			case scoring.score_high:	
			case scoring.score_low:
				val = _score;
				break;
			case scoring.time_high:
			case scoring.time_low:
				val = _time;
				break;
		}
		
		var rank = get_highscore_rank(val);
		if (rank == -1)
			return undefined;
		
		var rv = new HighScoreEntry(_name, _score, _time, _id);
		array_insert(data.entries, rank - 1, rv);
		array_resize(data.entries, data.max_entries);
		return rv;
	}

	/// @func		get_rank_list(from_rank = -1, to_rank = -1, prefix_character = "#")
	/// @desc	Get a list of ranks, one per line. This is useful
	///					for rendering the table. This is your "rank" column.
	///					NOTE: "rank" parameters are 1-based, NOT 0-based!
	///					rank 1 returns the leader of the table!
	///	@param {int=-1} from_rank. Leave at -1 to receive everything.
	///	@param {int=-1} to_rank. Leave at -1 to receive everything.
	///	@param {string="#"} prefix_character. The character to print as prefix to the rank number.
	static get_rank_list = function(from_rank = -1, to_rank = -1, prefix_character = "#") {
		if (to_rank < 0) to_rank = array_length(data.entries);
		var rv = "";
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			if (i >= from_rank - 1 && i <= to_rank - 1)
				rv = string_concat(rv, (rv == "" ? "" : "\n"), prefix_character, string(i + 1));
		}
		return rv;
	}

	/// @func		get_name_list(from_rank = -1, to_rank = -1)
	/// @desc	Get a list of names, one per line. This is useful
	///					for rendering the table. This is your "names" column.
	///					NOTE: "rank" parameters are 1-based, NOT 0-based!
	///					rank 1 returns the leader of the table!
	///	@param {int=-1} from_rank. Leave at -1 to receive everything.
	///	@param {int=-1} to_rank. Leave at -1 to receive everything.
	static get_name_list = function(from_rank = -1, to_rank = -1) {
		if (to_rank < 0) to_rank = array_length(data.entries);
		var rv = "";
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			if (i >= from_rank - 1 && i <= to_rank - 1)
				rv = string_concat(rv, (rv == "" ? "" : "\n"), entry.data.Name);
		}
		return rv;
	}

	/// @func		get_score_list(from_rank = -1, to_rank = -1)
	/// @desc	Get a list of scores, one per line. This is useful
	///					for rendering the table. This is your "score" column
	///					NOTE: "rank" parameters are 1-based, NOT 0-based!
	///					rank 1 returns the leader of the table!
	///	@param {int=-1} from_rank. Leave at -1 to receive everything.
	///	@param {int=-1} to_rank. Leave at -1 to receive everything.
	///	@param {int=0}	decimals. Number of decimal places to show.
	static get_score_list = function(from_rank = -1, to_rank = -1, decimals = 0) {
		if (to_rank < 0) to_rank = array_length(data.entries);
		var rv = "";
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			if (i >= from_rank - 1 && i <= to_rank - 1)
				rv = string_concat(rv, (rv == "" ? "" : "\n"), string_format(entry.data.Score ?? 0, 1, decimals));
		}
		return rv;
	}

	/// @func		get_time_list(from_rank = -1, to_rank = -1)
	/// @desc	Get a list of times, one per line. This is useful
	///					for rendering the table. This is your "time" column
	///					NOTE: "rank" parameters are 1-based, NOT 0-based!
	///					rank 1 returns the leader of the table!
	///	@param {int=-1} from_rank. Leave at -1 to receive everything.
	///	@param {int=-1} to_rank. Leave at -1 to receive everything.
	static get_time_list = function(from_rank = -1, to_rank = -1) {
		if (to_rank < 0) to_rank = array_length(data.entries);
		// first, find out if we need the hours
		var skip_hours = true;
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			if (entry.data.Time != undefined && entry.data.Time >= 3600000) { // 3600000 are the millis of one hour
				skip_hours = false;
				break;
			}
		}
		var rv = "";
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			if (i >= from_rank - 1 && i <= to_rank - 1)
				rv = string_concat(rv, (rv == "" ? "" : "\n"), entry.format_time(!skip_hours));
		}
		return rv;
	}

	/// @func		get_created_list(from_rank = -1, to_rank = -1, day_only = false)
	/// @desc	Get a list of times, one per line. This is useful
	///					for rendering the table. This is your "created" column.
	///					NOTE: "rank" parameters are 1-based, NOT 0-based!
	///					rank 1 returns the leader of the table!
	///	@param {int=-1} from_rank. Leave at -1 to receive everything.
	///	@param {int=-1} to_rank. Leave at -1 to receive everything.
	///	@param {bool=false} day_only. If true, only the date part of the creation of this entry is returned
	static get_created_list = function(from_rank = -1, to_rank = -1, day_only = false) {
		if (to_rank < 0) to_rank = array_length(data.entries);
		var rv = "";
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			if (i >= from_rank - 1 && i <= to_rank - 1)
				rv = string_concat(rv, (rv == "" ? "" : "\n"), (day_only ? date_date_string(entry.data.Created) : date_datetime_string(entry.data.Created)));
		}
		return rv;
	}

	// Dumps the entire table
	toString = function() {
		
		var max_name_len = 0;
		var max_score_len = -1;
		var max_time_len = -1;
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			max_name_len = max(max_name_len, string_length(entry.data.Name));
			if (entry.data.Score != undefined) max_score_len = max(max_score_len, string_length(string(entry.data.Score)));
			if (entry.data.Time != undefined) max_time_len = max(max_time_len, string_length(entry.format_time()));
		}
		
		var rv = "";
		for (var i = 0; i < array_length(data.entries); i++) {
			var entry = data.entries[@ i];
			if (entry == undefined)
				break;
			var tm = max_time_len > 0 ? entry.format_time() : "";
			rv = string_concat(rv, (rv == "" ? "" : "\n"),
				entry.data.Name, string_repeat(" ", max_name_len + 2 - string_length(entry.data.Name)),
				(max_score_len > 0 ? string_repeat(" ", max_score_len + 2 - string_length(string(entry.data.Score))) + string(entry.data.Score) : ""),
				(max_time_len > 0 ? string_repeat(" ", max_time_len + 2 - string_length(tm)) + tm : ""),
				"  ", date_datetime_string(entry.data.Created));
		}
		return rv;
	}

}
