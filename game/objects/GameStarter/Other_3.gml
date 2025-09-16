/// @desc destroy all

mlog($"Invoking onGameEnd()");
onGameEnd();
save_settings();
RAPTOR_LOGGER.shutdown();
