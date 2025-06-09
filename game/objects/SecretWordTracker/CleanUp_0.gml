/// @description remove tracker
event_inherited();

if (eq(self, SECRET_WORD_TRACKER))
	SECRET_WORD_TRACKER = undefined;
	