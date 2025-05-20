if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_LinqArray() {
	if (!script_exists(asset_get_index("LinqArray"))) {
		ilog($"Skipped unit tests for 'LingArray': Not in project.");
		return;
	}

	var ut = new UnitTest("LinqArray");

	ut.test_start = function(name) {
		if (string_ends_with(name, "_complex")) 
			return {
				ar  : LinqArray_create_from([{txt:"a",age:10},{txt:"b",age:20},{txt:"c",age:30},{txt:"d",age:40},{txt:"e",age:50}]),
				ar2 : LinqArray_create_from([{txt:"d",age:40},{txt:"e",age:50},{txt:"f",age:60},{txt:"g",age:70},{txt:"h",age:80}]),
				ar3 : LinqArray_create_from([{txt:"a",age:10},{txt:"a",age:10},{txt:"a",age:10},{txt:"b",age:20},{txt:"b",age:20},{txt:"c",age:30}]),
			};
		else
			return {
				ar  : LinqArray_create_from([1,2,3,4,5]),
				ar2 : LinqArray_create_from([4,5,6,7,8]),
				ar3 : LinqArray_create_from([1,1,1,2,2,3]),
			};
	}

	ut.tests.length			= function(test, data) { test.assert_equals(5, data.ar.length()); }
	ut.tests.reverse		= function(test, data) { test.assert_equals([5,4,3,2,1], data.ar.reverse().array); }
	ut.tests.index_in_range = function(test, data) { test.assert_equals(2, data.ar.get_index_in_range(7)); }
	ut.tests.clear			= function(test, data) { test.assert_equals([0,0,0,0,0], data.ar.clear(0).array); }
	ut.tests.intersect		= function(test, data) { test.assert_equals([4,5], data.ar.intersect(data.ar2).array); }
	ut.tests.union			= function(test, data) { test.assert_equals([1,2,3,4,5,6,7,8], data.ar.union(data.ar2).array); }
	ut.tests.minus			= function(test, data) { test.assert_equals([1,2,3], data.ar.minus(data.ar2).array); }
	ut.tests.insert			= function(test, data) { test.assert_equals([1,2,3,9,10,4,5], data.ar.insert(3,9,10).array); }
	ut.tests.remove			= function(test, data) { test.assert_equals([1,5], data.ar.remove(1,3).array); }
	ut.tests.distinct		= function(test, data) { test.assert_equals([1,2,3], data.ar3.distinct().array); }
	ut.tests.tmin			= function(test, data) { test.assert_equals(1, data.ar.minval()); }
	ut.tests.tmax			= function(test, data) { test.assert_equals(5, data.ar.maxval()); }
	ut.tests.tmax			= function(test, data) { test.assert_equals(3, data.ar.avg()); }
	ut.tests.sum			= function(test, data) { test.assert_equals(15, data.ar.sum()); }

	ut.tests.tmin_complex	= function(test, data) { test.assert_equals(10, data.ar.minval(ifun item.age efun)); }
	ut.tests.tmax_complex	= function(test, data) { test.assert_equals(50, data.ar.maxval(ifun item.age efun)); }
	ut.tests.tmax_complex	= function(test, data) { test.assert_equals(30, data.ar.avg(ifun item.age efun)); }
	ut.tests.sum_complex	= function(test, data) { test.assert_equals(150, data.ar.sum(ifun item.age efun)); }

	ut.tests.where			= function(test, data) { test.assert_equals([4,5], data.ar.where(ifun item>3 efun).array); }
	ut.tests.any_true		= function(test, data) { test.assert_true(data.ar.is_any(ifun item%2==0 efun)); }
	ut.tests.any_false		= function(test, data) { test.assert_false(data.ar.is_any(ifun item%6==0 efun)); }
	ut.tests.all_false		= function(test, data) { test.assert_false(data.ar.are_all(ifun item<3 efun)); }
	ut.tests.all_true		= function(test, data) { test.assert_true(data.ar.are_all(ifun item<=5 efun)); }
	
	ut.tests.first			= function(test, data) { test.assert_equals(1, data.ar.first_or_default()); }
	ut.tests.last			= function(test, data) { test.assert_equals(5, data.ar.last_or_default()); }
	
	ut.tests.first_complex  = function(test, data) { 
		var res = data.ar.first_or_default(ifun item.age>30 efun);
		test.assert_equals(40, res.age); 
	}
	ut.tests.last_complex	= function(test, data) { 
		var res = data.ar.last_or_default(ifun item.age<40 efun);
		test.assert_equals(30, res.age); 
	}

	ut.run();
}
