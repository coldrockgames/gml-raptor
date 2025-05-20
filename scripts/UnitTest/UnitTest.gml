/*
	Basic unit testing library for GML.
	Unit Testing is a very important step when coding libraries and classes.
	They are reproducible, stable environments that find side-effects and bugs after code changes.
	
	How unit testing works:
	You create a new UnitTest and now have 4 functions, that you can override (re-define):
	suite_start		- called once when you run() the tests.
	test_start		- called before each test. set up (and return) your test_data for each test of the suite in this function
	test_finish		- called after each test. use it to clean up, if necessary
	suite_finish	- called after the last test of the run(). use it to clean up, if necessary

	Alternatively, if you do not want (or need) to override test_start to create test_data, you can simply set .test_data
	to any struct you want, but keep in mind, that this is a reference type, so if your test modifies that data, the next
	test sees the modified version and not the original data.
	In doubt, it is always better to supply fresh generated test_data to EACH test.

	To add a test to the suite, you have 2 ways:
	1) simply set tests.name = func(...) {}
	2) call add_test(name, func)
	
	To run your unit tests simply call the run() method and watch the log.
	NOTE: To record your test in the suite, you MUST call one of the assert_*(...) methods to compare your values,
	otherwise the suite can not detect if a test failed or not!
	
	Long story short: Here is a short example, based on the java-standard test of 2+2, which uses no specific test_data.
	
	var math_test = new UnitTest("basic_math");
	math_test.add_test("add", function(test, data) { test.assert_equals(4, 2+2); });
	math_test.run();
	
	Produces this output:
	------------------------------------------------------------------------------------
	0: I <----- START TEST SUITE 'basic_math' ----->
	0: I  OK : add
	0: I DONE: TEST RESULTS 'basic_math': 1 tests, 1 succeeded, 0 failed
	------------------------------------------------------------------------------------
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT

*/

// Unit test room redirection
#macro unit_testing:ROOM_AFTER_STARTER				rmUnitTests
#macro unit_testing:STARTER_ASYNC_MIN_WAIT_TIME		1
#macro unit_testing:STARTER_FIRST_ROOM_FADE_IN		0

// Unit test automation

#macro __RUN_UNIT_TESTS					ilog("Unit tests disabled");
#macro unit_testing:__RUN_UNIT_TESTS	ilog("Running unit tests");	\
	global.__raptor_unit_tests = [];								\
	global.__raptor_unit_tests_total = 0;							\
	global.__raptor_unit_tests_total_ok = 0;						\
	global.__raptor_unit_tests_total_fail = 0;						\
	global.__raptor_unit_test_logger = new UnitTest().__log;		\
	global.__raptor_unit_test_scripts = [];							\
	var ids = asset_get_ids(asset_script);							\
	for (var i = 0, len = array_length(ids); i < len; i++) {		\
		var scr = script_get_name(ids[@i]);							\
		if (string_starts_with(scr, UNIT_TEST_FUNCTION_PREFIX))	{	\
			array_push(global.__raptor_unit_test_scripts, ids[@i]);	\
			ilog($"Discovered suite '{script_get_name(ids[@i])}'");	\
		}															\
	}																\
	ilog($"Discovered {array_length(global.__raptor_unit_test_scripts)} test suites total");	\
	global.__raptor_unit_test_next_suite_index = 0;					\
	global.__raptor_unit_test_next_suite = undefined;				\
	global.test = undefined;										\
	function __raptor_unit_test_suite_runner() {					\
		if (global.__raptor_unit_test_next_suite_index < array_length(global.__raptor_unit_test_scripts)) { \
			global.__raptor_unit_test_next_suite =					\
				global.__raptor_unit_test_scripts[@global.__raptor_unit_test_next_suite_index]; \
			global.__raptor_unit_test_next_suite();					\
		} else														\
			global.test = undefined;								\
		__raptor_unit_test_suite_checker();							\
	}																\
	function __raptor_unit_test_suite_checker() {					\
		if (global.test == undefined) {								\
			__raptor_unit_test_summary();							\
			return;													\
		}															\
		run_delayed(GAMESTARTER, 1, function() {					\
			if (global.test.__suite_finished) {						\
				global.__raptor_unit_test_next_suite_index++;		\
				__raptor_unit_test_suite_runner();					\
			} else {												\
				__raptor_unit_test_suite_checker();					\
			}														\
		});															\
	}																\
	function __raptor_unit_test_summary() {														\
		global.__raptor_unit_test_logger(2, "   TEST SUMMARY");									\
		global.__raptor_unit_test_logger(2, "   OK  FAIL  TEST SUITE ");						\
		global.__raptor_unit_test_logger(2, "---------------------------------------------");	\
		array_foreach(global.__raptor_unit_tests,												\
			function(it, ix) { global.__raptor_unit_test_logger(2, it); });						\
		global.__raptor_unit_test_logger(2, "---------------------------------------------");	\
		global.__raptor_unit_test_logger(2, $" {string_format(global.__raptor_unit_tests_total_ok, 4, 0)}  {string_format(global.__raptor_unit_tests_total_fail, 4, 0)}  {global.__raptor_unit_tests_total} total unit tests"); \
		global.__raptor_unit_tests = [];														\
		global.__raptor_unit_test_scripts = [];													\
		global.__raptor_unit_test_logger(2, "Unit tests finished");								\
	}																							\
	__raptor_unit_test_suite_runner();

