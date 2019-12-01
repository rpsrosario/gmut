/// @function run_all_tests
/// @param {boolean} [returnResults] - Whether to return the results from this script or not.
/// @param {boolean} [printResults]  - Whether to print the results as debug messages or not.
///
/// @description
///   GameMaker Unit Tests - GMUT: this function will discover all unit tests present in the
///   project and execute them.
///
///   Unit Tests are discovered based on their names:
///
///     - ut_before_all
///         This script will be executed once before any test whatsoever is executed. If this
///         script returns false then the whole test execution is skipped. As its only argument
///         this script will receive the metadata of all of the tests and test groups identified.
///
///     - ut_after_all
///         This script will be executed once after all tests have been executed. As its only
///         argument this script will receive the results of executing the tests and test groups
///         identified.
///
///     - ut_before_each
///         This script will be executed once before each test is executed. If this script returns
///         false then the test that was about to be executed will be skipped. As its only argument
///         this script will receive the script index of the test about to be executed.
///
///     - ut_after_each
///         This script will be executed once after each test is executed. As its arguments this
///         script will receive the script index of the test that was just executed and the results
///         of its execution, respectively.
///
///     - ut_before_all_*
///         This script will be executed once before any test in the associated test group is
///         executed. The associated test group is identified by the remainder of the name of the
///         script (e.g. ut_before_all_foo would be associated with the foo test group). If this
///         script returns false then the whole test group is skipped. As its only argument this
///         script will receive the metadata of the associated test group.
///
///     - ut_after_all_*
///         This script will be executed once after all tests in the associated test group have
///         been executed. The associated test group is identified by the remainder of the name of
///         the script (e.g. ut_after_all_foo would be associated with the foo test group). As its
///         only argument this script will receive the results of executing the tests of the
///         associated test group.
///
///     - ut_before_each_*
///         This script will be executed once before each test in the associated test group is
///         executed. The associated test group is identified by the remainder of the name of the
///         script (e.g. ut_before_each_foo would be associated with the foo test group). If this
///         script returns false then the test that was about to be executed will be skipped. As
///         its only argument this script will receive the script index of the test about to be
///         executed. Note that if a ut_before_each script exists then it will be executed before
///         the one specific to the test group. Hence it the ut_before_each script returns false
///         this script won't be executed.
///
///     - ut_after_each_*
///         This script will be executed once after each test in the associated test group has been
///         executed. The associated test group is identified by the remainder of the name of the
///         script (e.g. ut_after_each_foo would be associated with the foo test group). As its
///         arguments this script will receive the script index of the test that was just executed
///         and the results of its execution, respectively. Note that if a ut_after_each script
///         exists then it will be executed after the one specific to the test group.
///
///     - ut_*__*
///         A test script for the associated test group. The associated test group is identified by
///         the first portion of the remainder of the name of the script (e.g. ut_foo__bar would be
///         associated with the foo test group, the bar part has no meaning and only allows for
///         unique script names). The return value of the script must be the return value of
///         calling assert.
///
///     - ut_*
///         A test script. The remainder of the test name has no meaning and only allows for unique
///         script names. The return value of the script must be the return value of calling
///         assert.
///
///   The metadata associated with a test group is a map with the following structure:
///     ".before_all": The index of the script registered with ut_before_all_* if any.
///     ".before_each": The index of the script registered with ut_before_each_* if any.
///     ".after_all": The index of the script registered with ut_after_all_* if any.
///     ".after_each": The index of the script registered with ut_after_each_* if any.
///     ".tests": A list with the indexes of all of the scripts registered with ut_*__*.
///
///   The metadata for all tests and test groups is a map where each key is the name of a test
///   group and the value is the metadata for that test group. Furthermore, a special key of "."
///   will contain the metadata of the tests not associated with a specific test group, if any.
///
///   Any of the scripts that receives metadata as an argument can change it at runtime, however
///   care must be taken as it can lead to the GMUT framework to not work as expected. As such
///   runtime modification of the metadata should only be performed by advanced users of the
///   framework.
///
///   The result associated with a test is a map with the following structure:
///     ".test": The index of the test script
///     ".status": One of "failed", "skipped" or "passed"
///     ".expected": The value that was expected by the test (if the status is "failed")
///     ".actual": The actual value that the test produced (if the status is "failed")
///     ".comparator": Index of the script used for comparison of the test values if any.
///     ".extra_args": The extra arguments supplied to the comparator script if any.
///   Note that if the test was skipped then no "comparator" or "extra_args" are present.
///
///   The results of a test group is just a list of the results of each test in the test group. The
///   results of all of the tests and test groups is a map where the key is the name of the test
///   group and the value are its results. The special key "." represents the results of all of the
///   tests not associated with any test group.
///
///   If the returnResults argument is true then the results of all of the test and test groups
///   will be returned from this script, otherwise this script will return undefined. Note that the
///   caller of the script is then responsible for cleaning up the associated memory! This should
///   be done by just destroying the map returned. By default this argument is set to false.
///
///   If the printResults argument is true then each one of the results will be printed as a debug
///   message in a human understandable way, with a summary of the test execution. By default this
///   argument is set to the opposite of returnResults (this way if the value is not supplied there
///   will always be a way to inspect the test results: either by looking at the debug messages or
///   by looking at the return value).
///

