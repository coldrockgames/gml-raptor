if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_Interface() {
	if (!script_exists(asset_get_index("implement"))) {
		ilog($"Skipped unit tests for 'Interface': Not in project.");
		return;
	}

	var ut = new UnitTest("Interface");

	ut.tests.implement_coord2_ok = function(test, data) {
		var empty = {};
		with (empty) implement("Coord2");
		test.assert_true(implements(empty, "Coord2"), "implement");
		test.assert_equals(empty.toString(), "0/0", "tostring");
	};

	ut.tests.implement_multiple_ok = function(test, data) {
		var empty = {};
		with (empty) {
			implement("Coord2");
			implement("Coord3");
		}
		
		test.assert_true(implements(empty, "Coord2"), "implement");
		test.assert_true(implements(empty, "Coord3"), "implement");
		empty.z = 1;
		test.assert_equals(empty.toString(), "0/0/1", "tostring");
	};

	ut.tests.inherit_direct_ok = function(test, data) {
		var base = function() constructor {
			construct("base");
		}
		
		var b = new base();
		
		test.assert_true(is_class_of(b, "base"));
		test.assert_true(is_child_class_of(b, "base"));
	}

	ut.run();
}
