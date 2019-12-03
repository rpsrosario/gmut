/// @function tests_execute_next
/// @param env The environment created by a call to tests_start_execution.
/// @returns True if there are still execution steps to be taken, false otherwise.
///
/// @description
///   This function performs the next step in the execution of the tests (not necessarily the
///   execution of a test - e.g. test discovery). The supplied environment will be updated to the
///   latest state when the function returns.
///

var env = argument1;
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
    var nextIndex    = testDiscoveryEnv[? "next-index" ];
    var testMetadata = testDiscoveryEnv[? "metadata"   ];
    if (!is_real(nextIndex) || !__tests_is_type(testMetadata, "test-metadata")) {
      break;
    }
    
    if (!script_exists(nextIndex)) {
      // TODO: Move to test execution phase
    } else {
      // TODO: Analyze script
    }
  } break;
  
}

// If no portion of this script could identify that more steps are available then assume that means
// either no steps are actually available or that the environment is in an unkown state and hence
// no further steps can be performed.
return false;