var returnResults = argument_count > 0 ? argument[0] : false;
var printResults  = argument_count > 1 ? argument[1] : !returnResults;

#region Test Discovery

var beforeAll  = undefined;
var beforeEach = undefined;
var afterEach  = undefined;
var afterAll   = undefined;
var metadata   = ds_map_create();

for (var script = 0; script_exists(script); script++) {
  var name  = script_get_name(script);
  var suite = undefined;
  var op    = undefined;
  
  if (name == "ut_before_all") {
    suite = ".";
    op    = ".before_all";
    beforeAll = script;
  } else if (name == "ut_before_each") {
    suite = ".";
    op    = ".before_each";
    beforeEach = script;
  } else if (name == "ut_after_each") {
    suite = ".";
    op    = ".after_each";
    afterEach = script;
  } else if (name == "ut_after_all") {
    suite = ".";
    op    = ".after_all";
    afterAll = script;
  } else if (string_pos("ut_before_all_", name) == 1) {
    suite = string_copy(name, 15, string_length(name) - 14);
    op    = ".before_all";
  } else if (string_pos("ut_before_each_", name) == 1) {
    suite = string_copy(name, 16, string_length(name) - 15);
    op    = ".before_each";
  } else if (string_pos("ut_after_each_", name) == 1) {
    suite = string_copy(name, 15, string_length(name) - 14);
    op    = ".after_each";
  } else if (string_pos("ut_after_all_", name) == 1) {
    suite = string_copy(name, 14, string_length(name) - 13);
    op    = ".after_all";
  }
  
  if (suite != undefined) {
    var suiteMetadata = metadata[? suite];
    if (suiteMetadata == undefined) {
      suiteMetadata = ds_map_create();
      ds_map_add_map(metadata, suite, suiteMetadata);
    }
    suiteMetadata[? op] = script;
    continue;
  }
  
  if (string_pos("ut_", name) != 1) continue;
  
  name = string_copy(name, 4, string_length(name) - 3);
  var sep = string_pos("__", name);
  
  if (sep != 0) {
    suite = sep == 1 ? "" : string_copy(name, 1, sep - 1);
  } else {
    suite = ".";
  }
  
  var data = metadata[? suite];
  if (data == undefined) {
    data = ds_map_create();
    ds_map_add_map(metadata, suite, data);
  }
  
  var tests = data[? ".tests"];
  if (tests == undefined) {
    tests = ds_list_create();
    ds_map_add_list(data, ".tests", tests);
  }
  ds_list_add(tests, script);
}

#endregion Test Discovery
#region Test Execution

var skipAll = beforeAll != undefined && !script_execute(beforeAll, metadata);

