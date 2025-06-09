/*
	Utility methods to work with buffers.
	
	(c)coldrock.games
*/

/// @func		dump_buffer_hex(buffer, bytes_per_line = 16)
/// @param {buffer} buffer	The buffer to dump
/// @param {int=16}	Bytes per line (default = 16)
/// @desc	Writes the specified buffer as hex dump to the debug console
/// 
function dump_buffer_hex(buffer, bytes_per_line = 16) {
	// Found this little piece of code to display hex number at gmlscripts.com
	static convert = function dec_to_hex(dec, len = 1) 
	{
	    var hex = "";
 
	    if (dec < 0) {
	        len = max(len, ceil(logn(16, 2 * abs(dec))));
	    }
 
	    var dig = "0123456789ABCDEF";
	    while (len-- || dec) {
	        hex = string_concat(string_char_at(dig, (dec & $F) + 1), hex);
	        dec = dec >> 4;
	    }
 
	    return hex;
	};

	static readable = function(byte) {
		return (byte >= 32 && byte < 127) ? chr(byte) : ".";
	};

	buffer_seek(buffer, buffer_seek_start, 0);
	var i = 0;
	ilog($"[--- [BUFFER_DUMP_START] ({buffer_get_size(buffer)} bytes) ---]");
	var outline = "0000: ";
	var human = "";
	repeat (buffer_get_size(buffer)) {
		var byte = buffer_peek(buffer, i++, buffer_u8);
		outline = string_concat(outline, convert(byte, 2), " ");
		human = string_concat(human, readable(byte));
		if (i mod bytes_per_line == 0) {
			ilog($"{outline} {human}");
			outline = convert(i, 4) + ": ";
			human = "";
		}
	}
	var length = bytes_per_line * 3 - 3 * (i mod bytes_per_line) + 1;
	ilog($"{outline} {string_repeat(" ", length)} {human}");
	ilog($"[--- [BUFFER_DUMP_END] ---]");
}
