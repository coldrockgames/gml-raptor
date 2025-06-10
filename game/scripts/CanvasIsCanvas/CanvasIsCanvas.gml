/// feather ignore all
/// @func CanvasICanvas
/// @param {Any} value
function CanvasIsCanvas(_canvas) {
	return (is_struct(_canvas) && instanceof(_canvas) == "Canvas");
}