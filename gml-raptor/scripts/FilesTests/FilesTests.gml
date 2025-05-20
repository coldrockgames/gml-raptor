if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_Files() {
	if (!script_exists(asset_get_index("file_read_text_file_absolute")) ||
		!script_exists(asset_get_index("file_read_text_file_absolute_async"))) {
		ilog($"Skipped unit tests for 'Files': Not in project.");
		return;
	}

	var ut = new UnitTest("Files");

	#region SYNC access
	ut.tests.file_text_plain_ok = function(test, data) {
		var testfile = "unit_test/test_enc.jx";
		var testkey = "";
		var testcontent = "This\nFile\nContains\n4 lines";
		
		var writeres = file_write_text_file(testfile, testcontent, testkey);
		test.assert_true(writeres, "save enc file");
		var content = file_read_text_file(testfile, testkey);
		test.assert_not_null(content, "file content");
		test.assert_true(string_contains(content, "Contains"), "file contains");
	}
	
	ut.tests.file_text_plain_lines_ok = function(test, data) {
		var testfile = "unit_test/test_enc.jx";
		var testkey = "";
		var testcontent = ["This","File","Contains","4 lines"];
		
		var writeres = file_write_text_file_lines(testfile, testcontent, testkey);
		test.assert_true(writeres, "save enc file");
		var content = file_read_text_file_lines(testfile, testkey);
		test.assert_not_null(content, "file content");
		test.assert_equals(4, array_length(content), "file array");
		test.assert_true(array_contains(content, "Contains"), "file contains");		
	}

	ut.tests.file_struct_plain_ok = function(test, data) {
		var testfile = "unit_test/test_enc.jx";
		var testkey = "";
		var testcontent = {
			"first": "This",
			"second": "File",
			"third": "Contains",
			"fourth": "4 Members"
		};
		
		var writeres = file_write_struct(testfile, testcontent, testkey);
		test.assert_true(writeres, "save enc file");
		var content = file_read_struct(testfile, testkey);
		test.assert_not_null(content, "file content");
		test.assert_equals(4, array_length(struct_get_names(content)), "file contains");
		test.assert_equals(content.third, "Contains", "file contains");		
	}

	ut.tests.file_text_encrypted_ok = function(test, data) {
		var testfile = "unit_test/test_enc.jx";
		var testkey = "cryptkey$.some.key";
		var testcontent = "This\nFile\nContains\n4 lines";
		
		var writeres = file_write_text_file(testfile, testcontent, testkey);
		test.assert_true(writeres, "save enc file");
		var content = file_read_text_file(testfile, testkey);
		test.assert_not_null(content, "file content");
		test.assert_true(string_contains(content, "Contains"), "file contains");
	}
	
	ut.tests.file_text_encrypted_lines_ok = function(test, data) {
		var testfile = "unit_test/test_enc.jx";
		var testkey = "cryptkey$.some.key";
		var testcontent = ["This","File","Contains","4 lines"];
		
		var writeres = file_write_text_file_lines(testfile, testcontent, testkey);
		test.assert_true(writeres, "save enc file");
		var content = file_read_text_file_lines(testfile, testkey);
		test.assert_not_null(content, "file content");
		test.assert_equals(4, array_length(content), "file array");
		test.assert_true(array_contains(content, "Contains"), "file contains");		
	}

	ut.tests.file_struct_encrypted_ok = function(test, data) {
		var testfile = "unit_test/test_enc.jx";
		var testkey = "cryptkey$.some.key";
		var testcontent = {
			"first": "This",
			"second": "File",
			"third": "Contains",
			"fourth": "4 Members"
		};
		
		var writeres = file_write_struct(testfile, testcontent, testkey);
		test.assert_true(writeres, "save enc file");
		var content = file_read_struct(testfile, testkey);
		test.assert_not_null(content, "file content");
		test.assert_equals(4, array_length(struct_get_names(content)), "file contains");
		test.assert_equals(content.third, "Contains", "file contains");		
	}
	#endregion

	#region ASYNC access
	ut.tests.file_text_plain_async_ok = function(test, data) {
		test.start_async();
		var testfile = "unit_test/test_enc.jx";
		var testkey = "";
		var testcontent = "This\nFile\nContains\n4 lines";
		
		file_write_text_file_async(testfile, testcontent, testkey)
		.on_finished(function(res) {
			global.test.assert_true(res, "save enc file");
			var content = file_read_text_file_async("unit_test/test_enc.jx", "")
			.on_finished(function(content) {
				global.test.assert_not_null(content, "file content");
				global.test.assert_true(string_contains(content, "Contains"), "file contains");
				global.test.finish_async();
			});
		});
	}
	
	ut.tests.file_text_plain_lines_async_ok = function(test, data) {
		test.start_async();
		var testfile = "unit_test/test_enc.jx";
		var testkey = "";
		var testcontent = ["This","File","Contains","4 lines"];

		file_write_text_file_lines_async(testfile, testcontent, testkey)
		.on_finished(function(res) {
			global.test.assert_true(res, "save enc file");
			var content = file_read_text_file_lines_async("unit_test/test_enc.jx", "")
			.on_finished(function(content) {
				global.test.assert_not_null(content, "file content");
				global.test.assert_equals(4, array_length(content), "file array");
				global.test.assert_true(array_contains(content, "Contains"), "file contains");		
				global.test.finish_async();
			});
		});		
	}

	ut.tests.file_struct_plain_async_ok = function(test, data) {
		test.start_async();
		var testfile = "unit_test/test_enc.jx";
		var testkey = "";
		var testcontent = {
			"first": "This",
			"second": "File",
			"third": "Contains",
			"fourth": "4 Members"
		};

		file_write_struct_async(testfile, testcontent, testkey)
		.on_finished(function(res) {
			global.test.assert_true(res, "save enc file");
			var content = file_read_struct_async("unit_test/test_enc.jx", "")
			.on_finished(function(content) {
				global.test.assert_not_null(content, "file content");
				global.test.assert_equals(4, array_length(struct_get_names(content)), "content length");
				global.test.assert_equals(content.third, "Contains", "file contains");		
				global.test.finish_async();
			});
		});		
	}

	ut.tests.file_text_encrypted_async_ok = function(test, data) {
		test.start_async();
		var testfile = "unit_test/test_enc.jx";
		var testkey = "cryptkey$.some.key";
		var testcontent = "This\nFile\nContains\n4 lines";
		
		file_write_text_file_async(testfile, testcontent, testkey)
		.on_finished(function(res) {
			global.test.assert_true(res, "save enc file");
			var content = file_read_text_file_async("unit_test/test_enc.jx", "cryptkey$.some.key")
			.on_finished(function(content) {
				global.test.assert_not_null(content, "file content");
				global.test.assert_true(string_contains(content, "Contains"), "file contains");
				global.test.finish_async();
			});
		});
	}
	
	ut.tests.file_text_encrypted_lines_async_ok = function(test, data) {
		test.start_async();
		var testfile = "unit_test/test_enc.jx";
		var testkey = "cryptkey$.some.key";
		var testcontent = ["This","File","Contains","4 lines"];

		file_write_text_file_lines_async(testfile, testcontent, testkey)
		.on_finished(function(res) {
			global.test.assert_true(res, "save enc file");
			var content = file_read_text_file_lines_async("unit_test/test_enc.jx", "cryptkey$.some.key")
			.on_finished(function(content) {
				global.test.assert_not_null(content, "file content");
				global.test.assert_equals(4, array_length(content), "file array");
				global.test.assert_true(array_contains(content, "Contains"), "file contains");		
				global.test.finish_async();
			});
		});		
	}

	ut.tests.file_struct_encrypted_async_ok = function(test, data) {
		test.start_async();
		var testfile = "unit_test/test_enc.jx";
		var testkey = "cryptkey$.some.key";
		var testcontent = {
			"first": "This",
			"second": "File",
			"third": "Contains",
			"fourth": "4 Members"
		};

		file_write_struct_async(testfile, testcontent, testkey)
		.on_finished(function(res) {
			global.test.assert_true(res, "save enc file");
			var content = file_read_struct_async("unit_test/test_enc.jx", "cryptkey$.some.key")
			.on_finished(function(content) {
				global.test.assert_not_null(content, "file content");
				global.test.assert_equals(4, array_length(struct_get_names(content)), "content length");
				global.test.assert_equals(content.third, "Contains", "file contains");		
				global.test.finish_async();
			});
		});		
	}

	ut.tests.file_multiple_callbacks_async_ok = function(test, data) {
		test.start_async(300);
		var testfile = "unit_test/test_enc.jx";
		var testkey = "cryptkey$.some.key";
		var testcontent = { "hello": "world" };

		test.test_data.w_callback_count = 0;
		test.test_data.r_callback_count = 0;

		file_write_struct_async(testfile, testcontent, testkey)
		.on_finished(function(res) {
			global.test.assert_true(res, "save enc file");
			global.test.test_data.w_callback_count++;

			var content = file_read_struct_async("unit_test/test_enc.jx", "cryptkey$.some.key")
			.on_finished(function(content) {
				global.test.test_data.r_callback_count++;
			})
			.on_finished(function(res) {
				global.test.test_data.r_callback_count++;
			})
			.on_finished(function(res) {
				global.test.test_data.r_callback_count++;
				global.test.assert_equals(3, global.test.test_data.r_callback_count, "read callbacks");
				run_delayed(ROOMCONTROLLER, 30, function() {
					global.test.finish_async();
				});
			});
		})
		.on_finished(function(res) {
			global.test.test_data.w_callback_count++;
		})
		.on_finished(function(res) {
			global.test.test_data.w_callback_count++;
			global.test.assert_equals(3, global.test.test_data.w_callback_count, "write callbacks");
		});
	}

	#endregion
	
	ut.tests.file_get_filename_ok = function(test, data) {
		test.assert_equals("file.txt", file_get_filename("c:\\work\\some\\file.txt", true ), "backslash+");
		test.assert_equals("file",     file_get_filename("c:\\work\\some\\file.txt", false), "backslash-");
		test.assert_equals("file.txt", file_get_filename("c:/work/some/file.txt", true ),    "slash+");
		test.assert_equals("file",     file_get_filename("c:/work/some/file.txt", false),    "slash-");
	}
	
	ut.run();
}