if (!CONFIGURATION_UNIT_TESTING) exit;

/// @func	UnitTest(name = "UnitTest", _test_data = {})
/// @desc	Create a new unit test suite to perform a group of tests
function UnitTest(name = "UnitTest", _test_data = {}) constructor {

	global.test = self;
	
	__test_suite_name	= name;
	__suite_finished	= false;
	__current_test_ok	= true;
	__current_test_name = "";
	__current_test_msg	= "";
	__current_test_exc	= undefined;
	__fail_count		= 0;
	__next_test_index	= 0;
	__test_names		= [];
	__data_for_test		= {};
	__this				= self;
	
	tests = {};

	test_data = _test_data ?? {};

	/// @func __log(_type, _line)
	static __log = function(_type, _line) {
		if (string_starts_with(_line, "FAIL")) elog(_line); else ilog(_line);
		switch (_type) {
			case 0: with(UnitTestResultsViewer) report_log_line(_line); break;
			case 1: with(UnitTestResultsViewer) report_suite_line(_line); break;
			case 2: with(UnitTestResultsViewer) report_summary_line(_line); break;
		}
	}

	suite_start = function(data) {
	}
	
	suite_finish = function(data) {
	}
	
	test_start = function(current_test_name, data) {
		return data;
	}
	
	test_finish = function(current_test_name, data) {
	}

	#region ASSERTS
	static __assert_condition = function(condition, expected, actual, message) {
		__current_test_msg	= message;
		if (!condition) {
			__log(0, $"FAIL: {__current_test_name} *ASSERT*: expected='{expected}'; actual='{actual}'; message='{message}';");
			__current_test_ok	= false;
		}
		__current_test_msg = "";
	}
	
	/// @func fail(message = "")
	/// @desc fails the test immediately
	static fail = function(message = "") {
		__log(0, $"FAIL: {__current_test_name} *fail() reached*: message='{message}';");
		__current_test_ok = false;
	}
	
	/// @func success()
	static success = function() {
		__current_test_ok = true;
	}
	
	/// @func expect_exception(_error_message_contains = "")
	static expect_exception = function(_error_message_contains = "") {
		__current_test_exc = _error_message_contains;
	}
	
	/// @func	assert_equals(expected, actual, message = "")
	/// @desc	performs an equality value check. test fails, if "expected != actual"
	static assert_equals = function(expected, actual, message = "") {
		if (is_array(actual))
			__assert_condition(array_equals(expected, actual), expected, actual, message);
		else
			__assert_condition(expected == actual, expected, actual, message);
	}
	
	/// @func	assert_not_equals(expected, actual, message = "")
	/// @desc	performs an non-equality value check. test fails, if "expected == actual"
	static assert_not_equals = function(expected, actual, message = "") {
		if (is_array(actual))
			__assert_condition(!array_equals(expected, actual), expected, actual, message);
		else
			__assert_condition(expected != actual, expected, actual, message);
	}

	/// @func	assert_true(actual, message = "")
	/// @desc	performs a value check for true. test fails, if actual == false
	static assert_true = function(actual, message = "") {
		__assert_condition(actual, true, actual, message);
	}

	/// @func	assert_false(actual, message = "")
	/// @desc	performs a value check for false. test fails, if actual == true
	static assert_false = function(actual, message = "") {
		__assert_condition(!actual, false, actual, message);
	}
	
	/// @func	assert_null(actual, message = "")
	/// @desc	performs a value check against "undefined" and "noone". test fails, if actual is neither.
	static assert_null = function(actual, message = "") {
		__assert_condition(actual == undefined || actual == noone, true, actual, message);
	}
	
	/// @func	assert_not_null(actual, message = "")
	/// @desc	performs a value check against "undefined" and "noone". test fails, if actual is any of them.
	static assert_not_null = function(actual, message = "") {
		__assert_condition(actual != undefined && actual != noone, true, actual, message);
	}
	
	/// @func	assert_zero(actual, message = "")
	static assert_zero = function(actual, message = "") {
		__assert_condition(actual == 0, true, actual, message);
	}
	
	/// @func	assert_not_zero(actual, message = "")
	static assert_not_zero = function(actual, message = "") {
		__assert_condition(actual != 0, true, actual, message);
	}
	
	/// @func	assert_zero_or_greater(actual, message = "")
	static assert_zero_or_greater = function(actual, message = "") {
		__assert_condition(actual >= 0, true, actual, message);
	}

	/// @func	assert_zero_or_less(actual, message = "")
	static assert_zero_or_less = function(actual, message = "") {
		__assert_condition(actual <= 0, true, actual, message);
	}

	/// @func	assert_greater_than_zero(actual, message = "")
	static assert_greater_than_zero = function(actual, message = "") {
		__assert_condition(actual > 0, true, actual, message);
	}
	
	/// @func	assert_less_than_zero(actual, message = "")
	static assert_less_than_zero = function(actual, message = "") {
		__assert_condition(actual < 0, true, actual, message);
	}
	
	#endregion
	
	#region async
	__async_waiting		= false;
	__async_timeout		= 60;

	/// @func start_async(_timeout_frames = 60)
	/// @desc Tell the engine to wait for "finish_async" or a timeout
	static start_async = function(_timeout_frames = 60) {
		__async_waiting = true;
		__async_timeout = _timeout_frames;
	}

	/// @func finish_async()
	/// @desc Tell the engine, that the async operation is complete
	static finish_async = function() {
		__async_waiting = false;
		animation_abort(GAMESTARTER, "test_loop");
	}
	#endregion
	
	/// @func					add_test(name, func)
	/// @desc				add a unit test. alternatively you can simply set tests.name = func;
	///								a test function receives one argument, the test_data. This is the struct
	///								you set up in the test_start function.
	static add_test = function(name, func) {
		struct_set(tests, name, func);
	}

	/// @func					run()
	/// @desc				runs all tests and prints the results to the log
	static run = function() {
		__log(0, $"<----- START TEST SUITE '{__test_suite_name}' ----->");
		// ---- SUITE START ----
		try {
			__suite_finished = false;
			suite_start(test_data);
		} catch (_ex) {
			__log(0, $"FAIL: suite_start threw '{_ex.message}'");
			return;
		}
		
		__test_names		= struct_get_names(tests);
		array_sort(__test_names, true);
		
		__fail_count		= 0;
		__next_test_index	= 0;
		__prepare_next_test();		
	}

	static __prepare_next_test = function() {
		if (__async_waiting) {
			dlog($"Unit Test must wait for next test to finish async tasks");
			return;
		}
		
		call_later(1, time_source_units_frames, function() {
			if (__next_test_index < array_length(__test_names)) {
				__current_test_name = __test_names[__next_test_index];
				__current_test_ok	= true;
				__current_test_exc	= undefined;
				__current_test_msg	= "";
				__async_waiting		= false;
				__data_for_test		= {};
			
				__start_test();
				__check_test_completed();
			} else
				__finish_test_suite();
		}, false);
	}

	static __start_test = function() {
		var new_data;
		__data_for_test = test_data;
			
		// ---- TEST START ----
		try {
			new_data = test_start(__current_test_name, test_data);
			if (is_struct(new_data))
				__data_for_test = new_data;
		} catch (_ex) {
			var exm = string_replace_all(is_string(_ex) ? _ex : _ex.longMessage, "[", "[[");
			__log(0, $"FAIL: test_start of '{__current_test_name}' threw '{exm}'");
			__current_test_ok = false;
		}
			
		// ---- TEST RUN ----
		if (__current_test_ok) {
			try {
				struct_get(tests, __current_test_name)(self, __data_for_test);
			} catch (_ex) {
				var exm = string_replace_all(is_string(_ex) ? _ex : _ex.longMessage,"[","[[");
				if (__current_test_exc == undefined ||
						(!string_is_empty(__current_test_exc) && !string_contains(exm, __current_test_exc) &&
							(!IS_HTML || string_contains(exm, "undefined to a number"))
						)
					) {
					__log(0, $"FAIL: {__current_test_name} exception='{exm}'; msg='{__current_test_msg}'");
					__current_test_ok = false;
				}
			}
		}
	}
	
	static __check_test_completed = function() {
		// ---- WAIT FOR ASYNC COMPLETION ----
		if (__async_waiting) {
			run_delayed(GAMESTARTER, 1, function(t) {
				with(t) {
					if (__async_waiting) {
						__async_timeout--;
						if (__async_timeout <= 0) {
							__async_waiting = false;
							__current_test_ok = false;
							__log(0, $"FAIL: async timeout reached in '{__current_test_name}'");
						}
					}
					__check_test_completed();
				}
			}, __this).set_name("test_loop");
			return;
		}
		
		// ---- TEST FINISH ----
		try {
			test_finish(__current_test_name, __data_for_test);
		} catch (_ex) {
			var exm = string_replace_all(is_string(_ex) ? _ex : _ex.longMessage,"[","[[");
			__log(0, $"FAIL: test_finish of '{__current_test_name}' threw '{exm}'");
			__current_test_ok = false;
		}
		
		if (__current_test_ok) {
			__log(0, $" OK : {__current_test_name}");
		} else {
			__fail_count++;
		}
		
		__next_test_index++;
		__prepare_next_test();		
	}

	static __finish_test_suite = function() {
		// ---- SUITE FINISH ----
		try {
			suite_finish(test_data);
		} catch (_ex) {
			__log(0, $"FAIL: suite_finish threw '{_ex.message}'");
		}
		
		var total = array_length(__test_names);
		__log(1, $"DONE: {string_format(total, 4, 0)} tests, {string_format((total - __fail_count), 4, 0)} succeeded, {string_format(__fail_count, 4, 0)} failed in '{__test_suite_name}'");
		
		array_push(global.__raptor_unit_tests,
			$" {string_format(total - __fail_count, 4, 0)}  {string_format(__fail_count, 4, 0)}  {__test_suite_name}"
		);
		global.__raptor_unit_tests_total += total;
		global.__raptor_unit_tests_total_ok += (total - __fail_count);
		global.__raptor_unit_tests_total_fail += __fail_count;
		__suite_finished = true;
	}

}

