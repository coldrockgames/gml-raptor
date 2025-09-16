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
__original_lg_string = text;

/// @func	LG_reapply(_ignore_cache = true)
/// @desc	Re-evaluates the original LG string provided when this object
///			has been created.
///			As LG string can contain variables it might be useful to be able
///			to refresh/update the content.
///			By default, a reapply is equal to a "force evaluation".
///			This is, what the _ignore_cache argument does. To use the cache
///			even through a reapply, supply false as argument.
LG_reapply = function(_ignore_cache = true) {
	var ce = __LG_CACHE_ENABLED;
	if (_ignore_cache) __LG_CACHE_ENABLED = false;
	text = LG_resolve(__original_lg_string);
	if (_ignore_cache) __LG_CACHE_ENABLED = ce;
}

LG_reapply();