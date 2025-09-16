/*
    Utility class to scan tile layers in rooms.
	Offers various methods to search for things and list items in tile layers.
	
	It also de-mystifies the "rotate, flip, mirror" flag combinations into 
	an easy-to-understand "orientation" value (see enum below).
*/

enum tile_orientation {
	right	= 0, // rotation   0°
	up		= 1, // rotation  90° ccw
	left	= 2, // rotation 180° ccw
	down	= 3, // rotation 270° ccw
}

/// @func	TileScanner(_layername_or_id, _scan_on_create = true, _tileinfo_type = TileInfo)
/// @desc	Creates a TileScanner for the specified layer.
///			if _scan_on_create is true, the constructor will immediately scan the layer
///			and fill the "tiles" array with data. 
///			If you set it to false, tiles is an empty array of undefined's until you invoke "scan_layer()"
///			You may derive a class from TileInfo() and supply it as final argument.
///			TileScanner will use this to instantiate the TileInfo members when scanning.
///			NOTE: Supplying a type that is not a child of TileInfo will crash the game!
function TileScanner(_layername_or_id = undefined, _scan_on_create = true, _tileinfo_type = TileInfo) constructor {
	construct(TileScanner);
	
	__tileinfo_type = _tileinfo_type;
	__scan_timer	= new StopWatch("TileScanner layer scan");
	
	if (_layername_or_id != undefined)
		set_layer(_layername_or_id, _scan_on_create);
	
	/// @func	set_layer(_layername_or_id, scan_now = true)
	/// @desc	Sets or changes the layer used. 
	///			NOTE: This will delete all currently stored TileInfos!
	static set_layer = function(_layername_or_id, scan_now = true) {
		lay_id = is_string(_layername_or_id) ? layer_get_id(_layername_or_id) : _layername_or_id;
		map_id = layer_tilemap_get_id(lay_id);
	
		// These hold the width and height IN CELLS of the map!
		map_width	= tilemap_get_width (map_id);
		map_height	= tilemap_get_height(map_id);
	
		cell_width  = tilemap_get_tile_width (map_id);
		cell_height = tilemap_get_tile_height(map_id);

		tilecount = map_width * map_height;
		tiles = array_create(tilecount, undefined);
		
		ilog($"TileScanner initialized for layer '{layer_get_name(lay_id)}' with {tilecount} tiles in a {map_width}x{map_height} map of {cell_width}x{cell_height}px fields");
		
		if (scan_now)
			scan_layer();
	}

	/// @func	scan_layer()
	/// @desc	Returns (and fills) the "tiles" array of this TileScanner
	static scan_layer = function() {
		__scan_timer.restart();
		// purge any existing arrays
		tilecount = map_width * map_height;
		tiles = array_create(tilecount, undefined);
		var xp = 0, yp = 0;
		repeat (map_height) {
			repeat (map_width) {
				tiles[@(yp * map_width + xp)] = new TileInfo().__set_data(tilemap_get(map_id, xp, yp), xp, yp, self);
				xp++;
			}
			xp = 0;
			yp++;
		}
		__scan_timer.checkpoint($"{tilecount} tiles in");
		return tiles;
	}
	
	#region savegame management
	/// @func	get_modified_tiles()
	/// @desc	Gets an array of tiles that have been modified during runtime.
	///			ATTENTION! This is only for saving them to the savegame.
	///			Upon game load, invoke "restore_modified_tiles" with this array to
	///			recover all changes
	static get_modified_tiles = function() {
		var rv = [];
		var xp = 0, yp = 0;
		repeat (map_height) {
			repeat (map_width) {
				var tile = tiles[@(yp * map_width + xp)];
				if (tile.__modified) {
					var newtile = new __tileinfo_type().__set_data(tile.tiledata, tile.position.x, tile.position.y, self);
					newtile.scanner = undefined;
					newtile.__modified = true;
					array_push(rv, newtile);
				}
				xp++;
			}
			xp = 0;
			yp++;
		}
		dlog($"TileScanner found {array_length(rv)} modified tiles to save");
		return rv;
	}
	
	/// @func	restore_modified_tiles(_modified_tiles)
	/// @desc	Recovers all changed tiles from a savegame.
	///			ATTENTION! This can only be used with the return value of "get_modified_tiles"!
	static restore_modified_tiles = function(_modified_tiles) {
		dlog($"TileScanner restoring {array_length(_modified_tiles)} modified tiles");
		for (var i = 0, len = array_length(_modified_tiles); i < len; i++) {
			var modtile = _modified_tiles[@i];
			var orig = get_tile_at(modtile.position.x, modtile.position.y);
			with (orig) {
				__set_data(modtile.tiledata, modtile.position.x, modtile.position.y, other);
				set_index(index);
				if (empty) set_empty();
				set_flags(tile_get_flip(tiledata), tile_get_rotate(tiledata), tile_get_mirror(tiledata));
				__modified = true;
			}
		}
	}
	#endregion
	
	#region orientation management (private)
	
	/// @func		__tiledata_to_orientation(_tile)
	static __tiledata_to_orientation = function(_tile) {
		var rotate = _tile.rotated ;
		var flip   = _tile.flipped ;
		var mirror = _tile.mirrored;
		
		if ((!rotate && !flip && !mirror) || (!rotate &&  flip && !mirror)) return tile_orientation.right;
		if (( rotate &&  flip &&  mirror) || ( rotate && !flip &&  mirror)) return tile_orientation.up;
		if ((!rotate &&  flip &&  mirror) || (!rotate && !flip &&  mirror)) return tile_orientation.left;
		if (( rotate && !flip && !mirror) || ( rotate &&  flip && !mirror)) return tile_orientation.down;
		// This line should never be reached, but still... who knows
		return tile_orientation.right;
	}
	
	/// @func		__orientation_to_tiledata(_tile, _orientation)
	static __orientation_to_tiledata = function(_tile, _orientation) {
		switch (_orientation) {
			case tile_orientation.right:
				_tile.tiledata = tile_set_rotate(_tile.tiledata, false); _tile.rotated  = false;
				_tile.tiledata = tile_set_flip  (_tile.tiledata, false); _tile.flipped  = false;
				_tile.tiledata = tile_set_mirror(_tile.tiledata, false); _tile.mirrored = false;
				break;
			case tile_orientation.up:
				_tile.tiledata = tile_set_rotate(_tile.tiledata, true);  _tile.rotated  = true;
				_tile.tiledata = tile_set_flip  (_tile.tiledata, true);  _tile.flipped  = true;
				_tile.tiledata = tile_set_mirror(_tile.tiledata, true);  _tile.mirrored = true;
				break;
			case tile_orientation.left:
				_tile.tiledata = tile_set_rotate(_tile.tiledata, false); _tile.rotated  = false;
				_tile.tiledata = tile_set_flip  (_tile.tiledata, true);  _tile.flipped  = true;
				_tile.tiledata = tile_set_mirror(_tile.tiledata, true);  _tile.mirrored = true;			
				break;
			case tile_orientation.down:
				_tile.tiledata = tile_set_rotate(_tile.tiledata, true);  _tile.rotated  = true;
				_tile.tiledata = tile_set_flip  (_tile.tiledata, false); _tile.flipped  = false;
				_tile.tiledata = tile_set_mirror(_tile.tiledata, false); _tile.mirrored = false;
				break;
		}
		return _tile.tiledata;
	}
	#endregion
	
	#region finding tiles
	/// @func	find_tiles(indices...)
	/// @desc	scans the layer for tiles. Specify up to 16 tile indices you want to find
	///			either directly as arguments or specify an array, containing the indices, if
	///			you are looking for more than 16 tiles.
	///			NOTE: If you supply an array, this must be the ONLY argument!
	///	@returns {array}	Returns an array of TileInfo structs.
	static find_tiles = function() {
		var rv = [];
		var indices = argument0;
		if (!is_array(argument0)) {
			indices = array_create(argument_count);
			for (var a = 0, alen = argument_count; a < alen; a++)
				indices[@a] = argument[@a];
		}
		
		for (var i = 0, len = array_length(tiles); i < len; i++)
			if (array_contains(indices, tiles[@i].index)) 
				array_push(rv, tiles[@i]);
		return rv;		
	}
	
	/// @func	find_tiles_in_view(_tiles_array = undefined, _camera_index = 0, _viewport_index = 0)
	/// @desc	Returns only the tiles from the specified _tiles_array, that are currently in view
	///			of the specified camera.
	///			NOTE: if you do not specify a _tiles_array, the internal tiles array of the scanner is used,
	///			which contains all tiles of the level.
	///			But you may also supply a pre-filtered array, like a return value of find_tiles(...)
	///	@returns {array}	Returns an array of TileInfo structs.
	static find_tiles_in_view = function(_tiles_array = undefined, _camera_index = 0) {
		var rv = [];
		_tiles_array = _tiles_array ?? tiles;
		macro_camera_viewport_index_switch_to(_camera_index, VIEWPORT_INDEX);
		var camrect = new Rectangle(CAM_LEFT_EDGE, CAM_TOP_EDGE, CAM_WIDTH, CAM_HEIGHT);
		var tile = undefined;
		for (var i = 0, len = array_length(_tiles_array); i < len; i++) {
			tile = _tiles_array[@i];
			if (camrect.intersects_point(tile.center_px.x, tile.center_px.y))
				array_push(rv, tile);
		}
		macro_camera_viewport_index_switch_back();
		return rv;
	}
	
	/// @func get_tile_at(map_x, map_y)
	/// @desc Gets the TileInfo object at the specified map coordinates.
	///				 To get a tile from pixel coordinates, use get_tile_at_px(...)
	static get_tile_at = function(map_x, map_y) {
		var idx = map_y * map_width + map_x;
		if (idx >= 0 && idx < array_length(tiles))
			return tiles[@idx];
		return undefined;
	}
	
	/// @func get_tile_at_px(_x, _y)
	/// @desc Gets the TileInfo object at the specified pixel coordinates.
	///				 To get a tile from map coordinates, use get_tile_at(...)
	static get_tile_at_px = function(_x, _y) {
		var map_x = floor(_x / cell_width);
		var map_y = floor(_y / cell_height);
		return get_tile_at(map_x, map_y);
	}
	#endregion
	
	#region manipulating maps

	/// @func	fill_map(_index = 0) 
	/// @desc	Clears the entire layer, all tiles get the specified _index
	static fill_map = function(_index = 0) {
		gml_pragma("forceinline");
		fill_area(_index, 0, 0, map_width, map_height);
	}
	
	/// @func	fill_area(_index, _left, _top, _width, _height) 
	/// @desc	Fills an area in map coordinates in the layer with a specified tile index
	static fill_area = function(_index, _left, _top, _width, _height) {
		var tile;
		for (var yp = _top; yp < _top + _height; yp++) {
			for (var xp = _left; xp < _left + _width; xp++) {
				tile = get_tile_at(xp, yp);
				if (tile != undefined) tile.set_index(_index);
			}
		}
	}

	/// @func	fill_area_px(_index, _left, _top, _width, _height) 
	/// @desc	Fills an area in pixel coordinates in the layer with a specified tile index
	///			NOTE: ALL coordinates are in px here! Even _width and _height!
	static fill_area_px = function(_index, _left, _top, _width, _height) {
		fill_area(_index,
			floor(_left / cell_width),
			floor(_top  / cell_height),
			ceil (_width / cell_width),
			ceil (_height / cell_height)
		);
	}
	
	#endregion
}

