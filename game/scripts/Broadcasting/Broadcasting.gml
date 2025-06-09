/*
	Message Broadcasting subsystem.
	Part of gml-raptor.
	
	This subsystem consists of three main components:
	- The "Sender": This is your main object.
					The Sender is kind of a radio-station, 
					sending out broadcasts to all listening receivers.
					Just create a new Sender() and add receivers to it.
					NOTE: gml-raptor creates one Sender per Room in the ROOMCONTROLLER
					object. You can use it by adding receivers to ROOMCONTROLLER.Sender
					
	- The "Receiver":	When using the add_receiver function of your sender, a receiver 
						is built with the given name, message_filter and callback.
						Use remove_receiver with its name to stop receiving messages in its callback.
						
	- The "Broadcast":	Use the send function on a sender to send out a broadcast message.
						It contains three members:
						from  - the sender of the broadcast
						title - the name of the broadcast (this one must pass the message_filter of a receiver)
						data  - optional struct that holds any additional data for this broadcast.
						
	How to use the subsystem:
	If you want to send something, just create a new Broadcast(...) and call Sender.send(broadcast).
	
	Here is a small example:
	var snd = new Sender();
	snd.add_receiver("achievement_counter", "*_died", my_achievement_counter_function);
	
	... when a monster dies you could invoke
	snd.send(self, "dragon_died");
		
	You may return "true" from your callback function if it shall be removed from the queue after
	processing the callback. This is a comfortable way to take a receiver out, when its work is done.
	
*/

// ---- RAPTOR INTERNAL BROADCASTS ----
#macro __RAPTOR_BROADCAST_MSGBOX_OPENED				"__raptor_msgbox_opened"
#macro __RAPTOR_BROADCAST_MSGBOX_CLOSED				"__raptor_msgbox_closed"
#macro __RAPTOR_BROADCAST_POPUP_SHOWN				"__raptor_popup_shown"
#macro __RAPTOR_BROADCAST_POPUP_HIDDEN				"__raptor_popup_hidden"
#macro __RAPTOR_BROADCAST_DATA_GAME_LOADED			"__raptor_gamefile_datamode_loaded"
#macro __RAPTOR_BROADCAST_DATA_GAME_SAVED			"__raptor_gamefile_datamode_saved"
#macro __RAPTOR_BROADCAST_GAME_LOADING				"__raptor_gamefile_loading"
#macro __RAPTOR_BROADCAST_GAME_LOADED				"__raptor_gamefile_loaded"
#macro __RAPTOR_BROADCAST_GAME_SAVING				"__raptor_gamefile_saving"
#macro __RAPTOR_BROADCAST_GAME_SAVED				"__raptor_gamefile_saved"
#macro __RAPTOR_BROADCAST_SAVEGAME_VERSION_CHECK	"__raptor_savegame_version_check"

#macro RAPTOR_SAVEGAME_ACTIVITY_BROADCAST_FILTER	"__raptor_gamefile_*"
// ---- RAPTOR INTERNAL BROADCASTS ----

global.__raptor_broadcast_uid = 0;
#macro __RAPTOR_BROADCAST_UID					(++global.__raptor_broadcast_uid)


