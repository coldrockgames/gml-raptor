var inst = { };
function ImageLoadBar_hook(ctx, width, height, total, current, image) {
	if (ctx == null)
		return;
	
	function getv(s) {
		if (window.gml_Script_gmcallback_imgloadbar) {
			return window.gml_Script_gmcallback_imgloadbar(inst, null, s, current, total,
				width, height, image ? image.width : 0, image ? image.height : 0)
		} else 
			return undefined;
	}
	function getf(s, d) {
		var r = getv(s);
		return typeof(r) == "number" ? r : d;
	}
	function getw(s, d) {
		var r = getv(s);
		return r && r.constructor == Array ? r : d;
	}
	function getc(s, d) {
		var r = getv(s);
		if (typeof(r) == "number") {
			r = r.toString(16);
			while (r.length < 6) r = "0" + r;
			return "#" + r;
		} else if (typeof(r) == "string") {
			return r;
		} else return d;
	}
	// --- [object CanvasRenderingContext2D]-1920-940-18-1-null
	// get parameters:
	var backgroundColor = getc("background_color", "#FFFFFF");
	var barBackgroundColor = getc("bar_background_color", "#FFFFFF");
	var barForegroundColor = getc("bar_foreground_color", "#242238");
	var barBorderColor = getc("bar_border_color", "#242238");
	var barWidth = getf("bar_width", Math.round(width * 0.6));
	var barHeight = getf("bar_height", 20);
	var barBorderWidth = getf("bar_border_width", 2);
	var barOffset = getf("bar_offset", 10);
	// background:
	ctx.fillStyle = backgroundColor;
	ctx.fillRect(0, 0, width, height);
	// image:
	var totalHeight, barTop;
	if (image != null) {
		var rect = getw("image_rect");
		if (!rect) rect = [0, 0, image.width, image.height];
		totalHeight = rect[3] + barOffset + barHeight;
		var image_y = (height - totalHeight) >> 1;
		ctx.drawImage(image, rect[0], rect[1], rect[2], rect[3],
			(width - rect[2]) >> 1, image_y, rect[2], rect[3]);
		barTop = image_y + rect[3] + barOffset;
	} else barTop = (height - barHeight) >> 1;
	// bar border:
	var barLeft = (width - barWidth) >> 1;
	ctx.fillStyle = barBorderColor;
	ctx.fillRect(barLeft, barTop, barWidth, barHeight);
	//
	var barInnerLeft = barLeft + barBorderWidth;
	var barInnerTop = barTop + barBorderWidth;
	var barInnerWidth = barWidth - barBorderWidth * 2;
	var barInnerHeight = barHeight - barBorderWidth * 2;
	// bar background:
	ctx.fillStyle = barBackgroundColor;
	ctx.fillRect(barInnerLeft, barInnerTop, barInnerWidth, barInnerHeight);
	// bar foreground:
	var barLoadedWidth = Math.round(barInnerWidth * current / total);
	ctx.fillStyle = barForegroundColor;
	ctx.fillRect(barInnerLeft, barInnerTop, barLoadedWidth, barInnerHeight);
}