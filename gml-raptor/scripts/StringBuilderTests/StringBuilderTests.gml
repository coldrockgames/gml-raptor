if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_StringBuilder() {
	if (!script_exists(asset_get_index("StringBuilder"))) {
		ilog($"Skipped unit tests for 'StringBuilder': Not in project.");
		return;
	}

	var ut = new UnitTest("StringBuilder");

	ut.test_start = function(name, data) {
		data.t = new StringBuilder();
	}

	ut.test_finish = function(name, data) {
		data.t.clear();
	}
	
	ut.tests.empty_ok = function(test, data) {
		test.assert_equals(0, data.t.length(), "empty");
		test.assert_equals("", data.t.toString());
	};

	ut.tests.clear_ok = function(test, data) {
		if (IS_HTML) return; // this is because the raised exception here is one
							 // caught by the unit test engine "undefined to a number"
		data.t.clear();
		test.assert_null(data.t._buffer, "buffer is null");
		test.expect_exception("buffer");
		data.t.append(".");
		test.fail(); // must crash, as _buffer should be undefined
	};

	ut.tests.append_ok = function(test, data) {
		data.t.append("Hello");
		test.assert_equals("Hello", data.t.toString());
	}

	ut.tests.append_word_ok = function(test, data) {
		data.t.append("Hello").append_word("World");
		test.assert_equals("Hello World", data.t.toString());
	}

	ut.tests.append_line_ok = function(test, data) {
		data.t.append_line("Hello").append("World");
		test.assert_equals("Hello\nWorld", data.t.toString());
	}

	ut.tests.cursor_ok = function(test, data) {
		data.t.append("Hello").append_word("World");
		test.assert_equals("Hello World", data.t.toString(false));
		data.t.set_position(6).append("Grisgram");
		test.assert_equals("Hello Grisgram", data.t.toString());
	}

	ut.run();
}
