/*
    Convenience Audio functions.
*/

#region DEFAULT AUDIO FOR ROOMS
function __default_room_audio_entry(_room, _room_music = undefined, _ambience_sound = undefined) constructor {
	for_room = _room;
	music = _room_music;
	ambience = _ambience_sound;
}

#macro __DEFAULT_ROOM_AUDIO		global.__default_room_audio
__DEFAULT_ROOM_AUDIO			= [];

function __room_audio_session() constructor {
	music_id = undefined;
	music_asset = undefined;
	ambience_id = undefined;
	ambience_asset = undefined;
	
	/// @func		is_same_music()
	static is_same_music = function(mus) {
		return music_id != undefined && mus == music_asset;
	}
	
	/// @func		is_same_ambience()
	static is_same_ambience = function(amb) {
		return ambience_id != undefined && amb == ambience_asset;
	}
	
	/// @func		stop_active_music(fade_out_time_ms)
	static stop_active_music = function(fade_out_time_ms) {
		if (music_id != undefined) {
			audio_sound_gain(music_id, 0, fade_out_time_ms);
			run_delayed(GAMECONTROLLER, ms_to_frames(fade_out_time_ms), function(_music_id) { audio_stop_sound(_music_id); }, music_id);
			music_id = undefined;
			music_asset = undefined;
		}
	}
	
	/// @func		stop_active_ambience(fade_out_time_ms)
	static stop_active_ambience = function(fade_out_time_ms) {
		if (ambience_id != undefined) {
			audio_sound_gain(ambience_id, 0, fade_out_time_ms);
			run_delayed(GAMECONTROLLER, ms_to_frames(fade_out_time_ms), function(_amb_id) { audio_stop_sound(_amb_id); }, ambience_id);
			ambience_id = undefined;
			ambience_asset = undefined;
		}
	}

	/// @func __ambience_private(amb, gain, fade_in_time_ms, loop, pitch, offset, listener_mask, priority, reassign)
	static __ambience_private = function(amb, gain, fade_in_time_ms, loop, pitch, offset, listener_mask, priority, reassign) {
		amb ??= (ambience_asset ?? get_default_ambience_for_room());
		if (AUDIOSETTINGS.ambience_enabled && amb != undefined) {
			var finalgain = gain * AUDIOSETTINGS.ambience_volume * AUDIOSETTINGS.master_volume;
			var startgain = (fade_in_time_ms > 0 ? 0 : finalgain);
			
			var newid =
				audio_play_sound(amb, priority, loop, startgain, offset, pitch, listener_mask);
		
			if (fade_in_time_ms > 0)
				audio_sound_gain(newid, finalgain, fade_in_time_ms);
		
			if (reassign) {
				ambience_id = newid;
				ambience_asset = amb;
			}
		}
	}

	/// @func __music_private(mus, gain, fade_in_time_ms, loop, pitch, offset, listener_mask, priority, reassign)
	static __music_private = function(mus, gain, fade_in_time_ms, loop, pitch, offset, listener_mask, priority, reassign) {
		mus ??= (music_asset ?? get_default_music_for_room());
		if (AUDIOSETTINGS.music_enabled && mus != undefined) {
			var finalgain = gain * AUDIOSETTINGS.music_volume * AUDIOSETTINGS.master_volume;
			var startgain = (fade_in_time_ms > 0 ? 0 : finalgain);
		
			var newid =
				audio_play_sound(mus, priority, loop, startgain, offset, pitch, listener_mask);

			if (fade_in_time_ms > 0)
				audio_sound_gain(newid, finalgain, fade_in_time_ms);

			if (reassign) {
				__ACTIVE_AUDIO_SESSION.music_id = newid;
				__ACTIVE_AUDIO_SESSION.music_asset = mus;
			}
		}
	}

}

#macro __ACTIVE_AUDIO_SESSION		global.__active_audio_session
__ACTIVE_AUDIO_SESSION				= new __room_audio_session();

