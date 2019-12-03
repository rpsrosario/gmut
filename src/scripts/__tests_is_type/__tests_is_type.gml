/// @function __tests_is_type
/// @param map The map to check the type for
/// @param type The type the check for
/// @returns True if the supplied map is of the expected type, false otherwise.
///
/// @description
///   Utility function to validate that a given map is of an expected "type", i.e. structure.
///

gml_pragma("forceinline");
return argument0 != undefined
    && ds_exists(argument0, ds_type_map)
    && argument0[? "<type>" ] == argument1;
