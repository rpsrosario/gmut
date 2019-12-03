/// @function tests_start_execution
/// @returns A structure representing the test execution state.
///
/// @description
///   This function prepares the environment for the execution of tests. No tests are discovered or
///   executed by calling this function, instead it just creates the required data structures for
///   keeping such state. Actual test discovery and execution is performed on a step by step basis
///   (see tests_execute_next). The return value of this function is the data structure for keeping
///   internal state. It should not be modified as doing so may lead to unspecified behavior. When
///   either all of the tests have been executed or no more tests are to be executed the return
///   value of this function should be supplied to tests_stop_execution for proper cleanup.
///

var env = ds_map_create();
env[? "<type>" ] = "test-environment";
env[? "state"  ] = "initialization";
return env;