/// @func set_room_default_audio(_room, _music, _ambience)
/// @desc Define a music track and an ambience track that shall start playing
///				 automatically, when the room is entered
function set_room_default_audio(_room, _music, _ambience) {
	for (var i = 0; i < array_length(__DEFAULT_ROOM_AUDIO); i++) {
		if (__DEFAULT_ROOM_AUDIO[@ i].for_room == _room) {
			var aud = __DEFAULT_ROOM_AUDIO[@ i];
			aud.music = _music;
			aud.ambience = _ambience;
			return;
		}
	}
	array_push(__DEFAULT_ROOM_AUDIO, new __default_room_audio_entry(_room, _music, _ambience));
}

/// @func get_default_music_for_room()
/// @desc Get the sound_id of the currently playing music stream
function get_default_music_for_room() {
	for (var i = 0; i < array_length(__DEFAULT_ROOM_AUDIO); i++)
		if (__DEFAULT_ROOM_AUDIO[@ i].for_room == room)
			return __DEFAULT_ROOM_AUDIO[@ i].music;
	return undefined;
}

/// @func get_default_ambience_for_room()
/// @desc Get the sound_id of the currently playing ambience stream
function get_default_ambience_for_room() {
	for (var i = 0; i < array_length(__DEFAULT_ROOM_AUDIO); i++)
		if (__DEFAULT_ROOM_AUDIO[@ i].for_room == room)
			return __DEFAULT_ROOM_AUDIO[@ i].ambience;
	return undefined;
}
#endregion

/// @func		play_ui_sound(snd, gain = 1.0, pitch = 1.0, offset = 0, listener_mask = -1, priority = 7)
/// @desc	Plays a sound of type ui (attached to ui_volume setting)
function play_ui_sound( snd, 
						gain		  = 1.0, 
						pitch		  = AUDIO_UI_DEFAULT_PITCH, 
						offset		  = 0, 
						listener_mask = AUDIO_UI_DEFAULT_LISTENER_MASK, 
						priority	  = AUDIO_UI_DEFAULT_PRIORITY) {
	if (AUDIOSETTINGS.ui_enabled && snd != undefined) {
		var sid = audio_play_sound(snd, priority, false,
			gain * AUDIOSETTINGS.ui_volume * AUDIOSETTINGS.master_volume, offset, pitch, listener_mask);
		return sid;
	}
	return undefined;
}

/// @func		play_voice(snd, gain = 1.0, loop = false, pitch = 1.0, offset = 0, listener_mask = -1, priority = 10)
/// @desc	Plays a sound of type voice (attached to voice_volume setting)
function play_voice(snd, 
					gain		  = 1.0, 
					loop		  = false, 
					pitch		  = AUDIO_VOICE_DEFAULT_PITCH, 
					offset		  = 0, 
					listener_mask = AUDIO_VOICE_DEFAULT_LISTENER_MASK, 
					priority	  = AUDIO_VOICE_DEFAULT_PRIORITY) {
						
	if (AUDIOSETTINGS.voice_enabled && snd != undefined) {
		var sid = audio_play_sound(snd, priority, loop,
			gain * AUDIOSETTINGS.voice_volume * AUDIOSETTINGS.master_volume, offset, pitch, listener_mask);
		return sid;
	}
	return undefined;
}

/// @func		play_sound(snd, gain = 1.0, loop = false, pitch = 1.0, offset = 0, listener_mask = -1, priority = 10)
/// @desc	Plays a sound of type sfx (attached to sound_volume setting)
function play_sound(snd, 
					gain		  = 1.0, 
					loop		  = false, 
					pitch		  = AUDIO_SOUND_DEFAULT_PITCH, 
					offset		  = 0, 
					listener_mask = AUDIO_SOUND_DEFAULT_LISTENER_MASK, 
					priority	  = AUDIO_SOUND_DEFAULT_PRIORITY) {
						
	if (AUDIOSETTINGS.sound_enabled && snd != undefined) {
		var sid = audio_play_sound(snd, priority, loop, 
			gain * AUDIOSETTINGS.sound_volume * AUDIOSETTINGS.master_volume, offset, pitch, listener_mask);
		return sid;
	}
	return undefined;
}

/// @func		stop_sound(sound_id)
/// @desc	Stops any supplied playing sound_id
function stop_sound(sound_id) {
	if (sound_id != undefined)
		audio_stop_sound(sound_id);
}

