if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_Race() {
	if (!script_exists(asset_get_index("Race"))) {
		ilog($"Skipped unit tests for 'Race': Not in project.");
		return;
	}

	ENSURE_RACE;
	
	var ut = new UnitTest("Race");

	ut.suite_start = function() {
		file_write_text_file("race/race_unit_test" + DATA_FILE_EXTENSION, "{\"demotable\":{\"loot_count\":6,\"items\":{\"object\":{\"type\":\"RaceObject\",\"always\":0,\"unique\":0,\"enabled\":1,\"chance\":10.0},\"with_attribs\":{\"type\":\"OtherObject\",\"always\":0,\"unique\":0,\"enabled\":1,\"chance\":10.0,\"attributes\":{\"goldvalue\":42}},\"subtable_copy\":{\"type\":\"+subtable_copy\",\"always\":0,\"unique\":0,\"enabled\":1,\"chance\":50.0},\"subtable_ref\":{\"type\":\"=subtable_ref\",\"always\":0,\"unique\":1,\"enabled\":1,\"chance\":100.0},\"nulldrop\":{\"type\":null,\"always\":0,\"unique\":1,\"enabled\":1,\"chance\":33.0}}},\"subtable_copy\":{\"loot_count\":1,\"items\":{\"object\":{\"type\":\"RaceObject\",\"always\":0,\"unique\":0,\"enabled\":1,\"chance\":10.0}}},\"subtable_ref\":{\"loot_count\":1,\"items\":{\"object\":{\"type\":\"RaceObject\",\"always\":0,\"unique\":0,\"enabled\":1,\"chance\":10.0}}}}", FILE_CRYPT_KEY);
	}
	
	ut.suite_finish = function() {
		file_delete("race/race_unit_test" + DATA_FILE_EXTENSION);
	}

	ut.test_start = function(name, data) {
		data.t = new Race("race_unit_test", false, true);
		
		if (string_contains(name, "query"))
			data.t.add_table(new RaceTable("loot", {
				loot_count: 1,
				items: {
					item0: new RaceItem("grp1_item0", 10, 0, 0, 0),
					item1: new RaceItem("grp1_item1", 10, 0, 0, 0),
					item2: new RaceItem("grp2_item2", 10, 0, 0, 0),
					item3: new RaceItem("grp2_item3", 10, 0, 0, 0),
				}
			}));		
		
		if (string_contains(name, "item"))
			data.t.add_table(new RaceTable("bools", {
				loot_count: 1,
				items: {
					item0: { type: "grp1_item0", always: 0, unique: 0, enabled: 0, chance: 10.0, attributes: {a1: 0, a2: 7},},
					item1: { type: "grp2_item1", always: 0, unique: 0, enabled: 1, chance: 20.0, attributes: {a1: 1, a2: 6},},
					item2: { type: "grp3_item2", always: 0, unique: 1, enabled: 0, chance: 30.0, attributes: {a1: 2, a2: 5},},
					item3: { type: "grp4_item3", always: 0, unique: 1, enabled: 1, chance: 40.0, attributes: {a1: 3, a2: 4},},
					item4: { type: "grp1_item4", always: 1, unique: 0, enabled: 0, chance: 50.0, attributes: {a1: 4, a2: 3},},
					item5: { type: "grp2_item5", always: 1, unique: 0, enabled: 1, chance: 60.0, attributes: {a1: 5, a2: 2},},
					item6: { type: "grp3_item6", always: 1, unique: 1, enabled: 0, chance: 70.0, attributes: {a1: 6, a2: 1},},
					item7: { type: "grp4_item7", always: 1, unique: 1, enabled: 1, chance: 80.0, attributes: {a1: 7, a2: 0},},
				}
			}));
	}

	ut.test_finish = function(name, data) {
		data.t.clear();
	}

	ut.tests.file_load_ok = function(test, data) {
		var race = data.t;
		
		var names = struct_get_names(race.tables);
		
		test.assert_equals(3, array_length(names));
		test.assert_true(race.table_exists("demotable"), "demotable");
		test.assert_true(race.table_exists("subtable_copy"), "subtable_copy");
		test.assert_true(race.table_exists("subtable_ref"), "subtable_ref");
		
		test.assert_equals(6, race.tables.demotable.loot_count);
		test.assert_equals(1, race.tables.subtable_copy.loot_count);
		test.assert_equals(1, race.tables.subtable_ref.loot_count);
	};

	ut.tests.global_cache_ok = function(test, data) {
		var race = data.t;
		
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var names = struct_get_names(cache);
		
		test.assert_equals(3, array_length(names));
		test.assert_not_null(vsget(cache, "demotable"), "demotable");
		test.assert_not_null(vsget(cache, "subtable_copy"), "subtable_copy");
		test.assert_not_null(vsget(cache, "subtable_ref"), "subtable_ref");
		
		test.assert_equals(6, cache.demotable.loot_count);
		test.assert_equals(1, cache.subtable_copy.loot_count);
		test.assert_equals(1, cache.subtable_ref.loot_count);
	};

	ut.tests.add_table_manually_ok = function(test, data) {
		var race = data.t;
		
		race.add_table(new RaceTable("_temp", {
			loot_count: 3,
			items: {
				some: {type: "something", always: 0, unique: 0, enabled: 1, chance : 10.0, }
			}
		}));
		
		test.assert_true(race.table_exists("_temp"), "_temp exists");

		// now test, that this temp table is NOT in the global cache
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var names = struct_get_names(cache);
		test.assert_null(vsget(cache, "_temp"), "cache hit");
		
		// now remove the table
		race.remove_table("_temp");
		test.assert_false(race.table_exists("_temp"), "_temp gone");
	}

	ut.tests.remove_table_local_ok = function(test, data) {
		var race = data.t;
		test.assert_true(race.table_exists("demotable"), "demotable exists");
		test.assert_not_null(vsget(vsget(__RACE_CACHE, race.__cache_name), "demotable"), "cache before");
		
		race.remove_table("demotable", false);
		
		// table is gone, but global cache must still exist
		test.assert_false(race.table_exists("demotable"), "demotable gone");
		test.assert_not_null(vsget(vsget(__RACE_CACHE, race.__cache_name), "demotable"), "cache after");
	}

	ut.tests.remove_table_global_ok = function(test, data) {
		var race = data.t;
		test.assert_true(race.table_exists("demotable"), "demotable exists");
		test.assert_not_null(vsget(vsget(__RACE_CACHE, race.__cache_name), "demotable"), "cache after");
		
		race.remove_table("demotable", true);
		
		// table is gone, and global cache also
		test.assert_false(race.table_exists("demotable"), "demotable gone");
		test.assert_null(vsget(vsget(__RACE_CACHE, race.__cache_name), "demotable"), "cache after");
	}

	ut.tests.clone_table_ok = function(test, data) {
		var race = data.t;
		
		var ori = race.get_table("demotable");
		var tbl = race.clone_table("demotable");
		test.assert_true(string_starts_with(tbl.name, __RACE_TEMP_TABLE_PREFIX), "temp name");
		
		test.assert_equals(6, tbl.loot_count, "clone count");
		
		// change the loot count - the original may NOT change
		tbl.loot_count = 42;
		test.assert_equals(42, tbl.loot_count, "modified tbl count");
		test.assert_equals( 6, ori.loot_count, "modified ori count");
		
		// change an inner item to ensure, even the sub structs are clones
		tbl.items.object.chance = 999;
		test.assert_equals(999, tbl.items.object.chance, "modified tbl chance");
		test.assert_equals( 10, ori.items.object.chance, "modified ori chance");
	}

	ut.tests.clear_local_ok = function(test, data) {
		var race = data.t;
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var rnames = struct_get_names(race.tables);
		var cnames = struct_get_names(cache);
		
		// make sure, 3 tables in race and cache
		test.assert_equals(3, array_length(rnames), "before clear race" );
		test.assert_equals(3, array_length(cnames), "before clear cache");
		
		// now only race is deleted, cache still alive
		race.clear(false);
		rnames = struct_get_names(race.tables);
		cnames = struct_get_names(cache);
		test.assert_equals(0, array_length(rnames), "after local clear race" );
		test.assert_equals(3, array_length(cnames), "after local clear cache");

	}

	ut.tests.clear_global_ok = function(test, data) {
		var race = data.t;
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var rnames = struct_get_names(race.tables);
		var cnames = struct_get_names(cache);
		
		// make sure, 3 tables in race and cache
		test.assert_equals(3, array_length(rnames), "before clear race" );
		test.assert_equals(3, array_length(cnames), "before clear cache");
		
		// now both are cleared		
		race.clear(true);
		rnames = struct_get_names(race.tables);
		cnames = struct_get_names(cache);
		test.assert_equals(0, array_length(rnames), "after global clear race" );
		test.assert_equals(0, array_length(cnames), "after global clear cache");
	}

	ut.tests.reset_table_loaded_ok = function(test, data) {
		var race = data.t;
		
		test.assert_equals(6, race.tables.demotable.loot_count);
		
		// modify the loot count, reset non-recursive, must be 6 again
		race.tables.demotable.loot_count = 42;
		race.tables.subtable_ref.items.object.chance = 99;
		
		race.reset_table("demotable", false);
		test.assert_equals(6 , race.tables.demotable.loot_count, "loot count non-recursive");
		test.assert_equals(99, race.tables.subtable_ref.items.object.chance, "chance non-recursive");
		
		race.tables.demotable.loot_count = 42;
		race.reset_table("demotable");
		test.assert_equals(6 , race.tables.demotable.loot_count, "loot count recursive");
		test.assert_equals(10, race.tables.subtable_ref.items.object.chance, "chance recursive");
	}

	ut.tests.reset_table_cloned_ok = function(test, data) {
		var race = data.t;
		var tbl = race.clone_table("demotable");
		
		tbl.loot_count = 42;
		race.reset_table(tbl.name);
		// still 42, as temp tables can't be reset
		test.assert_equals(42, tbl.loot_count);
	}
	
	ut.tests.reset_manual_table_ok = function(test, data) {
		var race = data.t;
		var tbl = new RaceTable("_temp", {
			loot_count: 3,
			items: {
				some: {type: "something", always: 0, unique: 0, enabled: 1, chance : 10.0, }
			}
		});

		race.add_table(tbl);
		tbl.loot_count = 42;
		race.reset_table(tbl.name);
		// still 42, as temp tables can't be reset
		test.assert_equals(42, tbl.loot_count);
	}

	ut.tests.itemfilter_bools_ok = function(test, data) {
		var race = data.t;
		var res;
		// all single-bool filters must return 4 items, 
		// as each bool is true 4 times in the table
		res = race.tables.bools.filter_items().for_always(0).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "always-result-count-0");
		test.assert_true(vsget(res, "item0"), "always-0");
		test.assert_true(vsget(res, "item1"), "always-1");
		test.assert_true(vsget(res, "item2"), "always-2");
		test.assert_true(vsget(res, "item3"), "always-3");
		
		res = race.tables.bools.filter_items().for_always(1).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "always-result-count-1");
		test.assert_true(vsget(res, "item4"), "always-4");
		test.assert_true(vsget(res, "item5"), "always-5");
		test.assert_true(vsget(res, "item6"), "always-6");
		test.assert_true(vsget(res, "item7"), "always-7");

		res = race.tables.bools.filter_items().for_unique(0).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "unique-result-count-0");
		test.assert_true(vsget(res, "item0"), "unique-0");
		test.assert_true(vsget(res, "item1"), "unique-1");
		test.assert_true(vsget(res, "item4"), "unique-4");
		test.assert_true(vsget(res, "item5"), "unique-5");
		
		res = race.tables.bools.filter_items().for_unique(1).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "unique-result-count-1");
		test.assert_true(vsget(res, "item2"), "unique-2");
		test.assert_true(vsget(res, "item3"), "unique-3");
		test.assert_true(vsget(res, "item6"), "unique-6");
		test.assert_true(vsget(res, "item7"), "unique-7");

		res = race.tables.bools.filter_items().for_enabled(0).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "enabled-result-count-0");
		test.assert_true(vsget(res, "item0"), "enabled-0");
		test.assert_true(vsget(res, "item2"), "enabled-2");
		test.assert_true(vsget(res, "item4"), "enabled-4");
		test.assert_true(vsget(res, "item6"), "enabled-6");
		
		res = race.tables.bools.filter_items().for_enabled(1).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "enabled-result-count-1");
		test.assert_true(vsget(res, "item1"), "enabled-1");
		test.assert_true(vsget(res, "item3"), "enabled-3");
		test.assert_true(vsget(res, "item5"), "enabled-5");
		test.assert_true(vsget(res, "item7"), "enabled-7");

		// now test the combination of all 3 - we receive 8 unique results
		res = race.tables.bools.filter_items().for_always(0).for_unique(0).for_enabled(0).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-000");
		test.assert_true(vsget(res, "item0"), "triple-000");
		
		res = race.tables.bools.filter_items().for_always(0).for_unique(0).for_enabled(1).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-001");
		test.assert_true(vsget(res, "item1"), "triple-001");
		
		res = race.tables.bools.filter_items().for_always(0).for_unique(1).for_enabled(0).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-010");
		test.assert_true(vsget(res, "item2"), "triple-010");
		
		res = race.tables.bools.filter_items().for_always(0).for_unique(1).for_enabled(1).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-011");
		test.assert_true(vsget(res, "item3"), "triple-011");
		
		res = race.tables.bools.filter_items().for_always(1).for_unique(0).for_enabled(0).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-100");
		test.assert_true(vsget(res, "item4"), "triple-100");
		
		res = race.tables.bools.filter_items().for_always(1).for_unique(0).for_enabled(1).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-101");
		test.assert_true(vsget(res, "item5"), "triple-101");
		
		res = race.tables.bools.filter_items().for_always(1).for_unique(1).for_enabled(0).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-110");
		test.assert_true(vsget(res, "item6"), "triple-110");
		
		res = race.tables.bools.filter_items().for_always(1).for_unique(1).for_enabled(1).build();
		test.assert_equals(1, array_length(struct_get_names(res)), "triple-result-count-111");
		test.assert_true(vsget(res, "item7"), "triple-111");
	}

	ut.tests.itemfilter_chances_ok = function(test, data) {
		var race = data.t;
		var res;
		
		// test all true
		res = race.tables.bools.filter_items().for_chance(function(c) { return true; }).build();
		test.assert_equals(8, array_length(struct_get_names(res)), "chance-true");
		test.assert_true(vsget(res, "item0"), "chance-true-0");
		test.assert_true(vsget(res, "item1"), "chance-true-1");
		test.assert_true(vsget(res, "item2"), "chance-true-2");
		test.assert_true(vsget(res, "item3"), "chance-true-3");
		test.assert_true(vsget(res, "item4"), "chance-true-4");
		test.assert_true(vsget(res, "item5"), "chance-true-5");
		test.assert_true(vsget(res, "item6"), "chance-true-6");
		test.assert_true(vsget(res, "item7"), "chance-true-7");

		// test all false
		res = race.tables.bools.filter_items().for_chance(function(c) { return false; }).build();
		test.assert_equals(0, array_length(struct_get_names(res)), "chance-false");
		
		// test all multiples of 20 (some random filter)
		res = race.tables.bools.filter_items().for_chance(function(c) { return c % 20 == 0; }).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "chance-modulo-20");
		test.assert_true(vsget(res, "item1"), "chance-modulo-1");
		test.assert_true(vsget(res, "item3"), "chance-modulo-3");
		test.assert_true(vsget(res, "item5"), "chance-modulo-5");
		test.assert_true(vsget(res, "item7"), "chance-modulo-7");
	}
	
	ut.tests.itemfilter_attributes_ok = function(test, data) {
		var race = data.t;
		var res;
		
		// test all true
		res = race.tables.bools.filter_items().for_attribute(function(a) { return true; }).build();
		test.assert_equals(8, array_length(struct_get_names(res)), "attribute-true");
		test.assert_true(vsget(res, "item0"), "attribute-true-0");
		test.assert_true(vsget(res, "item1"), "attribute-true-1");
		test.assert_true(vsget(res, "item2"), "attribute-true-2");
		test.assert_true(vsget(res, "item3"), "attribute-true-3");
		test.assert_true(vsget(res, "item4"), "attribute-true-4");
		test.assert_true(vsget(res, "item5"), "attribute-true-5");
		test.assert_true(vsget(res, "item6"), "attribute-true-6");
		test.assert_true(vsget(res, "item7"), "attribute-true-7");

		// test all false
		res = race.tables.bools.filter_items().for_attribute(function(a) { return false; }).build();
		test.assert_equals(0, array_length(struct_get_names(res)), "attribute-false");
		
		// test all multiples of 20 (some random filter)
		res = race.tables.bools.filter_items().for_attribute(function(a) { return a.a1 >= a.a2; }).build();
		test.assert_equals(4, array_length(struct_get_names(res)), "attribute-a1-a2");
		test.assert_true(vsget(res, "item4"), "attribute-a1-a2-4");
		test.assert_true(vsget(res, "item5"), "attribute-a1-a2-5");
		test.assert_true(vsget(res, "item6"), "attribute-a1-a2-6");
		test.assert_true(vsget(res, "item7"), "attribute-a1-a2-7");
	}
	
	ut.tests.itemfilter_types_ok = function(test, data) {
		var race = data.t;
		var res;
		
		// test all true
		res = race.tables.bools.filter_items().for_type("*").build();
		test.assert_equals(8, array_length(struct_get_names(res)), "type-true");
		test.assert_true(vsget(res, "item0"), "type-true-0");
		test.assert_true(vsget(res, "item1"), "type-true-1");
		test.assert_true(vsget(res, "item2"), "type-true-2");
		test.assert_true(vsget(res, "item3"), "type-true-3");
		test.assert_true(vsget(res, "item4"), "type-true-4");
		test.assert_true(vsget(res, "item5"), "type-true-5");
		test.assert_true(vsget(res, "item6"), "type-true-6");
		test.assert_true(vsget(res, "item7"), "type-true-7");

		// test all false
		res = race.tables.bools.filter_items().for_type("invalid").build();
		test.assert_equals(0, array_length(struct_get_names(res)), "type-false");
		
		// test all multiples of 20 (some random filter)
		res = race.tables.bools.filter_items().for_type("grp1*").build();
		test.assert_equals(2, array_length(struct_get_names(res)), "type-grp1");
		test.assert_true(vsget(res, "item0"), "type-grp1-0");
		test.assert_true(vsget(res, "item4"), "type-grp1-4");
	}
	
	ut.tests.itembatch_bools_ok = function(test, data) {
		var race = data.t;
		var tbl = race.tables.bools;
		
		// batch-set all bools to 1 and 0 (6 blocks)
		tbl.set_all_enabled(1);
		test.assert_equals(1, tbl.items.item0.enabled, "batch-enabled-1-0");
		test.assert_equals(1, tbl.items.item1.enabled, "batch-enabled-1-1");
		test.assert_equals(1, tbl.items.item2.enabled, "batch-enabled-1-2");
		test.assert_equals(1, tbl.items.item3.enabled, "batch-enabled-1-3");
		test.assert_equals(1, tbl.items.item4.enabled, "batch-enabled-1-4");
		test.assert_equals(1, tbl.items.item5.enabled, "batch-enabled-1-5");
		test.assert_equals(1, tbl.items.item6.enabled, "batch-enabled-1-6");
		test.assert_equals(1, tbl.items.item7.enabled, "batch-enabled-1-7");
		
		tbl.set_all_enabled(0);
		test.assert_equals(0, tbl.items.item0.enabled, "batch-enabled-0-0");
		test.assert_equals(0, tbl.items.item1.enabled, "batch-enabled-0-1");
		test.assert_equals(0, tbl.items.item2.enabled, "batch-enabled-0-2");
		test.assert_equals(0, tbl.items.item3.enabled, "batch-enabled-0-3");
		test.assert_equals(0, tbl.items.item4.enabled, "batch-enabled-0-4");
		test.assert_equals(0, tbl.items.item5.enabled, "batch-enabled-0-5");
		test.assert_equals(0, tbl.items.item6.enabled, "batch-enabled-0-6");
		test.assert_equals(0, tbl.items.item7.enabled, "batch-enabled-0-7");

		tbl.set_all_unique(1);
		test.assert_equals(1, tbl.items.item0.unique, "batch-unique-1-0");
		test.assert_equals(1, tbl.items.item1.unique, "batch-unique-1-1");
		test.assert_equals(1, tbl.items.item2.unique, "batch-unique-1-2");
		test.assert_equals(1, tbl.items.item3.unique, "batch-unique-1-3");
		test.assert_equals(1, tbl.items.item4.unique, "batch-unique-1-4");
		test.assert_equals(1, tbl.items.item5.unique, "batch-unique-1-5");
		test.assert_equals(1, tbl.items.item6.unique, "batch-unique-1-6");
		test.assert_equals(1, tbl.items.item7.unique, "batch-unique-1-7");
		
		tbl.set_all_unique(0);
		test.assert_equals(0, tbl.items.item0.unique, "batch-unique-0-0");
		test.assert_equals(0, tbl.items.item1.unique, "batch-unique-0-1");
		test.assert_equals(0, tbl.items.item2.unique, "batch-unique-0-2");
		test.assert_equals(0, tbl.items.item3.unique, "batch-unique-0-3");
		test.assert_equals(0, tbl.items.item4.unique, "batch-unique-0-4");
		test.assert_equals(0, tbl.items.item5.unique, "batch-unique-0-5");
		test.assert_equals(0, tbl.items.item6.unique, "batch-unique-0-6");
		test.assert_equals(0, tbl.items.item7.unique, "batch-unique-0-7");

		tbl.set_all_always(1);
		test.assert_equals(1, tbl.items.item0.always, "batch-always-1-0");
		test.assert_equals(1, tbl.items.item1.always, "batch-always-1-1");
		test.assert_equals(1, tbl.items.item2.always, "batch-always-1-2");
		test.assert_equals(1, tbl.items.item3.always, "batch-always-1-3");
		test.assert_equals(1, tbl.items.item4.always, "batch-always-1-4");
		test.assert_equals(1, tbl.items.item5.always, "batch-always-1-5");
		test.assert_equals(1, tbl.items.item6.always, "batch-always-1-6");
		test.assert_equals(1, tbl.items.item7.always, "batch-always-1-7");
		
		tbl.set_all_always(0);
		test.assert_equals(0, tbl.items.item0.always, "batch-always-0-0");
		test.assert_equals(0, tbl.items.item1.always, "batch-always-0-1");
		test.assert_equals(0, tbl.items.item2.always, "batch-always-0-2");
		test.assert_equals(0, tbl.items.item3.always, "batch-always-0-3");
		test.assert_equals(0, tbl.items.item4.always, "batch-always-0-4");
		test.assert_equals(0, tbl.items.item5.always, "batch-always-0-5");
		test.assert_equals(0, tbl.items.item6.always, "batch-always-0-6");
		test.assert_equals(0, tbl.items.item7.always, "batch-always-0-7");

		// Now test them again, but with a subset of only 2 items
		// All bools in the table are 0 due to the set_all_* above (2nd call is always "0")
		// Filter only 2 items, lets say... grp 2 from the table
		var subset = race.tables.bools.filter_items().for_type("grp2*").build();
		
		// now use set_all_* with the subset and set all bools in the subset to 1
		tbl.set_all_enabled(1, subset);
		tbl.set_all_unique (1, subset);
		tbl.set_all_always (1, subset);
		
		// now check all 24 flags
		test.assert_equals(0, tbl.items.item0.enabled, "batch-enabled-subset-0");
		test.assert_equals(1, tbl.items.item1.enabled, "batch-enabled-subset-1");
		test.assert_equals(0, tbl.items.item2.enabled, "batch-enabled-subset-2");
		test.assert_equals(0, tbl.items.item3.enabled, "batch-enabled-subset-3");
		test.assert_equals(0, tbl.items.item4.enabled, "batch-enabled-subset-4");
		test.assert_equals(1, tbl.items.item5.enabled, "batch-enabled-subset-5");
		test.assert_equals(0, tbl.items.item6.enabled, "batch-enabled-subset-6");
		test.assert_equals(0, tbl.items.item7.enabled, "batch-enabled-subset-7");

		test.assert_equals(0, tbl.items.item0.unique, "batch-unique-subset-0");
		test.assert_equals(1, tbl.items.item1.unique, "batch-unique-subset-1");
		test.assert_equals(0, tbl.items.item2.unique, "batch-unique-subset-2");
		test.assert_equals(0, tbl.items.item3.unique, "batch-unique-subset-3");
		test.assert_equals(0, tbl.items.item4.unique, "batch-unique-subset-4");
		test.assert_equals(1, tbl.items.item5.unique, "batch-unique-subset-5");
		test.assert_equals(0, tbl.items.item6.unique, "batch-unique-subset-6");
		test.assert_equals(0, tbl.items.item7.unique, "batch-unique-subset-7");
		
		test.assert_equals(0, tbl.items.item0.always, "batch-always-subset-0");
		test.assert_equals(1, tbl.items.item1.always, "batch-always-subset-1");
		test.assert_equals(0, tbl.items.item2.always, "batch-always-subset-2");
		test.assert_equals(0, tbl.items.item3.always, "batch-always-subset-3");
		test.assert_equals(0, tbl.items.item4.always, "batch-always-subset-4");
		test.assert_equals(1, tbl.items.item5.always, "batch-always-subset-5");
		test.assert_equals(0, tbl.items.item6.always, "batch-always-subset-6");
		test.assert_equals(0, tbl.items.item7.always, "batch-always-subset-7");
	}
	
	ut.tests.itembatch_chances_ok = function(test, data) {
		var race = data.t;
		var tbl = race.tables.bools;
		
		// make sure, chances are correct before we modify
		test.assert_equals(10, tbl.items.item0.chance, "chances-start-0");
		test.assert_equals(20, tbl.items.item1.chance, "chances-start-1");
		test.assert_equals(30, tbl.items.item2.chance, "chances-start-2");
		test.assert_equals(40, tbl.items.item3.chance, "chances-start-3");
		test.assert_equals(50, tbl.items.item4.chance, "chances-start-4");
		test.assert_equals(60, tbl.items.item5.chance, "chances-start-5");
		test.assert_equals(70, tbl.items.item6.chance, "chances-start-6");
		test.assert_equals(80, tbl.items.item7.chance, "chances-start-7");
		
		// set all chances to 1
		tbl.set_all_chances(1);
		test.assert_equals(1, tbl.items.item0.chance, "chances-set-to-1-0");
		test.assert_equals(1, tbl.items.item1.chance, "chances-set-to-1-1");
		test.assert_equals(1, tbl.items.item2.chance, "chances-set-to-1-2");
		test.assert_equals(1, tbl.items.item3.chance, "chances-set-to-1-3");
		test.assert_equals(1, tbl.items.item4.chance, "chances-set-to-1-4");
		test.assert_equals(1, tbl.items.item5.chance, "chances-set-to-1-5");
		test.assert_equals(1, tbl.items.item6.chance, "chances-set-to-1-6");
		test.assert_equals(1, tbl.items.item7.chance, "chances-set-to-1-7");
		
		// now add 3 to each chance
		tbl.set_all_chances_modify_by(3);
		test.assert_equals(4, tbl.items.item0.chance, "chances-set-to-4-0");
		test.assert_equals(4, tbl.items.item1.chance, "chances-set-to-4-1");
		test.assert_equals(4, tbl.items.item2.chance, "chances-set-to-4-2");
		test.assert_equals(4, tbl.items.item3.chance, "chances-set-to-4-3");
		test.assert_equals(4, tbl.items.item4.chance, "chances-set-to-4-4");
		test.assert_equals(4, tbl.items.item5.chance, "chances-set-to-4-5");
		test.assert_equals(4, tbl.items.item6.chance, "chances-set-to-4-6");
		test.assert_equals(4, tbl.items.item7.chance, "chances-set-to-4-7");
		
		// now multiply them with 2.5, so all chances are 10
		tbl.set_all_chances_multiply_by(2.5);
		test.assert_equals(10, tbl.items.item0.chance, "chances-set-to-10-0");
		test.assert_equals(10, tbl.items.item1.chance, "chances-set-to-10-1");
		test.assert_equals(10, tbl.items.item2.chance, "chances-set-to-10-2");
		test.assert_equals(10, tbl.items.item3.chance, "chances-set-to-10-3");
		test.assert_equals(10, tbl.items.item4.chance, "chances-set-to-10-4");
		test.assert_equals(10, tbl.items.item5.chance, "chances-set-to-10-5");
		test.assert_equals(10, tbl.items.item6.chance, "chances-set-to-10-6");
		test.assert_equals(10, tbl.items.item7.chance, "chances-set-to-10-7");
		
		// now repeat that all with the subset of grp3 (item 2 and 6)
		var subset = race.tables.bools.filter_items().for_type("grp3*").build();
		
		// all chances are 10 currently, lets set the subset to 20, modify by 4 and divide by 2
		tbl.set_all_chances(20, subset);
		tbl.set_all_chances_modify_by(4, subset);
		tbl.set_all_chances_multiply_by(0.5, subset);
		test.assert_equals(10, tbl.items.item0.chance, "chances-subset-0");
		test.assert_equals(10, tbl.items.item1.chance, "chances-subset-1");
		test.assert_equals(12, tbl.items.item2.chance, "chances-subset-2");
		test.assert_equals(10, tbl.items.item3.chance, "chances-subset-3");
		test.assert_equals(10, tbl.items.item4.chance, "chances-subset-4");
		test.assert_equals(10, tbl.items.item5.chance, "chances-subset-5");
		test.assert_equals(12, tbl.items.item6.chance, "chances-subset-6");
		test.assert_equals(10, tbl.items.item7.chance, "chances-subset-7");
	}
	
	ut.tests.query_bools_ok = function(test, data) {
		var race = data.t;
		var tbl = race.tables.loot;
		var res;
		
		// First, test enabled flag
		tbl.loot_count = 4;
		
		// loot must contain 4 times item0
		tbl.items.item0.enabled = 1;
		res = tbl.query();
		
		test.assert_equals(4, array_length(res), "query-enabled-1");
		for (var i = 0, len = array_length(res); i < len; i++) {
			var it = res[@i];
			// item properties
			test.assert_null(it.instance, "enabled-instance-null");
			test.assert_equals("item0", it.item_name, "enabled-instance-itemname");
			test.assert_equals("loot",  it.table_name, "enabled-instance-tablename");
			// item contens
			test.assert_not_null(it.item, "enabled-item-null");
			test.assert_equals("grp1_item0", it.item.type, "enabled-instance-itemname-0");
			// item is reference
			it.item.chance = 99;
			test.assert_equals(99, tbl.items.item0.chance, "enabled-reference-chance");
			it.item.chance = 10;
		}
		
		// now set also unique, then there may be only 1 drop, even with loot_count = 4
		tbl.items.item0.unique = 1;
		res = tbl.query();		
		test.assert_equals(1, array_length(res), "query-unique-1");
		test.assert_equals("item0", res[@0].item_name, "unique-instance-itemname-0");
		
		// To test the always flag, we need 2 enabled items, loot_count = 1 and the loot must ALWAYS be the same item
		tbl.items.item0.enabled = 1; tbl.items.item1.enabled = 1;
		tbl.items.item0.always  = 1; tbl.items.item1.always  = 0;
		tbl.items.item0.unique  = 0; tbl.items.item1.unique  = 0;
		
		tbl.loot_count = 1;
		repeat(100) { // just do it 100 times to take away the random factor
			res = tbl.query();		
			test.assert_equals(1, array_length(res), "query-always-1");
			test.assert_equals("item0", res[@0].item_name, "always-instance-itemname-0");
		}
		
		// final test: if more items are "always" than the loot_count allows, loot_count loses. all drop.
		tbl.items.item0.enabled = 1; tbl.items.item1.enabled = 1;
		tbl.items.item0.always  = 1; tbl.items.item1.always  = 1;
		tbl.items.item0.unique  = 0; tbl.items.item1.unique  = 0;
		
		res = tbl.query();		
		test.assert_equals(2, array_length(res), "query-always-2");
		var have0 = false;
		var have1 = false;
		for (var i = 0, len = array_length(res); i < len; i++) {
			var it = res[@i];
			have0 |= (res[@i].item_name == "item0");
			have1 |= (res[@i].item_name == "item1");
		}
		test.assert_true(have0, "always-instance-itemname-0");
		test.assert_true(have1, "always-instance-itemname-1");
	}
	
	ut.tests.query_refs_and_subs_ok = function(test, data) {
		var race = data.t;
		test.assert_not_null(race, "race null");
		test.assert_not_null(race.tables, "race tables null");
		
		var tbl = race.tables.demotable;
		var ref = race.tables.subtable_ref;
		var cpy_original = race.tables.subtable_copy;
		test.assert_not_null(tbl, "demotable null");
		test.assert_not_null(ref, "ref subtable null");
		test.assert_not_null(cpy_original, "clone subtable null");
				
		var cpy_copy;
		var res;

		tbl.loot_count = 1;
		
		// First, test the reference table
		tbl.set_all_enabled(0);
		tbl.items.subtable_ref.enabled = 1;
		
		// we use race.query_table here, so this method is implicitly tested
		res = race.query_table("demotable");
		test.assert_equals(1, array_length(res), "query-ref-1");
		test.assert_equals("object", res[@0].item_name, "query-ref-itemname-0");
		// there may not be a copy of the reftable, so race's table count still must be 4
		test.assert_equals(4, array_length(struct_get_names(race.tables)), "query-ref-no-copy");
		
		// Second, test the copy table
		tbl.set_all_enabled(0);
		tbl.items.subtable_copy.enabled = 1;
		
		res = race.query_table("demotable");
		test.assert_equals(1, array_length(res), "query-copy-1");
		test.assert_equals("object", res[@0].item_name, "query-copy-itemname-0");
		// there must be a copy of the reftable, so race's table must be 5
		test.assert_equals(5, array_length(struct_get_names(race.tables)), "query-copy-copy");
		test.assert_not_equals("+subtable_copy", tbl.items.subtable_copy.type, "query-copy-name");
		test.assert_true(string_starts_with(tbl.items.subtable_copy.type, $"={__RACE_TEMP_TABLE_PREFIX}"), "query-copy-prefix");
	}
	
	ut.run();
}
