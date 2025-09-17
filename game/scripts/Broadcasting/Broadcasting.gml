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
#macro RAPTOR_BROADCAST_MSGBOX_OPENED				"raptor_msgbox_opened"
#macro RAPTOR_BROADCAST_MSGBOX_CLOSED				"raptor_msgbox_closed"
#macro RAPTOR_BROADCAST_POPUP_SHOWN					"raptor_popup_shown"
#macro RAPTOR_BROADCAST_POPUP_HIDDEN				"raptor_popup_hidden"
#macro RAPTOR_BROADCAST_POPUP_DESTROYED				"raptor_popup_destroyed"
#macro RAPTOR_BROADCAST_DATA_GAME_LOADING			"raptor_gamefile_datamode_loading"
#macro RAPTOR_BROADCAST_DATA_GAME_LOADED			"raptor_gamefile_datamode_loaded"
#macro RAPTOR_BROADCAST_DATA_GAME_SAVING			"raptor_gamefile_datamode_saving"
#macro RAPTOR_BROADCAST_DATA_GAME_SAVED				"raptor_gamefile_datamode_saved"
#macro RAPTOR_BROADCAST_GAME_LOADING				"raptor_gamefile_loading"
#macro RAPTOR_BROADCAST_GAME_LOADED					"raptor_gamefile_loaded"
#macro RAPTOR_BROADCAST_GAME_LOADING_NEW_ROOM		"raptor_gamefile_loading_new_room"
#macro RAPTOR_BROADCAST_GAME_SAVING					"raptor_gamefile_saving"
#macro RAPTOR_BROADCAST_GAME_SAVED					"raptor_gamefile_saved"
#macro RAPTOR_BROADCAST_SAVEGAME_VERSION_CHECK		"raptor_savegame_version_check"
#macro RAPTOR_BROADCAST_WINDOW_SIZE_CHANGED			"raptor_window_size_changed"
#macro RAPTOR_BROADCAST_SCENE_LOCKED				"raptor_scene_locked"
#macro RAPTOR_BROADCAST_SCENE_UNLOCKED				"raptor_scene_unlocked"
#macro RAPTOR_BROADCAST_MOUSE_UI_ENTER				"raptor_mouse_ui_enter"
#macro RAPTOR_BROADCAST_MOUSE_UI_LEAVE				"raptor_mouse_ui_leave"

#macro RAPTOR_MESSAGEBOX_BROADCAST_FILTER			"raptor_msgbox_*"
#macro RAPTOR_POPUP_BROADCAST_FILTER				"raptor_popup_*"
#macro RAPTOR_SAVEGAME_BROADCAST_FILTER				"raptor_gamefile_*"
#macro RAPTOR_MOUSE_UI_BROADCAST_FILTER				"raptor_mouse_ui_*"
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
	///			contain "*" as placeholder according to the string_match specifications
	static add_receiver = function(_owner, _name, _message_filter, _callback) {
		if (_owner == undefined) {
			wlog($"** WARNING ** add_receiver '{_name}' ignored, no 'owner' given!");
			return self;
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
		var r;
		for (var i = 0, len = array_length(receivers); i < len; i++) {
			r = receivers[@ i];
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

	/// @func	receiver_exists(_name)
	/// @desc	Checks whether a receiver with the specified name exists
	static receiver_exists = function(_name) {
		for (var i = 0, len = array_length(receivers); i < len; i++)
			if (receivers[@ i].name == _name) 
				return true;
				
		return false;
	}

	/// @func	receiver_count(_name_or_owner)
	/// @desc	Counts the existing receivers.
	///			Supply a (wildcard-)string as argument to count
	///			receivers that match a specified name or supply
	///			an owner instance to count the number of receivers
	///			registered for this instance.
	static receiver_count = function(_name_or_owner) {
		var rv = 0;
		
		if (is_string(_name_or_owner)) {
			for (var i = 0, len = array_length(receivers); i < len; i++)
				if (string_match(receivers[@ i].name, _name_or_owner)) 
					rv++
		} else {
			for (var i = 0, len = array_length(receivers); i < len; i++)
				if (receivers[@ i].owner == _name_or_owner)
					rv++			
		}
		
		return rv;
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

		var r;
		if (DEBUG_LOG_BROADCASTS) var rcvcnt = 0;
		for (var i = 0, len = array_length(loopers); i < len; i++) {
			r = loopers[@ i];
			if (r.filter_hit(_title)) {
				if (DEBUG_LOG_BROADCASTS) {
					vlog($"Sending broadcast #{bcid}: title='{_title}'; to='{r.name}';");
					rcvcnt++;
				}
				if (r.callback(bc))
					array_push(removers, r.name);
			}
			if (bc.handled) {
				if (DEBUG_LOG_BROADCASTS)
					dlog($"Broadcast #{bcid}: '{_title}' was handled by '{r.name}'");
				break;
			}
		}
		
		if (DEBUG_LOG_BROADCASTS) {
			var ended = get_timer() - started;
			var unit = "µs";
			if (ended > 1000) {
				unit = "ms";
				ended /= 1000;
			}
			dlog($"Broadcast #{bcid}: '{_title}' with {rcvcnt} receivers finished in {ended}{unit}");
		}
		
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