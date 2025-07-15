/// @func CollageDefineSpriteSheet(name, startX, startY, endX, endY)
/// @param {String} name
/// @param {Real} startX
/// @param {Real} startY
/// @param {Real} endX
/// @param {Real} endY
/// feather ignore all
function CollageDefineSpriteSheet(_name, _startX, _startY, _endX, _endY, _sprite_fps = 0) {
		return [_name, _startX, _startY, _endX, _endY, _sprite_fps];
}