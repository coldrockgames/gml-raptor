/*
    This is a chainable, hierarchical tree of controls that are
	anchored and docked to each other.
*/

enum dock {
	none, right, top, left, bottom, fill
}

enum anchor {
	none		= 0,
	right		= 1,
	top			= 2,
	left		= 4,
	bottom		= 8,
	all_sides	= 15
}

function ControlTree(
	_control = undefined, _parent_tree = undefined, 
	_margin = undefined, _padding = undefined) : BindableDataBuilder() constructor {
	construct(ControlTree);
	
	// This is the control, the tree is bound to. Gets set in Create of _baseContainerControl
	control				= _control;
	controls			= {};

	// if the parent_tree is undefined, this means, it's the top-level tree
	// ONLY the top-level tree invokes layout() when the control moves or changes size,
	// so the hierarchy is processed only once
	parent_tree			= _parent_tree;
	children			= [];
	
	margin_left			= _margin ?? 0;
	margin_top			= _margin ?? 0;
	margin_right		= _margin ?? 0;
	margin_bottom		= _margin ?? 0;
	
	padding_left		= _padding ?? 0;
	padding_top			= _padding ?? 0;
	padding_right		= _padding ?? 0;
	padding_bottom		= _padding ?? 0;

	render_area			= new Rectangle(); // client area minus all applied dockings (= free undocked render space)
	reorder_docks		= true;

	// holds rendering coordinates
	runner  = {
		left:	0,
		top :	0,
		right:	0,
		bottom: 0
	}
	
	__last_instance		= undefined;
	__last_container	= undefined;
	__last_entry		= undefined;
	__last_layout		= undefined;
	__root_tree			= self;
	__force_next		= false;
	__layout_done		= false;
	__alive				= true; // used for cleanup

	__on_shown_done		= false;
	__on_shown			= [];
	__on_opened			= [];
	__on_closed			= [];

	/// @func bind_to(_control)
	static bind_to = function(_control) {
		if (!is_child_of(_control, _baseContainerControl))
			throw("Binding target of a ControlTree must be a _baseContainerControl (Window, Panel, ...)!");
			
		control = _control;
		return self;
	}
	
	/// @func get_root_control()
	static get_root_control = function() {
		return __root_tree.control;
	}
	
	/// @func get_root_tree()
	static get_root_tree = function() {
		return __root_tree;
	}
	
	/// @func is_root_tree()
	static is_root_tree = function() {
		return (__root_tree == self);
	}
	
	/// @func get_instance()
	static get_instance = function() {
		return __last_instance;
	}
	
	/// @func set_margin_all(_margin)
	static set_margin_all = function(_margin) {
		set_margin(_margin, _margin, _margin, _margin);
		return self;
	}
	
	/// @func set_margin(_margin_left, _margin_top, _margin_right, _margin_bottom)
	static set_margin = function(_margin_left, _margin_top, _margin_right, _margin_bottom) {
		margin_left		= _margin_left;
		margin_top		= _margin_top;
		margin_right	= _margin_right;
		margin_bottom	= _margin_bottom;
		return self;
	}
	
	/// @func set_padding_all(_padding)
	static set_padding_all = function(_padding) {
		set_padding(_padding, _padding, _padding, _padding);
		return self;
	}
	
	/// @func set_padding(_padding_left, _padding_top, _padding_right, _padding_bottom)
	static set_padding = function(_padding_left, _padding_top, _padding_right, _padding_bottom) {
		padding_left	= _padding_left;
		padding_top		= _padding_top;
		padding_right	= _padding_right;
		padding_bottom	= _padding_bottom;
		return self;
	}
	
	/// @func add_control(_objtype, _init_struct = undefined)
	static add_control = function(_objtype, _init_struct = undefined) {
		// a new control can affect the whole render tree, so force redraw next frame
		__force_next = true;
		
		var inst = instance_create(-100000, -100000, layer_of(control), _objtype, _init_struct);
		//var inst = instance_create(control.x, control.y, layer_of(control), _objtype, _init_struct);
		if (!is_child_of(inst, _baseControl)) {
			instance_destroy(inst);
			throw("ControlTree accepts only raptor controls (child of _baseControl) as children!");
		}
		inst.__container = control;
		inst.draw_on_gui = control.draw_on_gui;
		inst.autosize = false;
		inst.control_tree_layout = new ControlTreeLayout();
		inst.control_tree_layout.xpos = -control.sprite_xoffset;
		inst.control_tree_layout.ypos = -control.sprite_yoffset;

		__last_entry = new ControlTreeEntry(inst);
		array_push(children, __last_entry);
		
		vlog($"Control {name_of(inst)} added to tree of {name_of(control)}");
		
		__last_instance = inst;
		if (is_child_of(inst, _baseContainerControl)) {
			inst.control_tree.parent_tree = self;
			inst.control_tree.__root_tree = __root_tree;
			inst.control_tree.__last_layout = inst.control_tree_layout;
			inst.control_tree.__last_entry = __last_entry;
			inst.control_tree.__last_container = self;
			return inst.control_tree;
		} else {
			__last_container = undefined;
			__last_layout = inst.control_tree_layout;
			return self;
		}
	}
	
	/// @func add_sprite(_sprite_asset, _init_struct = undefined)
	/// @desc Adds a sprite to the tree. Internally this is wrappend
	///				 in a ControlTreeSprite object, which is a _baseControl,
	///				 so you can use the _init_struct freely to assign all
	///				 variables, you'd like to change, from image_angle, scale,
	///				 blend_color, plus everything a _baseControl has in stock!
	///				 In addition, you can align, anchor, dock it as you would 
	///				 with any other control.
	static add_sprite = function(_sprite_asset, _init_struct = undefined) {
		var str = if_null(_init_struct, {});
		str.sprite_index = _sprite_asset;
		str.text		 = "";
		return add_control(ControlTreeSprite, str);
	}
	
	/// @func remove_control(_control_or_name)
	static remove_control = function(_control_or_name) {
		var strcompare = is_string(_control_or_name);
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child		= children[@i];
			var inst		= child.instance;
			if ((strcompare && eq(_control_or_name, child.name)) ||
				(!strcompare && eq(_control_or_name, inst))) {
				struct_remove(controls, child.name);
				array_delete(children, i, 1);
				vlog($"Removed {name_of(inst)} from tree of {name_of(control)}");
				break;
			}
		}
		return self;
	}
	
	/// @func bind_pull(_my_property, _source_instance, _source_property, _converter = undefined, _on_value_changed = undefined)
	static bind_pull = function(_my_property, _source_instance, _source_property, 
						   _converter = undefined, _on_value_changed = undefined) {
		with(__last_instance.binder) 
			bind_pull(_my_property, _source_instance, _source_property, _converter, _on_value_changed);
			
		return self;
	}

	/// @func bind_push(_my_property, _target_instance, _target_property, _converter = undefined, _on_value_changed = undefined)
	static bind_push = function(_my_property, _target_instance, _target_property, 
						   _converter = undefined, _on_value_changed = undefined) {	
		with(__last_instance.binder) 
			bind_push(_my_property, _target_instance, _target_property, _converter, _on_value_changed);
			
		return self;
	}
	
	/// @func bind_watcher(_my_property, _on_value_changed)
	///	@description The callback receives two arguments: (new_value, old_value)
	static bind_watcher = function(_my_property, _on_value_changed) {
		with(__last_instance.binder) 
			bind_watcher(_my_property, _on_value_changed);
			
		return self;
	}
	
	/// @func set_position(_xpos, _ypos, _relative = false)
	/// @desc Sets an absolute position in the client area of the parent control,
	///              unless you set _relative to true, then the values are just added to the
	///				 currently set xpos and ypos
	static set_position = function(_xpos, _ypos, _relative = false) {
		if (_relative) {
			__last_layout.xpos += _xpos;
			__last_layout.ypos += _ypos;
		} else {
			__last_layout.xpos = _xpos;
			__last_layout.ypos = _ypos;
		}
		return self;
	}
	
	/// @func set_position_from_align(_valign, _halign, _xoffset = 0, _yoffset = 0)
	static set_position_from_align = function(_valign, _halign, _xoffset = 0, _yoffset = 0) {
		__last_layout.xpos += _xoffset;
		__last_layout.ypos += _yoffset;
		__last_layout.xpos_align = _halign;
		__last_layout.ypos_align = _valign;
		return self;
	}
	
	/// @func set_spread(_spreadx = -1, _spready = -1)
	static set_spread = function(_spreadx = -1, _spready = -1) {
		__last_layout.spreadx = _spreadx;
		__last_layout.spready = _spready;
		return self;
	}
	
	/// @func set_dock(_dock)
	static set_dock = function(_dock) {
		__last_layout.docking = _dock;
		__last_layout.docking_reverse = (_dock == dock.right || _dock == dock.bottom);
		return self;
	}
	
	/// @func set_reorder_docks(_reorder)
	/// @desc True by default. Reorder dock means a more "natural" feeling of
	///				 adding right- and bottom docked elements.
	///				 When you design a form, you think "left-to-right" and "top-to-bottom",
	///				 so you likely want to appear the first bottom added ABOVE the second bottom
	///				 If you do not want that, just turn reorder off.
	static set_reorder_docks = function(_reorder) {
		reorder_docks = _reorder;
		return self;
	}
	
	/// @func set_align(_valign = fa_top, _halign = fa_left, _xoffset = 0, _yoffset = 0)
	static set_align = function(_valign = fa_top, _halign = fa_left, _xoffset = 0, _yoffset = 0) {
		__last_layout.xpos += _xoffset;
		__last_layout.ypos += _yoffset;
		__last_layout.valign	 = _valign;
		__last_layout.halign	 = _halign;
		__last_layout.have_align = true;
		return self;
	}
	
	/// @func remove_align()
	static remove_align = function() {
		__last_layout.have_align = false;
		return self;
	}
	
	/// @func set_anchor(_anchor)
	static set_anchor = function(_anchor) {
		__last_layout.anchoring = _anchor;
		return self;
	}
	
	/// @func set_name(_name)
	/// @desc Give a child control a name to retrieve it later through get_element(_name)
	static set_name = function(_name) {
		if (__last_container != undefined) {
			__last_container.__last_entry.name = _name;
			__last_container.__last_entry.instance.name = _name;
			__last_container.controls[$ _name] = __last_container.__last_entry.instance;
		} else {
			__last_entry.name = _name;
			__last_entry.instance.name = _name;
			controls[$ _name] = __last_entry.instance;
		}
		return self;
	}

	/// @func select_element(_control_or_name)
	/// @desc Searches through the tree for the specified control
	///				 and sets it as the active element, if found.
	///				 "Active element" means, all ".set_*" function will apply to it
	///				 NOTE: This function throws an exception if the control is not in the tree!
	static select_element = function(_control_or_name) {
		var found = false;
		var strcompare = is_string(_control_or_name);
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child		= children[@i];
			var inst		= child.instance;
			var ilayout		= inst.control_tree_layout;
			
			if ((strcompare && eq(_control_or_name, child.name)) ||
				(!strcompare && eq(_control_or_name, inst))) {
				found = true;
				__last_instance = inst;
				__last_layout	= ilayout;
				__last_entry	= child;
				vlog($"Selected control {name_of(inst)}{(child.name != "" ? $" ({child.name})" : "")} as active tree control");
				break;
			}
		}
		if (!found) 
			throw($"Control '{name_of(_control)}' not found in tree of '{name_of(control)}'!");
	}

	/// @func	set_visible(_visible)
	/// @desc	Sets the visible state for this and all children
	static set_visible = function(_visible) {
		control.visible = _visible;
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child	= children[@i];
			var inst	= child.instance;
			
			if (is_child_of(inst, _baseContainerControl)) {
				inst.control_tree.set_visible(_visible);
			}
			inst.visible = _visible;
		}
		return self;
	}

	/// @func	set_enabled(_enabled)
	/// @desc	Sets the enabled state for this and all children
	static set_enabled = function(_enabled) {
		control.set_enabled(_enabled);
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child	= children[@i];
			var inst	= child.instance;
			
			if (is_child_of(inst, _baseContainerControl)) {
				inst.control_tree.set_enabled(_enabled);
			}
			inst.set_enabled(_enabled);
		}
		return self;
	}

	/// @func get_element(_name)
	/// @desc Retrieve a child control by its name. Returns the instance or undefined
	static get_element = function(_name) {
		var rv = undefined;
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			if (child.name == _name)
				rv = child.instance;
			else if (is_child_of(child.instance, _baseContainerControl))
				rv = child.instance.control_tree.get_element(_name);
			if (rv != undefined) 
				return rv;
		}
		return undefined;
	}

	/// @func get_element_name(_control)
	/// @desc Retrieve a child control's name by its instance pointer. Returns the name or undefined
	static get_element_name = function(_control) {
		var rv = undefined;
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			if (child.instance == _control)
				rv = child.name;
			else if (is_child_of(child.instance, _baseContainerControl))
				rv = child.instance.control_tree.get_element_name(child.instance);
			if (rv != undefined) 
				return rv;
		}
		return undefined;
	}
	
	/// @func step_out()
	static step_out = function() {
		return parent_tree??self;
	}
	
	/// @func build()
	static build = function() {
		try {
			with(__root_tree.control) {
				animation_abort(self, "##__raptor_##.control_tree_build", false);
				run_delayed(self, 1, function() { 
					if (control_tree.__alive)
						control_tree.layout(true); 
				})
				.set_name("##__raptor_##.control_tree_build");
			}
			__on_shown_done = false;
		} catch (_) {}
		return self;
	}
	
	/// @func on_window_opened(_callback)
	static on_window_opened = function(_callback) {
		array_push(__on_opened, _callback);
		return self;
	}
	
	/// @func on_window_closed(_callback)
	static on_window_closed = function(_callback) {
		array_push(__on_closed, _callback);
		return self;
	}

	/// @func	on_shown()
	/// @desc	Occurs once after first draw event
	static on_shown = function(_callback) {
		array_push(__on_shown, _callback);
		return self;
	}

	/// @func	invoke_on_shown()
	static invoke_on_shown = function() {
		if (!__on_shown_done) {
			__on_shown_done = true;
			if (array_length(__on_shown) > 0) {
				dlog($"Invoking on_shown callback for {name_of(control)}");
				for (var i = 0, len = array_length(__on_shown); i < len; i++) {
					__on_shown[@i](control);
				}
			}
		}
		return self;
	}

	/// @func invoke_on_opened()
	static invoke_on_opened = function() {
		if (array_length(__on_opened) > 0) {
			dlog($"Invoking on_window_opened callback for {name_of(control)}");
			for (var i = 0, len = array_length(__on_opened); i < len; i++) {
				__on_opened[@i](control);
			}
		}
		return self;
	}
	
	/// @func invoke_on_closed()
	static invoke_on_closed = function() {
		if (array_length(__on_closed) > 0) {
			dlog($"Invoking on_window_closed callback for {name_of(control)}");
			for (var i = 0, len = array_length(__on_closed); i < len; i++) {
				__on_closed[@i](control);
			}
		}
		return self;
	}

	/// @func layout(_forced = false)
	/// @desc	performs layouting of all child controls. Invoked when the control
	///					changes its size or position.
	///					also calls layout() on all children
	static layout = function(_forced = false) {
		if (!__alive) return self;
		
		update_render_area();
		
		runner.left		= render_area.left;
		runner.top		= render_area.top ;
		runner.right	= render_area.get_right();
		runner.bottom	= render_area.get_bottom();
		
		var child		= undefined;
		var inst		= undefined;
		var ilayout		= undefined;
		var oldinstx	= 0;
		var oldinsty	= 0;
		var oldsizex	= 0;
		var oldsizey	= 0;
		var auto_width	= 0;
		var auto_height	= 0;
		var cur_width	= 0;
		var cur_height	= 0;
		
		_forced |= __force_next;
		__force_next = false;
		
		for (var i = 0, len = array_length(children); i < len; i++) {			
			child		= children[@i];
			inst		= child.instance;
			ilayout		= inst.control_tree_layout;
			oldinstx	= inst.x;
			oldinsty	= inst.y;
			oldsizex	= inst.sprite_width;
			oldsizey	= inst.sprite_height;
			
			if (_forced) inst.force_redraw();
			
			if (is_child_of(inst, _baseContainerControl)) {
				inst.control_tree.layout(_forced);
				inst.update_client_area();
			}

			// kind of "test-try" position controls so we get autosize values...
			if (control.__auto_size_with_content) {
				ilayout.apply_positioning(render_area, inst, control, false);
				cur_width  = max(control.min_width,  control.sprite_width,  ilayout.xpos + inst.sprite_width);
				cur_height = max(control.min_height, control.sprite_height, ilayout.ypos + inst.sprite_height);
				if (cur_width > auto_width || cur_height > auto_height) {
					auto_width  = min(cur_width,  if_null(parent_tree, self).render_area.width);
					auto_height = min(cur_height, if_null(parent_tree, self).render_area.height);
					with(control) {
						scale_sprite_to(auto_width, auto_height);
						update_client_area();
					}
					update_render_area();
				}
			}
			
			// ... then do the real thing
			ilayout.apply_positioning(render_area, inst, control);
			ilayout.apply_docking	 (render_area, inst, control);
			ilayout.apply_spreading  (render_area, inst, control);
			ilayout.apply_alignment  (render_area, inst, control);
			ilayout.apply_anchoring  (render_area, inst, control);
		}
		
		if (reorder_docks) {
			__reorder_bottom_dock();
			__reorder_right_dock();
		}
		
		// if anything in our size or position changed, force update of the text display to avoid rubberbanding
		if (inst != undefined && 
			(inst.x != oldinstx || inst.y != oldinsty || 
			 inst.sprite_width != oldsizex || inst.sprite_height != oldsizey)) {
				inst.force_redraw();
				inst.__draw_self();
		}
		return self;
	}

	/// @func update_render_area()
	static update_render_area = function() {
		render_area.set(
			control.x + control.data.__raptordata.client_area.left, 
			control.y + control.data.__raptordata.client_area.top , 
			control.data.__raptordata.client_area.width, 
			control.data.__raptordata.client_area.height
		);
	}

	static __reorder_bottom_dock = function() {
		var dtop = render_area.get_bottom();
		var bottoms = [];
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child		= children[@i];
			var inst		= child.instance;
			if (inst.control_tree_layout.docking == dock.bottom)
				array_push(bottoms, inst);
		}
		while (array_length(bottoms) > 0) {
			var inst = array_shift(bottoms);
			inst.y = dtop + margin_top + padding_top + 1;
			dtop += inst.sprite_height + margin_bottom + padding_bottom;
		}
	}
	
	static __reorder_right_dock = function() {
		var dright = render_area.get_right();
		var rights = [];
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child		= children[@i];
			var inst		= child.instance;
			if (inst.control_tree_layout.docking == dock.right)
				array_push(rights, inst);
		}
		while (array_length(rights) > 0) {
			var inst = array_shift(rights);
			inst.x = dright + margin_left + padding_left + 1;
			dright += inst.sprite_width + margin_right + padding_right;
		}
	}

	__child_looper = undefined;
	static draw_children = function() {
		if (__force_next) {
			layout();
			__layout_done = true;
			__force_next = false;
		}
		for (var i = 0, len = array_length(children); i < len; i++) {
			__child_looper = children[@i];
			if (__child_looper.instance.visible) __child_looper.instance.__draw_instance();
			__child_looper.instance.depth = __root_tree.control.depth - 1; // set AFTER first draw! (gms draw chain... trust me)
		}
		
		if (!__on_shown_done) invoke_on_shown();
	}
	
	static update_children_depth = function() {
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child	= children[@i];
			var inst	= child.instance;
			
			if (is_child_of(inst, _baseContainerControl)) {
				inst.control_tree.update_children_depth();
			}
			inst.depth = __root_tree.control.depth - 1;
		}
	}
	
	/// @func move_children(_by_x, _by_y)
	static move_children = function(_by_x, _by_y) {
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			var inst = child.instance;
			inst.x += _by_x;
			inst.y += _by_y;
			inst.__text_x += _by_x;
			inst.__text_y += _by_y;
			with(inst) commit_move();
			if (is_child_of(inst, _baseContainerControl))
				inst.control_tree.move_children(_by_x, _by_y);
		}
	}

	/// @func move_children_after_sizing()
	static move_children_after_sizing = function(_force) {
		if (_force && is_root_tree()) layout(_force);
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			with(child.instance) {
				__text_x += SELF_MOVE_DELTA_X;
				__text_y += SELF_MOVE_DELTA_Y;
				if (is_child_of(self, _baseContainerControl))
					control_tree.move_children_after_sizing(_force);
			}
		}
		control.force_redraw(_force);
	}

	/// @func clear_children()
	static clear_children = function() {
		dlog($"Clearing all children in ControlTree of {name_of(control)}");
		
		__on_shown	= [];
		__on_opened	= [];
		__on_closed	= [];
		
		while (array_length(children) > 0) {
			var child = array_shift(children);
			var inst = child.instance;
			struct_remove(controls, child.name);
			if (is_child_of(inst, _baseContainerControl))
				inst.control_tree.clear_children();
			instance_destroy(inst);
		}
		return self;
	}

	/// @func clear()
	static clear = function() {
		if (!__alive) return;
		__alive = false;
		vlog($"CleanUp ControlTree of {name_of(control)}");
		__on_shown	= [];
		__on_opened	= [];
		__on_closed	= [];
		var have_elements = (array_length(children) > 0);
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			struct_remove(controls, child.name);
			var inst = child.instance;
			if (is_child_of(inst, _baseContainerControl) && instance_exists(inst))
				inst.control_tree.clear();
			instance_destroy(inst);
		}
		if (is_root_tree())
			dlog($"{name_of(control)} ControlTree cleanup finished");
		instance_destroy(control);
		control = undefined;
	}
}