#macro __TILESCANNER_UPDATE_TILE	tilemap_set(scanner.map_id, tiledata, position.x, position.y);
/// @func		TileInfo()
/// @desc	Holds condensed information about a single tile
function TileInfo() constructor {
	construct(TileInfo);
	
	__modified = false;
	
	/// @func		__set_data(_tiledata, _map_x, _map_y, _scanner)
	/// @desc	Wrap this in a function to have an empty constructor for the savegame system
	static __set_data = function(_tiledata, _map_x, _map_y, _scanner) {
		scanner		= _scanner;
		tiledata	= _tiledata;
		index		= tile_get_index(_tiledata);
		rotated		= tile_get_rotate(tiledata);
		flipped		= tile_get_flip(tiledata);
		mirrored	= tile_get_mirror(tiledata);
		orientation = scanner.__tiledata_to_orientation(self);
		empty		= (index <= 0);
		position	= new Coord2(_map_x, _map_y);
		position_px = new Coord2(_map_x * scanner.cell_width, _map_y * scanner.cell_height);
		center_px	= position_px.clone2().add(scanner.cell_width / 2, scanner.cell_height / 2);
		return self;
	}

	/// @func	is_empty()
	static is_empty = function() {
		gml_pragma("forceinline");
		return index <= 0;
	}
	
	/// @func set_empty()
	/// @desc Clears this tile
	static set_empty = function() {
		__modified = true;
		empty = true;
		index = 0;
		orientation = tile_orientation.right;
		tiledata = tile_set_empty(tiledata);
		__TILESCANNER_UPDATE_TILE;
		return self;
	}

	/// @func	get_index()
	static get_index = function() {
		gml_pragma("forceinline");
		return index;
	}

	/// @func set_index(_tile_index)
	/// @desc Assign a new index to the tile
	static set_index = function(_tile_index) {
		__modified	= true;
		index		= _tile_index;
		empty		= (index <= 0);
		tiledata	= tile_set_index(tiledata, _tile_index);
		__TILESCANNER_UPDATE_TILE;
		return self;
	}

	/// @func set_flags(_flip = undefined, _rotate = undefined, _mirror = undefined)
	/// @desc Modify the flags of a tile (flip, rotate, mirror)
	static set_flags = function(_flip = undefined, _rotate = undefined, _mirror = undefined) {
		__modified = true;
		if (_flip     != undefined) tiledata = tile_set_flip(tiledata, _flip);
		if (_rotate   != undefined) tiledata = tile_set_rotate(tiledata, _rotate);
		if (_mirror   != undefined) tiledata = tile_set_mirror(tiledata, _mirror);
		orientation = scanner.__tiledata_to_orientation(self);
		__TILESCANNER_UPDATE_TILE;
		return self;
	}
	
	/// @func	is_flipped()
	///	@desc	Returns whether this tile has the "flip" flag set
	static is_flipped = function() {
		return flipped;
	}
	
	/// @func	is_mirrored()
	///	@desc	Returns whether this tile has the "mirror" flag set
	static is_mirrored = function() {
		return mirrored;
	}
	
	/// @func	is_rotated()
	///	@desc	Returns whether this tile has the "rotate" flag set
	static is_rotated = function() {
		return rotated;
	}
	
	/// @func set_orientation(_tile_orientation)
	/// @desc Rotate a tile to a specified orientation
	static set_orientation = function(_tile_orientation) {
		__modified = true;
		orientation = _tile_orientation;
		tiledata	= scanner.__orientation_to_tiledata(self, _tile_orientation);
		__TILESCANNER_UPDATE_TILE;
		return self;
	}
	
}