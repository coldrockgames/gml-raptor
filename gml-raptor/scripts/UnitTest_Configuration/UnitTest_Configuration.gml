/*
    Configure the unit test setup in this file.
*/

// If you set this to false, every single test will output a "OK" line to the test log
// In bigger projects with lots of tests, it is better to view "FAIL" tests only, so you don't
// need to scroll many pages to find the test error
#macro UNIT_TEST_REPORT_FAILED_ONLY				true

// By default, all unit tests of raptor are prefixed with "unit_test_"
// Either you also use this prefix and name your functions unit_test_* for unit tests, then the
// tests will run together will all raptor unit tests when you select the "unit_testing" configuration
// in the top right corner of GameMaker.
//
// You may also change this prefix to something else and name your function different, then you can run
// your unit tests standalone and ignore/skip all the raptor unit tests.
#macro UNIT_TEST_FUNCTION_PREFIX			"unit_test_"