function Sender() constructor {
	construct(Sender);	

	__receivercount = 0;
	receivers		= [];
	removers		= [];
	
	/// @func	add_receiver(_owner, _name, _message_filter, _callback)
	/// @desc	adds a listener for a specific kind of message.
	///			NOTE: If a receiver with that name already exists, it gets overwritten!
	///			The _message_filter is a wildcard string, that may
	///			contain "*" as placeholder either at the start of the string,
	///			at the end, or both, but not in-between.
	///			VALID FILTERS are:
	///			*_died
	///			enemy*
	///			*dragon*
	///			INVALID FILTERS are all that contain * in the middle, like
	///			enemy_*_died
	///			So, plan your broadcast names accordingly to be able to filter
	///			as you need!
	static add_receiver = function(_owner, _name, _message_filter, _callback) {
		if (_owner == undefined) {
			wlog($"** WARNING ** add_receiver '{_name}' ignored, no 'owner' given!");
			return;
		}
		
		var rcv = new __receiver(_owner, _name, _message_filter, _callback);
		remove_receiver(_name);
		array_push(receivers, rcv);
		__receivercount++;
		if (DEBUG_LOG_BROADCASTS)
			vlog($"Broadcast receiver added: name='{_name}'; filter='{_message_filter}';");
		
		return self;
	}

	/// @func	remove_receiver(_name)
	/// @desc	Removes the receiver with the specified name and returns true, if found.
	///			If it does not exist, it is silently ignored, but false is returned.
	static remove_receiver = function(_name) {
		for (var i = 0, len = array_length(receivers); i < len; i++) {
			var r = receivers[@ i];
			if (r.name == _name) {
				array_delete(receivers, i, 1);
				__receivercount--;
				if (DEBUG_LOG_BROADCASTS)
					vlog($"Broadcast receiver removed: name='{_name}';");
				return true;
			}
		}
		return false;
	}

	/// @func	remove_owner(_owner)
	/// @desc	Removes ALL receivers with the specified owner and returns the number of removed receivers.
	///			NOTE: If your object is a child of _raptorBase, you do not need to call this,
	///			because the base object removes all owned receivers in the CleanUp event
	static remove_owner = function(_owner) {
		var cnt = 0;
		var tmpremovers = [];
		for (var i = 0, len = array_length(receivers); i < len; i++) {
			var r = receivers[@ i];
			if (r.owner == _owner) {
				cnt++;
				array_push(tmpremovers, r.name);
			}
		}
		if (array_length(tmpremovers) > 0) {
			for (var i = 0, len = array_length(tmpremovers); i < len; i++) {
				var rname = tmpremovers[@i];
				remove_receiver(rname);
			}
			var ownername = "<dead instance>";
			if (is_object_instance(_owner)) ownername = name_of(_owner);
			if (DEBUG_LOG_BROADCASTS)
				vlog($"{cnt} broadcast receiver(s) removed for owner {ownername}");
		}
		return cnt;
	}

	/// @func	send(_from, _title, _data = undefined)
	/// @desc	Sends a broadcast and returns self for call chaining if you want to
	///				send multiple broadcasts.
	///				Set .handled to true in the broadcast object delivered to the function
	///				to stop the send-loop from sending the same message to the remaining recipients.
	static send = function(_from, _title, _data = undefined) {	
		var bcid = __RAPTOR_BROADCAST_UID;
		var bc = new __broadcast(_from, _title, _data);
		bc.uniqueid = bcid;
		
		var started = get_timer();
		
		removers = [];
		var loopers = array_create(array_length(receivers));
		array_copy(loopers, 0, receivers, 0, array_length(receivers));
		array_sort(loopers, function(elm1, elm2)
		{
			// TODO: In case, broadcasts break, re-enable this try/catch
			//TRY 
				return (elm1.has_depth ? elm1.owner.depth : 0) - (elm2.has_depth ? elm2.owner.depth : 0); 
			//CATCH 
			//	return 0; 
			//ENDTRY
		});

		for (var i = 0, len = array_length(loopers); i < len; i++) {
			var r = loopers[@ i];
			if (r.filter_hit(_title)) {
				if (DEBUG_LOG_BROADCASTS)
					dlog($"Sending broadcast #{bcid}: title='{_title}'; to='{r.name}';");
				if (r.callback(bc))
					array_push(removers, r.name);
			}
			if (bc.handled) {
				if (DEBUG_LOG_BROADCASTS)
					dlog($"Broadcast #{bcid}: '{_title}' was handled by '{r.name}'");
				break;
			}
		}
		
		if (DEBUG_LOG_BROADCASTS)
			vlog($"Broadcast #{bcid}: '{_title}' finished in {(get_timer() - started)}µs");
		
		for (var i = 0, len = array_length(removers); i < len; i++) 
			remove_receiver(removers[@ i]);
		
		return self;
	}
	
	/// @func	clear()
	/// @desc	Removes all receivers.	
	static clear = function() {
		if (DEBUG_LOG_BROADCASTS)
			ilog($"Broadcast receiver list cleared");
		receivers = [];
		__receivercount = 0;
	}

	static dump_to_string = function() {
		return $"Receivers: {array_length(receivers)} Sent: {global.__raptor_broadcast_uid}";
	}

}

/*
    A receiver for broadcast messages sent through a Sender.
	
	The callback will receive 1 parameter: The Broadcast message,
	containing "from", "title" and (optional) "data" members.
*/

/// @func	__receiver(_owner, _name, _message_filter, _callback)
/// @desc	Contains a receiver.
function __receiver(_owner, _name, _message_filter, _callback) constructor {
	owner			= _owner;
	has_depth		= (vsget(_owner, "depth") != undefined);
	name			= _name;
	message_filter  = string_split(_message_filter, "|", true);
	callback		= method(owner, _callback);
	
	static filter_hit = function(_title) {
		if (array_contains(message_filter, _title))
			return true;
		
		for (var i = 0, len = array_length(message_filter); i < len; i++) {
			if (string_match(_title, message_filter[@i]))
				return true;
		}
		
		return false;
	}
	
	toString = function() {
		return $"{name_of(owner)}/{message_filter[@0]}";
	}
}

/// @func	__broadcast(_from, _title, _data = undefined)
/// @desc	Contains a broadcast message with at least a "from" and a "title".
function __broadcast(_from, _title, _data = undefined) constructor {
	uniqueid	= -1;
	handled		= false;
	from		= _from;
	title		= _title;
	data		= _data;
}