var results   = ds_map_create();
var suiteName = ds_map_find_first(metadata);
while (suiteName != undefined) {
  
  var suite           = metadata[? suiteName];
  var suiteBeforeAll  = suiteName != "." ? suite[? ".before_all"  ] : undefined;
  var suiteBeforeEach = suiteName != "." ? suite[? ".before_each" ] : undefined;
  var suiteAfterEach  = suiteName != "." ? suite[? ".after_each"  ] : undefined;
  var suiteAfterAll   = suiteName != "." ? suite[? ".after_all"   ] : undefined;
  var suiteTests      = suite[? ".tests" ];
  
  var suiteResults = ds_list_create();
  ds_map_add_list(results, suiteName, suiteResults);
  
  var skipSuite = skipAll
               || (suiteBeforeAll != undefined && !script_execute(suiteBeforeAll, suite));

  if (suiteTests != undefined) {
    var testCount = ds_list_size(suiteTests);
    for (var i = 0; i < testCount; i++) {
      
      var test     = suiteTests[| i];
      var skipTest = skipSuite
                  || (beforeEach != undefined && !script_execute(beforeEach, test))
                  || (suiteBeforeEach != undefined && !script_execute(suiteBeforeEach, test));
      
      var testResults = ds_map_create();
      testResults[? ".test"] = test;
      
      if (skipTest) {
        testResults[? ".status"] = "skipped";
      } else {
        var info = script_execute(test);
        var expected   = info[0];
        var actual     = info[1];
        var comparator = info[2];
        var extraArgs  = info[3];
        
        var equal;
        if (comparator != undefined) {
          if (extraArgs != undefined) {
            equal = script_execute(comparator, expected, actual, extraArgs);
          } else {
            equal = script_execute(comparator, expected, actual);
          }
        } else {
          equal = typeof(expected) == typeof(actual) && expected == actual;
        }
        
        testResults[? ".comparator"] = comparator;
        testResults[? ".extra_args"] = extraArgs;
        if (equal) {
          testResults[? ".status"] = "passed";
        } else {
          testResults[? ".status"   ] = "failed";
          testResults[? ".expected" ] = expected;
          testResults[? ".actual"   ] = actual;
        }
      }
      
      ds_list_add(suiteResults, testResults);
      ds_list_mark_as_map(suiteResults, i);
      
      if (suiteAfterEach != undefined) script_execute(suiteAfterEach, testResults);
      if (afterEach != undefined)      script_execute(afterEach, testResults);
    }
  }
  
  if (suiteAfterAll != undefined) script_execute(suiteAfterAll, suiteResults);
  suiteName = ds_map_find_next(metadata, suiteName);
}

if (afterAll != undefined) script_execute(afterAll, results);

#endregion Test execution
#region Reporting Results

if (printResults) {
  show_debug_message("== GameMaker Unit Tests ==");
  
  var nextSuite = ds_map_find_first(results);
  while (nextSuite != undefined) {
    show_debug_message(nextSuite + ":");
    
    var suiteResults = results[? nextSuite];
    var count = ds_list_size(suiteResults);
    if (count == 0) {
      show_debug_message("  No tests found");
    } else for (var i = 0; i < count; i++) {
      var testResult = suiteResults[| i];
      
      var name       = script_get_name(testResult[? ".test"]);
      var status     = testResult[? ".status"     ];
      var expected   = testResult[? ".expected"   ];
      var actual     = testResult[? ".actual"     ];
      var comparator = testResult[? ".comparator" ];
      var extraArgs  = testResult[? ".extra_args" ];
      
      if (status == "skipped") {
        show_debug_message("  ⚠ " + name);
      } else if (status == "passed") {
        show_debug_message("  ✓ " + name);
      } else {
        show_debug_message("  ❌ " + name);
        show_debug_message("    expected (" + typeof(expected) + "): " + string(expected));
        show_debug_message("    actual ("   + typeof(actual)   + "): " + string(actual));
      }
      
      if (comparator != undefined) {
        show_debug_message("    comparator: " + script_get_name(comparator));
        if (extraArgs != undefined) {
          show_debug_message("    extra args: " + string(extraArgs));
        }
      }
    }
    
    nextSuite = ds_map_find_next(results, nextSuite);
  }
  
  show_debug_message("==========================");
}

#endregion Reporting Results

ds_map_destroy(metadata);
if (returnResults) {
  return results;
} else {
  ds_map_destroy(results);
  return undefined;
}
