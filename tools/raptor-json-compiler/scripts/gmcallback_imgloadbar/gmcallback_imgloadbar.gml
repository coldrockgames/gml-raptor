/*
	How this file works:
	It gets called from the .js extension from the loading bar.
	The first argument contains, what is needed from the loading screen.
	This method is more or less a big switch statement that returns the desired values.
	
	Especially for the colors:
	Use your CI Colors, so you get a fitting theme to your software label, a styled loading screen.

	Credits to @YellowAfterLife for this extension.
	It has been modified slightly by me.	
*/


/// @desc  gmcallback_imgloadbar(context, current, total, canvas_width, canvas_height, image_width, image_height)
/// @param context
/// @param  current
/// @param  total
/// @param  canvas_width
/// @param  canvas_height
/// @param  image_width
/// @param  image_height
function gmcallback_imgloadbar(argument0, argument1, argument2, argument3, argument4, argument5, argument6) {
	var r;
	var pc = argument1; // progress current
	var pt = argument2; // progress total
	var cw = argument3; // canvas width
	var ch = argument4; // canvas height
	var iw = argument5; // image width
	var ih = argument6; // image height
	
	switch (argument0) {
	    case "image_rect":
	        //r[0] = (current_time div 500) mod 4 * (iw div 4);
	        //r[1] = 0;
	        //r[2] = iw div 4;
	        //r[3] = ih;

	        r[0] = 0;
	        r[1] = 0;
	        r[2] = iw;
	        r[3] = ih;
			return r;
	    case "background_color":		return "#111111";
	    case "bar_background_color":	return "#000000";
	    case "bar_foreground_color":	return "#1111CC";
	    case "bar_border_color":		return "#050588";
	    case "bar_width":				return round(cw * 0.6);
	    case "bar_height":				return 24;
	    case "bar_border_width":		return 2;
	    case "bar_offset":				return 10;
	}
	return undefined;
}
