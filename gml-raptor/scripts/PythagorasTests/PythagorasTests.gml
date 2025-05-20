if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_Pythagoras() {
	if (!script_exists(asset_get_index("Pythagoras"))) {
		ilog($"Skipped unit tests for 'Pythagoras': Not in project.");
		return;
	}

	var ut = new UnitTest("Pythagoras");

	ut.tests.xy_ok_1		= function(test, data) {
		var x1 = 10, y1 = 10, x2 = 20, y2 = 20;
		var p = pyth_xy(x1, y1, x2, y2);
		test.assert_equals(45, p.alpha);
		test.assert_equals(45, p.beta);
	};

	ut.tests.xy_ok_q0		= function(test, data) {
		var x1 = 10, y1 = 10, x2 = 40, y2 = 25;
		var p = pyth_xy(x1, y1, x2, y2);
		test.assert_equals(90 - p.beta, p.alpha);
		test.assert_equals(p.angle, p.alpha);
	};

	ut.tests.xy_ok_q1		= function(test, data) {
		var x1 = 40, y1 = 10, x2 = 10, y2 = 25;
		var p = pyth_xy(x1, y1, x2, y2);
		test.assert_equals(90 - p.beta, p.alpha);
		test.assert_equals(p.angle, 180 - p.alpha);
	};

	ut.tests.xy_ok_q2		= function(test, data) {
		var x1 = 40, y1 = 25, x2 = 10, y2 = 10;
		var p = pyth_xy(x1, y1, x2, y2);
		test.assert_equals(90 - p.beta, p.alpha);
		test.assert_equals(p.angle, 180 + p.alpha);
	};

	ut.tests.xy_ok_q3		= function(test, data) {
		var x1 = 10, y1 = 25, x2 = 40, y2 = 10;
		var p = pyth_xy(x1, y1, x2, y2);
		test.assert_equals(90 - p.beta, p.alpha);
		test.assert_equals(p.angle, 360 - p.alpha);
	};

	ut.run();

}
