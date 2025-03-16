if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_little_helpers() {
 
	var ut = new UnitTest("LittleHelpers");
 
	ut.tests.bit_operations_enum_ok = function(test, data) {		
		var t = 0;
		t = bit_set_enum(t, bits_enum.b3, true);	test.assert_equals(t, bits_enum.b3, "b3 set");
		t = bit_set_enum(t, bits_enum.b2, true);	test.assert_equals(t, bits_enum.b3 | bits_enum.b2, "b2 set");
		t = bit_set_enum(t, bits_enum.b3, false);	test.assert_equals(t, bits_enum.b2, "b2 check");
		
		test.assert_true (bit_get_enum(t, bits_enum.b2), "b2 get");
		test.assert_false(bit_get_enum(t, bits_enum.b3), "b2 get");
	}
 
	ut.tests.bit_operations_variable_ok = function(test, data) {
		var t = 0;
		t = bit_set(t, 3, true);	test.assert_equals(t, bits_enum.b3, "b3 set");
		t = bit_set(t, 2, true);	test.assert_equals(t, bits_enum.b3 | bits_enum.b2, "b2 set");
		t = bit_set(t, 3, false);	test.assert_equals(t, bits_enum.b2, "b2 check");
		
		test.assert_true (bit_get(t, 2), "b2 get");
		test.assert_false(bit_get(t, 3), "b2 get");		
	}
 
	ut.tests.extract_init_ok = function(test, data) {
		var str = {
			a: 1
		};
		
		test.assert_null(extract_init(str), "1");
		
		str.init = {
			b: 2
		}
		var i = str.init;
		
		test.assert_equals(i, extract_init(str), "2");
		test.assert_equals(i, extract_init(str, true), "3");
		// now init must have been gone
		test.assert_false(struct_exists(str, "init"), "4");
	}
 
	ut.run();
}
