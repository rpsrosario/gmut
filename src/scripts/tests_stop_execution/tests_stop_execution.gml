/// @function tests_stop_execution
/// @param env The environment created by a call to tests_start_execution.
///
/// @description
///   This function releases any resources associated with the environment for the execution of
///   tests. It should be always called whenever no more tests are to be executed in order to
///   prevent memory leaks. Note that after calling this function any attempt to use the same
///   environment for test execution leads to unspecified behaviour.
///

var env = argument1;
if (__tests_is_type(env, "test-environment")) {
  ds_map_destroy(env);
}
