/// @function tests_execute_next
/// @param env The environment created by a call to tests_start_execution.
/// @returns True if there are still execution steps to be taken, false otherwise.
///
/// @description
///   This function performs the next step in the execution of the tests (not necessarily the
///   execution of a test - e.g. test discovery). The supplied environment will be updated to the
///   latest state when the function returns.
///

var env = argument0;
if (!__tests_is_type(env, "test-environment")) {
  // Can't execute any steps from an unknown environment structure.
  return false;
}

switch (env[? "state"]) {
  
  case "initialization": {
    // Prepare the metadata of the discovered tests
    var testMetadata = ds_map_create();
    testMetadata[? "<type>" ] = "test-metadata";
    ds_map_add_list(testMetadata, "test-groups", ds_list_create());
    
    // Prepare the environment for test discovery
    var testDiscoveryEnv = ds_map_create();
    testDiscoveryEnv[? "<type>"     ] = "test-discovery-environment";
    testDiscoveryEnv[? "next-index" ] = 0;
    ds_map_add_map(testDiscoveryEnv, "metadata", testMetadata);
    
    // Update test environment
    ds_map_add_map(env, "context", testDiscoveryEnv);
    env[? "state" ] = "test-discovery";
    
    return true;
  } break;
  
  case "test-discovery": {
    var testDiscoveryEnv = env[? "context" ];
    if (!__tests_is_type(testDiscoveryEnv, "test-discovery-environment")) {
      break;
    }
    
    // Resume test discovery state
    var script       = testDiscoveryEnv[? "next-index" ];
    var testMetadata = testDiscoveryEnv[? "metadata"   ];
    if (!is_real(script) || !__tests_is_type(testMetadata, "test-metadata")) {
      break;
    }
    
    if (!script_exists(script)) {
      // Cleanup context
      ds_map_delete(testDiscoveryEnv, "metadata");
      ds_map_destroy(testDiscoveryEnv);
      
      // Update test environment
      env[? "state" ] = "test-execution-initialization";
      ds_map_add_map(env, "metadata", testMetadata);
      ds_map_delete(env, "context");
      
      return true;
    } else {
      var name  = script_get_name(script);
      var group = undefined;
      var stage = undefined;
      
      // General test lifecycle
      if (name == "ut_before_all") {
        group = ".";
        stage = ".before_all";
      } else if (name == "ut_before_each") {
        group = ".";
        stage = ".before_each";
      } else if (name == "ut_after_each") {
        group = ".";
        stage = ".after_each";
      } else if (name == "ut_after_all") {
        group = ".";
        stage = ".after_all";
      }
      // Test group lifecycle
      else if (__tests_string_startswith(name, "ut_before_all_")) {
        group = __tests_string_drop_left(name, string_length("ut_before_all_"));
        stage = ".before_all";
      } else if (__tests_string_startswith(name, "ut_before_each_")) {
        group = __tests_string_drop_left(name, string_length("ut_before_each_"));
        stage = ".before_each";
      } else if (__tests_string_startswith(name, "ut_after_each_")) {
        group = __tests_string_drop_left(name, string_length("ut_after_each_"));
        stage = ".after_each";
      } else if (__tests_string_startswith(name, "ut_after_all_")) {
        group = __tests_string_drop_left(name, string_length("ut_after_all_"));
        stage = ".after_all";
      }
      // Test cases
      else if (__tests_string_startswith(name, "ut_")) {
        name = __tests_string_drop_left(name, string_length("ut_"));
        var separator = string_pos("__", name);
        if (separator != 0) {
          group = (separator == 1) ? "" : string_copy(name, 1, separator - 1);
        } else {
          group = ".";
        }
        stage = ".tests";
      }
      
      // Save discovered metadata
      if (group != undefined) {
        var groupMetadata = testMetadata[? group];
        if (!__tests_is_type(groupMetadata, "group-metadata")) {
          groupMetadata = ds_map_create();
          groupMetadata[? "<type>" ] = "group-metadata";
          ds_map_add_map(testMetadata, group, groupMetadata);
        }
        
        if (stage != ".tests") {
          groupMetadata[? stage ] = script_get_name(script);
        } else {
          var tests = groupMetadata[? stage ];
          if (tests == undefined || !ds_exists(tests, ds_type_list)) {
            tests = ds_list_create();
            ds_map_add_list(groupMetadata, stage, tests);
          }
          ds_list_add(tests, script_get_name(script));
        }
        
        var groups = testMetadata[? "test-groups" ];
        if (groups == undefined || !ds_exists(groups, ds_type_list)) {
          groups = ds_list_create();
          ds_map_add_list(testMetadata, "test-groups", groups);
        }
        
        if (ds_list_find_index(groups, group) == -1) {
          ds_list_add(groups, group);
        }
      }
      
      // Update context for next iteration
      testDiscoveryEnv[? "next-index" ] = script + 1;
      
      return true;
    }
  } break;
  
  case "test-execution-initialization": {
    // Prepare container for test results
    var testResults = ds_map_create();
    testResults[? "<type>" ] = "test-results-container"
    ds_map_add_list(testResults, "executed-tests", ds_list_create());
    
    // Prepare the environment for test execution
    var testExecutionEnv = ds_map_create();
    testExecutionEnv[? "<type>"     ] = "test-execution-environment";
    testExecutionEnv[? "next-group" ] = 0;
    testExecutionEnv[? "next-test"  ] = 0;
    ds_map_add_map(testExecutionEnv, "results", testResults);
    
    // Update test environment
    ds_map_add_map(env, "context", testExecutionEnv);
    env[? "state" ] = "test-execution";
    
    return true;
  } break;
  
}

// If no portion of this script could identify that more steps are available then assume that means
// either no steps are actually available or that the environment is in an unkown state and hence
// no further steps can be performed.
return false;