/// @func		update_audio_streams()
/// @desc	Updates both streaming channels (music and ambience) with current
///					values for volume and their enabled state. 
///					You must invoke this function whenever you change the enabled state
///					or the volume of a streaming channel
function update_audio_streams() {
	if (__ACTIVE_AUDIO_SESSION != undefined) {
		// --- Audio update
		if (__ACTIVE_AUDIO_SESSION.music_id != undefined) {
			if (AUDIOSETTINGS.music_enabled) {
				audio_sound_gain(__ACTIVE_AUDIO_SESSION.music_id, 
					AUDIOSETTINGS.music_volume * AUDIOSETTINGS.master_volume, 0);
			} else {
				stop_music();
			}
		} else if (AUDIOSETTINGS.music_enabled) {
			// restart the music, if it got enabled
			play_music(get_default_music_for_room());
		}
		
		// --- Ambience update
		if (__ACTIVE_AUDIO_SESSION.ambience_id != undefined) {
			if (AUDIOSETTINGS.ambience_enabled) {
				audio_sound_gain(__ACTIVE_AUDIO_SESSION.ambience_id, 
					AUDIOSETTINGS.ambience_volume * AUDIOSETTINGS.master_volume, 0);
			} else {
				stop_ambience();
			}
		} else if (AUDIOSETTINGS.ambience_enabled) {
			// restart the ambience, if it got enabled
			play_ambience(get_default_ambience_for_room());
		}
	}
}

/// @func		play_music(mus, gain = 1.0, fade_in_time_ms = 1000, loop = true, force_restart = false, pitch = 1.0, offset = 0, listener_mask = -1, priority = 9)
/// @desc	Plays a sound of type music (attached to music_volume setting)
function play_music(mus, 
					gain			= 1.0, 
					fade_in_time_ms = AUDIO_MUSIC_DEFAULT_FADE_IN_MS, 
					loop			= AUDIO_MUSIC_DEFAULT_LOOP, 
					force_restart	= false, 
					pitch			= AUDIO_MUSIC_DEFAULT_PITCH, 
					offset			= 0, 
					listener_mask	= AUDIO_MUSIC_DEFAULT_LISTENER_MASK, 
					priority		= AUDIO_MUSIC_DEFAULT_PRIORITY) {
						
	if (!force_restart && __ACTIVE_AUDIO_SESSION.is_same_music(mus)) {
		vlog($"Play music ignored. Same music already playing.");
		return;
	}
		
	stop_music();
	run_delayed(GAMECONTROLLER, (AUDIO_MUSIC_CHANGE_OVERLAY ? 0 : ms_to_frames(AUDIO_MUSIC_DEFAULT_FADE_OUT_MS)),
		function(p) {
			__ACTIVE_AUDIO_SESSION.__music_private(
				p._mus,
				p._gain,
				p._fade_in_time_ms,
				p._loop,
				p._pitch,
				p._offset,
				p._listener_mask,
				p._priority,
				true);
		},
		{
			_mus 			 : mus,
			_gain			 : gain,
			_fade_in_time_ms : fade_in_time_ms,
			_loop			 : loop,
			_pitch			 : pitch,
			_offset		 	 : offset,
			_listener_mask	 : listener_mask,
			_priority		 : priority
		});
}

/// @func play_music_overlay(mus, gain = 1.0, fade_in_time_ms = 1000, pitch = 1.0, offset = 0, listener_mask = -1)
/// @desc Play the specified music sound as overlay together with the current music.
///				 This function will not modify, change or stop the current music. It just plays until the end, then stops.
function play_music_overlay(mus, 
							gain			= 1.0, 
							fade_in_time_ms = AUDIO_MUSIC_DEFAULT_FADE_IN_MS, 
							pitch			= AUDIO_MUSIC_DEFAULT_PITCH, 
							offset			= 0, 
							listener_mask	= AUDIO_MUSIC_DEFAULT_LISTENER_MASK) {
	__ACTIVE_AUDIO_SESSION.__music_private(
		mus,gain,fade_in_time_ms,false,pitch,offset,listener_mask,AUDIO_MUSIC_DEFAULT_PRIORITY,false);
}

