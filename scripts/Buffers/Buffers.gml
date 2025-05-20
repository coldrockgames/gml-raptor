/*
	Utility methods to work with buffers.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
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

/// @func			encrypt_buffer(buffer, cryptkey)
/// @desc		Encrypts the specified buffer with a key by xor'ing each byte
///						of the buffer with the next character in sequence of the crypt key string.
///						This is just a small and simple added confusion level for readers of
///						SaveGame files if you just let this function run over the buffer before
///						writing it to a file.
///						Let the function run over the buffer a second time to decrypt it again.
///						See file_write_encrypted and file_read_encrypted for more information.
///						Those functions use encrypt_buffer.
///						NOTE: This function works with (and modifies) the buffer directly! No copy is made!
/// @param {buffer}	buffer		The buffer to encrypt/decrypt
/// @param {string} cryptkey	A (hopefully) long string that makes the crypt mask
function encrypt_buffer(buffer, cryptkey) {
	var keyIdx = 1;
	var i = 0;
	var len = string_length(cryptkey);

	repeat (buffer_get_size(buffer)) {
		var byte = buffer_peek(buffer, i, buffer_u8);
		var endkey = ord(string_char_at(cryptkey, len - keyIdx));
		var key = ord(string_char_at(cryptkey, keyIdx++));
		var crypted = byte^key^endkey;
		buffer_poke(buffer, i++, buffer_u8, crypted);
		if (keyIdx > string_length(cryptkey))
			keyIdx = 1;
	}
}
