#define gmcallback_browser_click_handler
/// @description  ()
//#browser_click_handler global.g_browser_click_handler
var q = global.g_browser_click_handler;
if (script_exists(q)) script_execute(q);

#define browser_click_handler_init_gml
/// @description  ()
global.g_browser_click_handler = -1;
if (browser_click_handler_init_js()) {
	gmcallback_browser_click_handler();
}