/// @func		stop_music(fade_out_time_ms = 1000)
/// @desc	Stops the currently playing music
function stop_music(fade_out_time_ms = AUDIO_MUSIC_DEFAULT_FADE_OUT_MS) {
	if (__ACTIVE_AUDIO_SESSION.music_asset != undefined) {
		dlog($"Stopping music audio '{audio_get_name(__ACTIVE_AUDIO_SESSION.music_asset ?? -1)}' in {fade_out_time_ms}ms");
		__ACTIVE_AUDIO_SESSION.stop_active_music(fade_out_time_ms);
	}

}

/// @func		play_ambience(amb, gain = 1.0, fade_in_time_ms = 1000, loop = true, force_restart = false, pitch = 1.0, offset = 0, listener_mask = -1, priority = 8)
/// @desc	Plays a sound of type ambience (attached to ambience_volume setting)
function play_ambience( amb, 
						gain			= 1.0, 
						fade_in_time_ms = AUDIO_AMBIENCE_DEFAULT_FADE_IN_MS, 
						loop			= AUDIO_AMBIENCE_DEFAULT_LOOP, 
						force_restart	= false, 
						pitch			= AUDIO_AMBIENCE_DEFAULT_PITCH, 
						offset			= 0, 
						listener_mask	= AUDIO_AMBIENCE_DEFAULT_LISTENER_MASK, 
						priority		= AUDIO_AMBIENCE_DEFAULT_PRIORITY) {

	if (!force_restart && __ACTIVE_AUDIO_SESSION.is_same_ambience(amb)) {
		vlog($"Play ambience ignored. Same ambience already playing.");
		return;
	}
		
	stop_ambience();
	run_delayed(GAMECONTROLLER, (AUDIO_AMBIENCE_CHANGE_OVERLAY ? 0 : ms_to_frames(AUDIO_AMBIENCE_DEFAULT_FADE_OUT_MS)),
		function(p) {
			__ACTIVE_AUDIO_SESSION.__ambience_private(
				p._amb,
				p._gain,
				p._fade_in_time_ms,
				p._loop,
				p._pitch,
				p._offset,
				p._listener_mask,
				p._priority,
				true);
		},
		{
			_amb 			 : amb,
			_gain			 : gain,
			_fade_in_time_ms : fade_in_time_ms,
			_loop			 : loop,
			_pitch			 : pitch,
			_offset		 	 : offset,
			_listener_mask	 : listener_mask,
			_priority		 : priority
		});
	
}

/// @func play_ambience_overlay(amb, gain = 1.0, fade_in_time_ms = 1000, pitch = 1.0, offset = 0, listener_mask = -1)
/// @desc Play the specified ambience sound as overlay together with the current ambience.
///				 This function will not modify, change or stop the current ambience. It just plays until the end, then stops.
function play_ambience_overlay( amb, 
								gain			= 1.0, 
								fade_in_time_ms = AUDIO_AMBIENCE_DEFAULT_FADE_IN_MS, 
								pitch			= AUDIO_AMBIENCE_DEFAULT_PITCH, 
								offset			= 0, 
								listener_mask	= AUDIO_AMBIENCE_DEFAULT_LISTENER_MASK) {
	__ACTIVE_AUDIO_SESSION.__ambience_private(
		amb,gain,fade_in_time_ms,false,pitch,offset,listener_mask,AUDIO_AMBIENCE_DEFAULT_PRIORITY,false);
}

/// @func		stop_ambience(fade_out_time_ms = 1000)
/// @desc	Stops the currently playing ambience sounds
function stop_ambience(fade_out_time_ms = AUDIO_AMBIENCE_DEFAULT_FADE_OUT_MS) {
	if (__ACTIVE_AUDIO_SESSION.ambience_asset != undefined) {
		dlog($"Stopping ambience audio '{audio_get_name(__ACTIVE_AUDIO_SESSION.ambience_asset ?? -1)}' in {fade_out_time_ms}ms");
		__ACTIVE_AUDIO_SESSION.stop_active_ambience(fade_out_time_ms);
	}
}
