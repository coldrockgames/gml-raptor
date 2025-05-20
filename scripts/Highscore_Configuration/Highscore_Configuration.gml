/*
    Highscore setup for the game
*/

#macro USE_HIGHSCORES				false
#macro HIGHSCORE_TABLE_NAME			"Highscores"
#macro HIGHSCORE_TABLE_LENGTH		10
#macro HIGHSCORE_TABLE_SCORING		scoring.score_high
#macro HIGHSCORES					global.__highscores
#macro HIGHSCORES_UI_LAYER			"ui_highscores"

if (USE_HIGHSCORES) {
	HIGHSCORES = new HighScoreTable(HIGHSCORE_TABLE_NAME, HIGHSCORE_TABLE_LENGTH, HIGHSCORE_TABLE_SCORING);
	repeat (HIGHSCORE_TABLE_LENGTH) HIGHSCORES.register_highscore("- no entry -",0);
} else {
	HIGHSCORES = undefined;
}
