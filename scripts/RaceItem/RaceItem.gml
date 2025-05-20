/*
    Convenience functions to add items easily to a table through code
*/


/// @function RaceItem(_type = undefined, _chance = 10, _enabled = 1, _unique = 0, _always = 0, _attributes = undefined)
function RaceItem(_type = undefined, _chance = 10, _enabled = 1, _unique = 0, _always = 0, _attributes = undefined) constructor {

	type	= _type;
	chance	= _chance;
	enabled	= _enabled;
	unique	= _unique;
	always	= _always;
	
	attributes = _attributes ?? {};

}

/// @func RaceNullItem(_chance = 10, _unique = 1) : RaceItem(undefined, _chance, 1, _unique, 0, undefined)
/// @desc Creates a null-drop item, which is by default set to unique = 1
function RaceNullItem(_chance = 10, _unique = 1) : RaceItem(undefined, _chance, 1, _unique, 0, undefined)  constructor {
}
