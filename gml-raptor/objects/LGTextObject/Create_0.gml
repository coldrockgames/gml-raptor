/// @desc resolve text variable through LG

/*
	Set the text variable to anything starting with =
	to have the string resolved on object creation.
	Use double-equal, if you need = at the start of this text
	and you do not want it to be resolved.
	
	Examples:
	set text to "=path/to/your/string" to have it autoresolve on create
	set text to "==keep me" to have it contain "=keep me" on create
*/
event_inherited();
text = LG_resolve(text);
