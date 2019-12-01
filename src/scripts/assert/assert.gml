/// @function assert
/// @param {any}    expected     - The value expected by the test.
/// @param {any}    actual       - The actual value produced by the test.
/// @param {script} [comparator] - The (optional) script to use for comparing the values.
/// @param {any}    [extraArgs]  - The (optional) extra arguments to supply to the comparator.
///
/// @description
///   Returns the results of the assertion.
///
///   If a comparator is supplied then that script will be used for comparing the expected and the
///   actual values. The script will be called with the expected value as the first argument and
///   the actual value as the second argument. If extraArgs is supplied then its value will be
///   supplied to the comparator as the third argument.
///
///   The returned value of this script should not be used directly, instead the execution of this
///   script should be the return value of any Unit Test.
///

var expected   = argument[0];
var actual     = argument[1];
var comparator = argument_count > 2 ? argument[2] : undefined;
var extraArgs  = argument_count > 3 ? argument[3] : undefined;

return [
  expected, actual, comparator, extraArgs
];
