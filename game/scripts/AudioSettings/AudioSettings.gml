/*
    This class holds the common basic audio settings.
	Derive if you need more and put this struct in the
	save code of your settings file.
*/

#macro AUDIOSETTINGS		global.__audiosettings
AUDIOSETTINGS				= new AudioSettings();

#macro ALL_AUDIOSETTINGS_DEFAULT	(AUDIOSETTINGS.music_enabled && AUDIOSETTINGS.sound_enabled && AUDIOSETTINGS.ambience_enabled && \
									 AUDIOSETTINGS.master_volume == 1.0 && AUDIOSETTINGS.sound_volume == 1.0 && AUDIOSETTINGS.music_volume == 1.0 && \
									 AUDIOSETTINGS.ui_volume == 1.0 && AUDIOSETTINGS.ambience_volume == 1.0 && AUDIOSETTINGS.voice_volume == 1.0)

enum audio_type {
	ui, sound, music, ambience, voice
}

function AudioSettings() constructor {
	construct(AudioSettings);
	
	music_enabled		= true;
	ui_enabled			= true;
	sound_enabled		= true;
	voice_enabled		= true;
	ambience_enabled	= true;
	
	master_volume		= 1.0;
	sound_volume		= 1.0;
	music_volume		= 1.0;
	ui_volume			= 1.0;
	ambience_volume		= 1.0;
	voice_volume		= 1.0;
}