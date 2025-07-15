/// @ignore
/// feather ignore all
/// TODO: Preparation for the future of detecting same images and mapping those accordingly
/*
function __CollageHashGenerator(_spriteID){
	var _width = sprite_get_width(_spriteID);
	var _height = sprite_get_height(_spriteID);
	var _size = _width*_height*4;
	var _subImages = sprite_get_number(_spriteID);
	var _surf = surface_create(_width, _height);
	static _buff = buffer_create(1, buffer_fixed, 1);
	buffer_resize(_buff, _size);
	var _hashes = array_create(_subImages);
	var _i = 0;
	repeat(_subImages) {
		surface_set_target(_surf);
		draw_sprite(_spriteID, _i, 0, 0);
		surface_reset_target();
		buffer_get_surface(_buff, _surf, 0);
		_hashes[_i] = buffer_sha1(_buff, 0, _size);
		++_i;
	}
	surface_free(_surf);
	buffer_resize(_buff, 1);
	return _hashes;
}