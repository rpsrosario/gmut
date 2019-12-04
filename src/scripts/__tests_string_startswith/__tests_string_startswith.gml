/// @function __tests_string_startswith
/// @param string The string to check.
/// @param substring The string to check for.
/// @returns True if the supplied string starts with the supplied substring, false otherwise.
///
/// @description
///   Utility function to check if a string starts with the given substring or not.
///

gml_pragma("forceinline");
return string_pos(argument1, argument0) == 1;
