/// @function __tests_string_drop_left
/// @param string The original string.
/// @param count Number of characters to remove from the left.
/// @returns The portion of the string after dropping the leftmost characters.
///
/// @description
///   Drops a predefined number of characters from the left part of the supplied string.
///

gml_pragma("forceinline");
return string_copy(argument0, argument1 + 1, string_length(argument0) - argument1);