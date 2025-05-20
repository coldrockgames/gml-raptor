/*
    Holds the macros for default audio behavior of raptor.
	
	The ROOMCONTROLLER automatically starts ambience and music themes, when a room
	gets entered, and these macros define the behavior of those actions, as well as
	the default values for all optional arguments of the audio functions.
	
	About AUDIO_MUSIC_CHANGE_OVERLAY and AUDIO_AMBIENCE_CHANGE_OVERLAY
	------------------------------------------------------------------
	Those two macro define, what shall happen, when you change the music or ambience.
	If you set overlay to true (default), then the fade_out of the old audio and the fade_in of the
	new audio will happen AT THE SAME TIME (softly overlaying each other).
	If you set overlay to false, the fade_out is performed first, until silence, and afterwards
	the fade_in of the new sound starts.
	Most of the time you get a way better and more immersive audio experience, when you overlay them.
*/

// --- STREAMING CHANNELS ---

// MUSIC Defaults
#macro AUDIO_MUSIC_CHANGE_OVERLAY				 true
#macro AUDIO_MUSIC_DEFAULT_FADE_IN_MS			 1000
#macro AUDIO_MUSIC_DEFAULT_FADE_OUT_MS			 1000
#macro AUDIO_MUSIC_DEFAULT_LOOP					 true
#macro AUDIO_MUSIC_DEFAULT_PITCH				 1.0
#macro AUDIO_MUSIC_DEFAULT_LISTENER_MASK		-1
#macro AUDIO_MUSIC_DEFAULT_PRIORITY				 9

// AMBIENCE Defaults
#macro AUDIO_AMBIENCE_CHANGE_OVERLAY			 true
#macro AUDIO_AMBIENCE_DEFAULT_FADE_IN_MS		 1000
#macro AUDIO_AMBIENCE_DEFAULT_FADE_OUT_MS		 1000
#macro AUDIO_AMBIENCE_DEFAULT_LOOP				 true
#macro AUDIO_AMBIENCE_DEFAULT_PITCH				 1.0
#macro AUDIO_AMBIENCE_DEFAULT_LISTENER_MASK		-1
#macro AUDIO_AMBIENCE_DEFAULT_PRIORITY			 8

// ---  INSTANT CHANNELS  ---

// SOUND Defaults
#macro AUDIO_SOUND_DEFAULT_PITCH				 1.0
#macro AUDIO_SOUND_DEFAULT_LISTENER_MASK		-1
#macro AUDIO_SOUND_DEFAULT_PRIORITY				 10

// VOICE Defaults
#macro AUDIO_VOICE_DEFAULT_PITCH				 1.0
#macro AUDIO_VOICE_DEFAULT_LISTENER_MASK		-1
#macro AUDIO_VOICE_DEFAULT_PRIORITY				 10

// UI-SOUND Defaults
#macro AUDIO_UI_DEFAULT_PITCH					 1.0
#macro AUDIO_UI_DEFAULT_LISTENER_MASK			-1
#macro AUDIO_UI_DEFAULT_PRIORITY				 7
