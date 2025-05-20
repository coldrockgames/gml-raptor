if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_Highscorer() {
	if (!script_exists(asset_get_index("HighScoreTable"))) {
		ilog($"Skipped unit tests for 'Highscorer': Not in project.");
		return;
	}
	
	var ut = new UnitTest("Highscorer");

	ut.tests.table_add_ok = function(test, data) {
		var hs = new HighScoreTable("Highscores", 3, scoring.score_high);
		test.assert_equals(0, hs.size());
		
		hs.register_highscore("1",10,100,1000);
		test.assert_equals(1, hs.size());
		
		hs.register_highscore("2",20,200,2000);
		test.assert_equals(2, hs.size());
		
		hs.register_highscore("3",30,300,3000);
		test.assert_equals(3, hs.size());
		
		hs.register_highscore("4",40,400,4000);
		test.assert_equals(3, hs.size()); // still 3 entries!
		
		hs.reset();
		test.assert_equals(0, hs.size());
	}

	ut.tests.table_score_high_get_rank_ok = function(test, data) {
		var hs = new HighScoreTable("Highscores", 3, scoring.score_high);
		hs.register_highscore("1",10,100,1000);
		hs.register_highscore("2",20,200,2000);
		hs.register_highscore("3",30,300,3000);
		test.assert_equals(1, hs.get_highscore_rank(35), "rank 1");
		test.assert_equals(2, hs.get_highscore_rank(25), "rank 2");
		test.assert_equals(3, hs.get_highscore_rank(15), "rank 3");
		test.assert_equals(-1, hs.get_highscore_rank(5), "rank -1");
	}

	ut.tests.table_score_low_get_rank_ok = function(test, data) {
		var hs = new HighScoreTable("Highscores", 3, scoring.score_low);
		hs.register_highscore("1",10,100,1000);
		hs.register_highscore("2",20,200,2000);
		hs.register_highscore("3",30,300,3000);
		test.assert_equals(-1, hs.get_highscore_rank(35), "rank -1");
		test.assert_equals(3, hs.get_highscore_rank(25), "rank 3");
		test.assert_equals(2, hs.get_highscore_rank(15), "rank 2");
		test.assert_equals(1, hs.get_highscore_rank(5), "rank 1");
	}

	ut.tests.table_time_low_get_rank_ok = function(test, data) {
		var hs = new HighScoreTable("Highscores", 3, scoring.time_low);
		hs.register_highscore("1",10,100,1000);
		hs.register_highscore("2",20,200,2000);
		hs.register_highscore("3",30,300,3000);
		test.assert_equals(-1, hs.get_highscore_rank(350), "rank -1");
		test.assert_equals(3, hs.get_highscore_rank(250), "rank 3");
		test.assert_equals(2, hs.get_highscore_rank(150), "rank 2");
		test.assert_equals(1, hs.get_highscore_rank(50), "rank 1");
	}

	ut.tests.table_time_high_get_rank_ok = function(test, data) {
		var hs = new HighScoreTable("Highscores", 3, scoring.time_high);
		hs.register_highscore("1",10,100,1000);
		hs.register_highscore("2",20,200,2000);
		hs.register_highscore("3",30,300,3000);
		test.assert_equals(1, hs.get_highscore_rank(350), "rank 1");
		test.assert_equals(2, hs.get_highscore_rank(250), "rank 2");
		test.assert_equals(3, hs.get_highscore_rank(150), "rank 3");
		test.assert_equals(-1, hs.get_highscore_rank(50), "rank -1");
	}

	ut.tests.table_lists_ok = function(test, data) {
		var hs = new HighScoreTable("Highscores", 3, scoring.score_low);
		hs.register_highscore("1",10,100,1000);
		hs.register_highscore("2",20,200,2000);
		hs.register_highscore("3",30,300,3000);
		test.assert_equals("#1\n#2\n#3", hs.get_rank_list(), "ranks");
		test.assert_equals("1\n2\n3", hs.get_name_list(), "names");
		test.assert_equals("10\n20\n30", hs.get_score_list(), "scores");
		test.assert_equals("00:00.100\n00:00.200\n00:00.300", hs.get_time_list(), "times");
	}

	ut.run();
}
