if (!CONFIGURATION_UNIT_TESTING) exit;
 
function unit_test_Structs() {
	if (!script_exists(asset_get_index("struct_join"))) {
		ilog($"Skipped unit tests for 'Structs': Not in project.");
		return;
	}

	var ut = new UnitTest("Structs");
 
	ut.TestRoot = function(_val = 42) constructor {
		construct("TestRoot");
		some_var = _val;
		
		virtual("TestRoot", "virt", function() {
			return 42;
		});
	}
	 
	ut.tests.construct_ok = function(test, data) {
		var root = new test.TestRoot();	
		test.assert_equals(root[$ __CONSTRUCTOR_NAME], "TestRoot", "construct");
		test.assert_true(is_class_of(root, "TestRoot"), "class of");	
		test.assert_true(is_child_class_of(root, "TestRoot"), "child class of");	
	}
 	
	ut.tests.implement_ok = function(test, data) {
		var root = {};
		with (root) implement(test.TestRoot);
		test.assert_equals(42, root.some_var, "implement default");
		
		with (root) implement(test.TestRoot, 1337);
		test.assert_equals(1337, root.some_var, "implement 1337");

		test.assert_true(implements(root, "TestRoot"), "implements TestRoot");
	}
	
	ut.tests.struct_join_ok = function(test, data) {
		var s1 = { m1: 0 };
		var s2 = { m2: 0 };
		
		var s3 = struct_join(s1, s2);
		
		test.assert_true(struct_exists(s3, "m1"), "m1");
		test.assert_true(struct_exists(s3, "m2"), "m2");
		
		test.assert_false(struct_exists(s2, "m1"), "s2.m1");
		test.assert_false(struct_exists(s1, "m2"), "s1.m2");
	}

	ut.tests.struct_join_into_ok = function(test, data) {
		var s1 = { m1: 0, sub: { sub1: 1, } };
		var s2 = { m2: 0, sub: { sub2: 1, } };
		var s3 = { m3: 0, sub: { sub3: 1, } };
		
		struct_join_into(s1, s2, s3);
		
		test.assert_true(struct_exists(s1, "m1"), "m1");
		test.assert_true(struct_exists(s1, "m2"), "m2");
		test.assert_true(struct_exists(s1, "m3"), "m3");

		test.assert_true(struct_exists(s1.sub, "sub1"), "sub1");
		test.assert_true(struct_exists(s1.sub, "sub2"), "sub2");
		test.assert_true(struct_exists(s1.sub, "sub3"), "sub3");

	}

	ut.tests.struct_join_into_type_mismatch_ok = function(test, data) {
		var s1 = {
			m: "m1",
		};
		var s2 = {
			m: {},
		};
		
		struct_join_into(s1, s2);
		
		test.assert_true(struct_exists(s1, "m"), "s1");
		test.assert_true(struct_exists(s2, "m"), "s2");

		test.assert_true(is_struct(s1.m), "is_struct");
	}

	ut.tests.vsgetx_ok = function(test, data) {
		var root = new test.TestRoot();	

		test.assert_null(vsget(root, "hello"), "hello before");
		vsgetx(root, "hello", undefined, false);		
		test.assert_null(vsget(root, "hello"), "hello after"); // still null
		
		vsgetx(root, "hello", "world");
		test.assert_equals("world", vsget(root, "hello"), "hello world");

	}

	ut.tests.vsget_ok = function(test, data) {
		var root = new test.TestRoot();	

		test.assert_null(vsget(root, "hello"), "hello");
		test.assert_equals(42, vsget(root, "some_var"), "42");
		test.assert_equals(1337, vsget(root, "hello", 1337), "1337");
	}

	ut.tests.versioned_data_struct_names_ok = function(test, data) {
		var vds = new VersionedDataStruct();
		var names = struct_get_names(vds);
		test.assert_equals(3, array_length(names), "length");
		test.assert_true(array_contains(names, "on_game_loaded"), "callback");
		test.assert_true(array_contains(names, __CONSTRUCTOR_NAME), "const");
		test.assert_true(array_contains(names, __PARENT_CONSTRUCTOR_NAME), "parent const");
		
		names = vds.get_names();
		test.assert_zero(array_length(names), "zero");
	}

	ut.tests.class_tree_ok = function(test, data) {
		var undef = class_tree(undefined);
		test.assert_null(undef, "undefined arg");
		
		var tree = class_tree(Coord4);
		test.assert_null(tree, "not an instance");
		
		tree = class_tree(new Coord4());
		test.assert_equals(3, array_length(tree));
		test.assert_equals("Coord4", tree[0], "tree[0]");
		test.assert_equals("Coord3", tree[1], "tree[1]");
		test.assert_equals("Coord2", tree[2], "tree[2]");
	}

	ut.tests.object_tree_ok = function(test, data) {
		var undef = object_tree(undefined);
		test.assert_null(undef, "undefined arg");

		var tree = object_tree(Scrollbar, true); // as strings
		test.assert_equals(8, array_length(tree));
		test.assert_equals("Scrollbar"  , tree[0], "string tree[0]");
		test.assert_equals("_raptorBase", tree[7], "string tree[7]");

		tree = object_tree(Scrollbar, false); // as object indices
		test.assert_equals(8, array_length(tree));
		test.assert_equals(asset_get_index("Scrollbar")  , tree[0], "index tree[0]");
		test.assert_equals(asset_get_index("_raptorBase"), tree[7], "index tree[7]");
		
		// We know, UTE uses scrollbars, so we have an instance
		var firstscroll = undefined;
		with (Scrollbar) {
			firstscroll = self;
			break;
		}
		
		tree = object_tree(firstscroll, true);
		test.assert_equals(8, array_length(tree));
		test.assert_equals("Scrollbar"  , tree[0], "string tree[0]");
		test.assert_equals("_raptorBase", tree[7], "string tree[7]");

		tree = object_tree(firstscroll, false); // as object indices
		test.assert_equals(8, array_length(tree));
		test.assert_equals(asset_get_index("Scrollbar")  , tree[0], "index tree[0]");
		test.assert_equals(asset_get_index("_raptorBase"), tree[7], "index tree[7]");
	}

	ut.tests.deep_copy_ok = function(test, data) {
		var str1 = {
			child: undefined,
			val1: 1,
			val2: 2,
			f1: function(a,b) {return a+b;},
			f2: function() {return val1+val2;}
		};
		var str2 = {
			parent: str1,
			val3: 3,
			val4: 4,
		}
		str1.child = str2;
		var arr1 = [1,2,3,4,5];
		var arr2 = [10,11,str1,arr1,str2]
		arr1[1] = arr2;
		
		var master = {
			s1: str1,
			s2: str2,
			a1: arr1,
			a2: arr2,
		}
		var res = deep_copy(master);

		test.assert_not_equals(master, res, "c1 eq");
		test.assert_equals(master.s1.val1, res.s1.val1, "c1 v");
		test.assert_equals(master.s1.child, master.s2, "c1 pc");
		test.assert_equals(master.s1.child.parent, master.s1, "c1 pc");
		test.assert_not_equals(master.s1.f1, res.s1.f1, "c1 af");
		test.assert_equals(7, master.s1.f1(2,5), "c1 fm");
		test.assert_equals(7, res.s1.f1(2,5), "c1 fr");
		res.s1.val1 = 5;
		res.s1.val2 = 4;
		test.assert_equals(3, master.s1.f2(), "c1 f2m");
		test.assert_equals(9, res.s1.f2(), "c1 f2r");

		var master = [
			str1,
			str2,
			arr1,
			arr2,
		];
		res = deep_copy(master);
		
		test.assert_not_equals(master, res, "c2 eq");
		test.assert_equals(master[0].val1, res[0].val1, "c2 v");
		test.assert_equals(master[0].child, master[1], "c2 pc");
		test.assert_equals(master[0].child.parent, master[0], "c2 pc");
		test.assert_not_equals(master[0].f1, res[0].f1, "c2 af");
		test.assert_equals(7, master[0].f1(2,5), "c2 fm");
		test.assert_equals(7, res[0].f1(2,5), "c2 fr");
		res[0].val1 = 5;
		res[0].val2 = 4;
		test.assert_equals(3, master[0].f2(), "c2 f2m");
		test.assert_equals(9, res[0].f2(), "c2 f2r");
	}

	ut.tests.struct_move_single_ok = function(test, data) {
		var t1 = {
			foo: "bar",
			universe: 42,
			leet: 1337,
		};
		
		var t2 = struct_move(t1, {}, "foo");
		test.assert_equals("bar", t2.foo, "foo");
		test.assert_null(vsget(t1, "foo"), "null");
		
		struct_move(t1, t2, "universe", "leet");
		test.assert_zero(array_length(struct_get_names(t1)), "empty");
		test.assert_equals(42, t2.universe, "universe");
		test.assert_equals(1337, t2.leet, "leet");
	}

	ut.tests.struct_move_array_ok = function(test, data) {
		var t1 = {
			foo: "bar",
			universe: 42,
			leet: 1337,
		};
		
		var t2 = struct_move(t1, {}, ["foo", "leet"]);
		test.assert_equals("bar", t2.foo, "foo");
		test.assert_equals(1337, t2.leet, "leet");
		test.assert_null(vsget(t1, "foo"), "null");
		test.assert_null(vsget(t1, "leet"), "null");
	}

	ut.tests.struct_move_method_ok = function(test, data) {
		var t1 = {
			name: "t1",
			me: function() { 
				return self.name; 
			}
		};
		
		test.assert_equals("t1", t1.me(), "t1me");
		
		var t2 = struct_move(t1, {}, "me");
		t2.name = "t2";
		
		test.assert_equals("t2", t2.me(), "t2me");
		test.assert_null(vsget(t1, "me"), "null");		
	}

	ut.run();
}

