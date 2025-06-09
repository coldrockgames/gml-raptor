/*
    This function creates a new guid every time it is called.
	The guid is returned as a string of 36 characters in the format
	XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
*/

/// @func guid(as_uppercase = false)
/// @returns {string} a new guid
function guid(as_uppercase = false) {
	var buf = buffer_create(36, buffer_fixed, 1);
	
	static write_bytes = function(buf, cnt, upper) {
		repeat(cnt) buffer_write(buf, buffer_text, string_get_hex(irandom_range(0,255),2,upper));
	}
	
	write_bytes(buf, 4, as_uppercase);
	buffer_write(buf, buffer_text, "-");
	write_bytes(buf, 2, as_uppercase);
	buffer_write(buf, buffer_text, "-");
	write_bytes(buf, 2, as_uppercase);
	buffer_write(buf, buffer_text, "-");
	write_bytes(buf, 2, as_uppercase);
	buffer_write(buf, buffer_text, "-");
	write_bytes(buf, 6, as_uppercase);
	buffer_seek(buf, buffer_seek_start, 14); // this character is always a "4" (guid version marker)
	buffer_write(buf, buffer_text, "4");
	buffer_seek(buf, buffer_seek_start, 19); // this character is always a "a,b,8,9" (definition of guidv4)
	buffer_write(buf, buffer_text, (as_uppercase ? choose("8","9","A","B") : choose("8","9","a","b")));
	
	buffer_seek(buf, buffer_seek_start, 0);
	return buffer_read(buf, buffer_text);
}
