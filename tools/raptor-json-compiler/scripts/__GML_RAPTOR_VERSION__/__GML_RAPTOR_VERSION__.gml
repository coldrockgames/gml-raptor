// Feather ignore all in ./*

#macro GML_RAPTOR_VERSION	"2504"
#macro GML_RAPTOR_NAME		"gml-raptor "
#macro GML_RAPTOR_COPYRIGHT	"(c)2022* coldrock.games, @Grisgram (github)"

var cpyrght = (current_year == 2022) ?
	string_replace(GML_RAPTOR_COPYRIGHT, "*", "") :
	string_replace(GML_RAPTOR_COPYRIGHT, "*", "-" + string(current_year));
show_debug_message(string_concat(GML_RAPTOR_NAME, GML_RAPTOR_VERSION, " loaded. ", cpyrght));
