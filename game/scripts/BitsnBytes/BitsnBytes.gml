/*
	Some binary helper functions
*/

// An enum containing 32 bits, which is normally enough for a bit field
enum bits_enum {
	b0	= 1,
	b1	= 2,
	b2	= 4,
	b3	= 8,
	b4	= 16,
	b5	= 32,
	b6	= 64,
	b7	= 128,
	b8	= 256,
	b9	= 512,
	b10	= 1024,
	b11	= 2048,
	b12 = 4096,
	b13 = 8192,
	b14 = 16384,
	b15 = 32768,
	b16 = 65536,
	b17 = 131072,
	b18 = 262144,
	b19 = 524288,
	b20 = 1048576,
	b21 = 2097152,
	b22 = 4194304,
	b23 = 8388608,
	b24 = 16777216,
	b25 = 33554432,
	b26 = 67108864,
	b27 = 134217728,
	b28 = 268435456,
	b29 = 536870912,
	b30 = 1073741824,
	b31 = 2147483648,
}

/// @func	bit_get_enum(_variable, _enum_value)
/// @desc	Get, whether the bit of the enum_value is set in _variable
function bit_get_enum(_variable, _enum_value) {
	gml_pragma("forceinline");
    return (_variable & _enum_value) == _enum_value;
}

/// @func	bit_set_enum(_variable, _enum_value, _bit_value)
/// @desc	Set the bit of the enum_value in _variable to _bit_value (true or false)
function bit_set_enum(_variable, _enum_value, _bit_value) {
	gml_pragma("forceinline");
    if (_bit_value) {
        return _variable | _enum_value;
    } else {
        return _variable & ~_enum_value;
    }
}

/// @func	bit_get(_variable, _bit_no)
/// @desc	Gets the bit _bit_no of _variable
function bit_get(_variable, _bit_no) {
	gml_pragma("forceinline");
    return (_variable & (1 << _bit_no)) != 0;
}

/// @func	bit_set(_variable, _bit_no, _bit_value)
/// @desc	Sets the bit _bit_no in _variable to _bit_value (true or false)
function bit_set(_variable, _bit_no, _bit_value) {
	gml_pragma("forceinline");
    if (_bit_value) {
        return _variable | (1 << _bit_no);
    } else {
        return _variable & ~(1 << _bit_no);
    }
}