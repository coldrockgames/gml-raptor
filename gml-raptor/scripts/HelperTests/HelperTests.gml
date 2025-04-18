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
		
		// invalid init name is null
		test.assert_null(extract_init(str, false, "helloworld"), "null");
		
		test.assert_equals(i, extract_init(str), "2");
		test.assert_equals(i, extract_init(str, true), "3");
		// now init must have been gone
		test.assert_false(struct_exists(str, "init"), "4");
	}
 
	ut.tests.asset_from_to_string_ok = function(test, data) {
		test.assert_equals(UnitTest,	asset_from_string("UnitTest"),			"01");	// script
		test.assert_equals(_raptorBase, asset_from_string("_raptorBase"),		"02");	// object
		test.assert_equals(rmUnitTests, asset_from_string("rmUnitTests"),		"03");	// room
		test.assert_equals(spr1pxTrans, asset_from_string("spr1pxTrans"),		"04");	// sprite
		test.assert_equals(-1, asset_from_string("some_non_existing_class"),	"05");	// invalid
		
		test.assert_equals("UnitTest"   , asset_to_string(UnitTest),			"11");	// script
		test.assert_equals("_raptorBase", asset_to_string(_raptorBase),			"12");	// object
		test.assert_equals("rmUnitTests", asset_to_string(rmUnitTests),			"13");	// room
		test.assert_equals("spr1pxTrans", asset_to_string(spr1pxTrans),			"14");	// sprite
		test.assert_equals("fntUnitTest", asset_to_string(fntUnitTest),			"15");	// font
		test.assert_equals("DisabledShader", asset_to_string(DisabledShader),	"16");	// shader
		test.assert_equals("string"		,asset_to_string("string"),			"17");	// invalid
	}

	ut.tests.color_from_to_json_ok = function(test, data) {
		var wrong_array = [1,2];
		var wrong_val	= "HelloWorld";
		
		test.assert_equals(wrong_array, color_from_array(wrong_array), "1");
		test.assert_equals(wrong_val,	color_from_array(wrong_val)	, "2");
		
		var good_array	= [10,20,30];
		var good_col	= color_from_array(good_array);
		test.assert_equals(10, color_get_red	(good_col), "3");
		test.assert_equals(20, color_get_green	(good_col), "4");
		test.assert_equals(30, color_get_blue	(good_col), "5");
		
		var arr = color_to_array(c_red);
		test.assert_true(is_array(arr), "6");
		test.assert_equals(3, array_length(arr), "7");
		test.assert_equals(255, arr[0], "8");
		test.assert_equals(0, arr[1], "9");
		test.assert_equals(0, arr[2], "10");
	}

	ut.tests.color_from_hexcode_ok = function(test, data) {
		var red  = color_from_hexcode("#FF0000");
		var blue = color_from_hexcode("$FF0000");
		
		test.assert_equals(make_color_rgb(255, 0, 0), red, "red");
		test.assert_equals(make_color_bgr(255, 0, 0), blue, "blue");
	}

	ut.tests.make_color_bgr_ok = function(test, data) {
		var blue_rgb = make_color_rgb(0, 0, 255);
		
		var blue_bgr = make_color_bgr(255, 0, 0);
		
		test.assert_equals(blue_rgb, blue_bgr, "blue");
	}

	ut.run();
}
