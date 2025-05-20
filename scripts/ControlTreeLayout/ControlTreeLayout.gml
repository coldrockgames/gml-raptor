/*
    This class is attached to data._layout on each _baseControl when it gets added as a child
*/

/// @func ControlTreeLayout()
function ControlTreeLayout() constructor {
	construct(ControlTreeLayout);

	docking		= dock.none;
	valign      = fa_top;
	halign      = fa_left;
	have_align	= false;
	spreadx		= -1;
	spready		= -1;
	xpos		=  0;
	ypos		=  0;
	xpos_align	=  undefined;
	ypos_align	=  undefined;
	
	anchoring	= anchor.none;
	anchor_init = {
		init		: false,
		dist_top	: 0,
		dist_left	: 0,
		dist_right	: 0,
		dist_bottom	: 0
	};
	anchor_now  = {
		delta_top	: 0,
		delta_left	: 0,
		delta_right	: 0,
		delta_bottom: 0,
		width		: 0,
		height		: 0,
		anch_top	: false,
		anch_left	: false,
		anch_right	: false,
		anch_bottom	: false
	};
		
	__filler		= new Coord2();

#region Positioning
	/// @func apply_positioning(_area, _inst, _control, _reset_align_state = true)
	static apply_positioning = function(_area, _inst, _control, _reset_align_state = true) {
		if (docking != dock.none)
			return;
		
		var tree = _control.control_tree;
		
		if (xpos_align != undefined && ypos_align != undefined) {
			var havebefore	= have_align;
			var vbefore		= valign;
			var hbefore		= halign;
			
			have_align = true;
			valign = ypos_align;
			halign = xpos_align;
			apply_spreading(_area, _inst, _control);
			apply_alignment(_area, _inst, _control);
			xpos = _inst.x - (_area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset);
			ypos = _inst.y - (_area.top + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset);
			
			have_align	= havebefore;
			valign		= vbefore;
			halign		= hbefore;
			
			// delete the markers, we do this only once!
			if (_reset_align_state) {
				xpos_align = undefined;
				ypos_align = undefined;
			}
		}
		
		_inst.x = _area.left + xpos + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.top + ypos + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
	}
	
#endregion

#region Docking
	/// @func apply_docking(_area, _inst, _control)
	static apply_docking = function(_area, _inst, _control) {
		var neww = _inst.sprite_width;
		var newh = _inst.sprite_height;
		
		switch (docking) {
			case dock.none:		return;
			case dock.left:		newh = __apply_dock_left	(_area, _inst, _control); break;
			case dock.right:	newh = __apply_dock_right	(_area, _inst, _control); break;
			case dock.top:		neww = __apply_dock_top		(_area, _inst, _control); break;
			case dock.bottom:	neww = __apply_dock_bottom	(_area, _inst, _control); break;
			case dock.fill:
				__apply_dock_fill(_area, _inst, _control, __filler);
				neww = __filler.x;
				newh = __filler.y;
				break;
		}
		
		with (_inst)
			scale_sprite_to(neww, newh);
	}
	
	static __apply_dock_top = function(_area, _inst, _control) {
		var tree = _control.control_tree;
		var runner = tree.runner;
		
		var neww = _area.width - 
				tree.margin_left - tree.margin_right -
				tree.padding_left - tree.padding_right;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.top  + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				
		var areadiff = max(_inst.min_height, _inst.sprite_height + tree.padding_top + tree.padding_bottom) + 
			tree.margin_top + tree.margin_bottom;
				
		runner.top += areadiff;
		_area.top += areadiff;
		_area.height = max(0, _area.height - areadiff);
		
		return neww;
	}
	
	static __apply_dock_bottom = function(_area, _inst, _control) {
		var tree = _control.control_tree;
		var runner = tree.runner;
		
		var neww = _area.width - 
				tree.margin_left - tree.margin_right -
				tree.padding_left - tree.padding_right;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		
		var opp = (runner.bottom == _area.get_bottom() ? 0 :
					tree.margin_top + tree.padding_top);		
		_inst.y = _area.get_bottom() - opp -
			tree.margin_bottom - tree.padding_bottom - 
			_inst.sprite_height - _inst.sprite_yoffset;
				
		var areadiff = max(_inst.min_height, _inst.sprite_height + tree.padding_top + tree.padding_bottom) + 
			tree.margin_top + tree.margin_bottom;
				
		runner.bottom = max(0, runner.bottom - areadiff);
		_area.height = max(0, _area.height - areadiff);

		return neww;
	}

	static __apply_dock_left = function(_area, _inst, _control) {
		var tree = _control.control_tree;
		var runner = tree.runner;
		
		var newh = _area.height - 
				tree.margin_top - tree.margin_bottom -
				tree.padding_top - tree.padding_bottom;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.top  + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				
		var areadiff = max(_inst.min_width, _inst.sprite_width + tree.padding_left + tree.padding_right) + 
			tree.margin_left + tree.margin_right;

		runner.left += areadiff;
		_area.left += areadiff;
		_area.width = max(0, _area.width - areadiff);

		return newh;
	}

	static __apply_dock_right = function(_area, _inst, _control) {
		var tree = _control.control_tree;
		var runner = tree.runner;

		var newh = _area.height - 
				tree.margin_top - tree.margin_bottom -
				tree.padding_top - tree.padding_bottom;

		var opp = (runner.right == _area.get_right() ? 0 :
					tree.margin_left + tree.padding_left);
		_inst.x = _area.get_right() - opp -
			tree.margin_right - tree.padding_right - 
			_inst.sprite_width - _inst.sprite_xoffset;
			
		_inst.y = _area.top + tree.margin_top + tree.padding_top + _inst.sprite_yoffset;
				
		var areadiff = max(_inst.min_width, _inst.sprite_width + tree.padding_left + tree.padding_right) + 
			tree.margin_left + tree.margin_right;
		
		runner.right = max(0, runner.right - areadiff);
		_area.width = max(0, _area.width - areadiff);

		return newh;
	}
	
	static __apply_dock_fill = function(_area, _inst, _control, rv = undefined) {
		rv ??= new Coord2();
		var neww = _inst.sprite_width;
		var newh = _inst.sprite_height;
		var tree = _control.control_tree;
		
		// left
		var neww = _area.width - 
				tree.margin_left - tree.margin_right -
				tree.padding_left - tree.padding_right;
				
		var newh = _area.height - 
				tree.margin_top - tree.margin_bottom -
				tree.padding_top - tree.padding_bottom;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.top  + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				
		// dock fill does NOT modify the area!
		// it just sizes its content to the entire remaining area

		rv.set(neww, newh);

		return rv;
	}

#endregion

#region Alignment
	/// @func apply_alignment(_inst, _control)
	static apply_alignment = function(_area, _inst, _control) {
		if (docking != dock.none || !have_align)
			return; // we can only align if we are the master of our size
			
		var tree = _control.control_tree;
		_control.update_client_area();

		// The switches here ignore fa_top and fa_left because this is "runner-style" and
		// has already been set by the layout() function of the tree.
		// We only care about middle/center/right/bottom here as this function gets invoked
		// AFTER the final size of the instance is set
		switch (valign) {
			case fa_top:
				_inst.y = ypos + _area.top + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				break;
			case fa_middle:
				_inst.y = ypos + _area.top + _area.height / 2 - _inst.sprite_height / 2;
				break;
			case fa_bottom:
				var dist = _inst.sprite_height + tree.margin_bottom + tree.padding_bottom;
				_inst.y = ypos + _area.get_bottom() - dist + 1;
				break;
		}
		switch (halign) {
			case fa_left:
				_inst.x = xpos + _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
				break;
			case fa_center:
				_inst.x = xpos + _area.left + _area.width / 2 - _inst.sprite_width / 2;
				break;
			case fa_right:
				var dist = _inst.sprite_width + tree.margin_right + tree.padding_right;
				_inst.x = xpos + _area.get_right() - dist + 1;
				break;
		}
	}
#endregion

#region Anchoring
	#macro __RAPTOR_ANCHOR_DIST_TOP		(SELF_VIEW_TOP_EDGE - _area.top)
	#macro __RAPTOR_ANCHOR_DIST_LEFT	(SELF_VIEW_LEFT_EDGE - _area.left)
	#macro __RAPTOR_ANCHOR_DIST_RIGHT	(_area.get_right()  - SELF_VIEW_RIGHT_EDGE - 1)
	#macro __RAPTOR_ANCHOR_DIST_BOTTOM	(_area.get_bottom() - SELF_VIEW_BOTTOM_EDGE - 1)

	/// @func apply_anchoring(_area, _inst, _control)
	static apply_anchoring = function(_area, _inst, _control) {
		if (docking != dock.none || anchoring == anchor.none)
			return; // we can only align if we are the master of our size
		
		if (!anchor_init.init)
			initialize_anchoring(_area, _inst, _control);
			
		anchor_now.anch_top		= ((anchoring & anchor.top)		== anchor.top	);	
		anchor_now.anch_left	= ((anchoring & anchor.left)	== anchor.left	);	
		anchor_now.anch_right	= ((anchoring & anchor.right)	== anchor.right	);
		anchor_now.anch_bottom	= ((anchoring & anchor.bottom)	== anchor.bottom);

		with (_inst) {
			other.anchor_now.delta_top		= (__RAPTOR_ANCHOR_DIST_TOP	   - other.anchor_init.dist_top		);
			other.anchor_now.delta_left		= (__RAPTOR_ANCHOR_DIST_LEFT   - other.anchor_init.dist_left	);
			other.anchor_now.delta_right	= (__RAPTOR_ANCHOR_DIST_RIGHT  - other.anchor_init.dist_right	);
			other.anchor_now.delta_bottom	= (__RAPTOR_ANCHOR_DIST_BOTTOM - other.anchor_init.dist_bottom	);
			other.anchor_now.width			= sprite_width;
			other.anchor_now.height			= sprite_height;
		}
		
		//vlog($"Anchor delta TLRB: {anchor_now.delta_top} {anchor_now.delta_left} {anchor_now.delta_right} {anchor_now.delta_bottom}");		
		
		if (anchor_now.anch_left && anchor_now.anch_right) {
			_inst.x -= (anchor_now.delta_left + anchor_now.delta_right) / 2;
			anchor_now.width += anchor_now.delta_left + anchor_now.delta_right;
		} else if (anchor_now.anch_left) {
			_inst.x -= anchor_now.delta_left;			
		} else if (anchor_now.anch_right) {
			_inst.x += anchor_now.delta_right;
		}
		
		if (anchor_now.anch_top && anchor_now.anch_bottom) {
			_inst.y -= (anchor_now.delta_top + anchor_now.delta_bottom) / 2;
			anchor_now.height += anchor_now.delta_top + anchor_now.delta_bottom;
		} else if (anchor_now.anch_top) {
			_inst.y -= anchor_now.delta_top;
		} else if (anchor_now.anch_bottom) {
			_inst.y += anchor_now.delta_bottom;
		}
		
		with(_inst) {
			scale_sprite_to(other.anchor_now.width, other.anchor_now.height);
		}
	}
	
	/// @func initialize_anchoring(_area, _inst, _control, _into)
	static initialize_anchoring = function(_area, _inst, _control) {
		if (anchor_init.init) return;
		anchor_init.init = true;
		
		// Initialization means: Measure the distance to each border.
		// How much the size changes, is done by the apply_anchoring method
		// This one here just measures
		with (_inst) {
			other.anchor_init.dist_top		= __RAPTOR_ANCHOR_DIST_TOP;
			other.anchor_init.dist_left		= __RAPTOR_ANCHOR_DIST_LEFT;
			other.anchor_init.dist_right	= __RAPTOR_ANCHOR_DIST_RIGHT;
			other.anchor_init.dist_bottom	= __RAPTOR_ANCHOR_DIST_BOTTOM;
		}		
		
		//vlog($"Anchor Init INST: {_inst.x}+{_inst.sprite_xoffset}+{_inst.sprite_width} {_inst.y}+{_inst.sprite_yoffset}+{_inst.sprite_height}");
		//vlog($"Anchor Init AREA: {_area.left} {_area.top} {_area.get_right()} {_area.get_bottom()}");
		//vlog($"Anchor Init TLRB: {anchor_init.dist_top} {anchor_init.dist_left} {anchor_init.dist_right} {anchor_init.dist_bottom}");
	}
	
#endregion

#region Spreading
	/// @func apply_spreading(_area, _inst, _control)
	static apply_spreading = function(_area, _inst, _control) {
		if (docking != dock.none || anchoring != anchor.none)
			return; // we can only spread if we are the master of our size

		var tree = _control.control_tree;

		_control.update_client_area();
		
		if (spreadx != -1) {
			var netto = max(_inst.min_width, spreadx * (_area.width - 
				tree.margin_left  - tree.margin_right - 
				tree.padding_left - tree.padding_right));
			with(_inst) 
				scale_sprite_to(netto, sprite_height);
		}
		if (spready != -1) {
			var netto = max(_inst.min_height, spready * (_area.height -
				tree.margin_top  - tree.margin_bottom - 
				tree.padding_top - tree.padding_bottom));
			with(_inst) 
				scale_sprite_to(sprite_width, netto);
		}
	}
#endregion

}
