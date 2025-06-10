/*
	Utility methods that help with randomization.
*/

// Use this macro with braces to prevent syntax checker from going mad
// Use like this: if (IS_PERCENT_HIT(5)) do_something_cool();
#macro IS_PERCENT_HIT random_range(0, 100) <= 

/// @func	roll_dice(sides, dice_count = 1)
/// @desc	Rolls one or more dice with a specified amount of sides.
/// @param  {int} sides			How many sides the die has (6, 12, 20, etc)
/// @param  {int=1} dice_count	How many dice to roll (default = 1)
/// @returns {array}			An array with the length of dice_count entries, each containing one die-result.
function roll_dice(sides, dice_count = 1) {
	var rv = array_create(dice_count, 0);
	for (var i = 0; i < dice_count; i++)
		rv[@ i] = irandom_range(1, sides);
	return rv;
}

