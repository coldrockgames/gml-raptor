// Feather ignore all in ./*

#macro GML_OUTLINE_SHADER_VERSION	"2504"
#macro GML_OUTLINE_SHADER_NAME		"gml-outline-shader "
#macro GML_OUTLINE_SHADER_COPYRIGHT	"(c)2022* coldrock.games, @Grisgram (github)"

var cpyrght = (current_year == 2022) ?
	string_replace(GML_OUTLINE_SHADER_COPYRIGHT, "*", "") :
	string_replace(GML_OUTLINE_SHADER_COPYRIGHT, "*", "-" + string(current_year));
show_debug_message(string_concat(GML_OUTLINE_SHADER_NAME, GML_OUTLINE_SHADER_VERSION, " loaded. ", cpyrght));
