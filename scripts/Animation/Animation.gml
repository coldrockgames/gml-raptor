/*
    The Animation class runs an animation on an object over an animcurve.
	The RoomController object manages animations for you by calling all active animations'
	step() method every step.
	For this to work, you have instanciated a RoomController in your room.
	If not, nothing bad happens, but you have to call step() for yourself on every animation.
	
	The Animation class will autodetect the channels in the animcurve and set the 
	properties of the object automatically based on the curve channels.
	The names of the channels must be identical to the variables you want to set.
	So, to modify the hspeed, name the channel "hspeed", to modify x or y name them "x" or "y"...
	
	TRIGGERS
	--------
	The Animation class supports triggers for various points in time during the animation.
	Four trigger types are supported:
	- loop_trigger		- all loop triggers get invoked after the animation reached its final frame
	- started_trigger	- all started triggers get invoked once before the first frame of the animation
						  is processed.
	- finished_trigger	- all finished triggers get invoked when the last repeat of the animation is completed
						  NOTE: infinite animations receive this trigger only if you call abort()!
	- frame_trigger		- add a trigger to a specific frame. it gets invoked BEFORE this frame is processed

	If you reuse the animation often, it may become handy, to clear out all triggers from previous
	iterations. You can use the reset_triggers() function for that. It will delete ALL registered triggers.
	
	Every Animation instance has a data={} struct variable available.
	One member is added to the data in the constructor: data.anim = self;
	It holds a pointer to the Animation, this data struct belongs to, so you can easily access the running
	animation from within any trigger function (which is always scoped to the owner -- the game object).
	You can add any data to it. Each trigger will receive this data struct as first parameter.
	IN ADDITION, the frame_trigger callback receives a second parameter "frame" which holds the current frame
	number that is about to get processed.

*/

#macro ANIMATIONS	global.__ANIMATIONS
ANIMATIONS		= new ListPool("ANIMATIONS");

#macro LOOP_INFINITE	-1

/// @func		Animation(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {})
/// @desc	Holds an animation. set repeats to -1 to loop forever until you call abort()
/// @param {instance}	_obj_owner  The object to be animated
/// @param {int}		_delay      How many frames to wait until animation starts
/// @param {int}		_duration   Running time of (one loop) of the animation
/// @param {AnimCurve}	_animcurve  The AnimCurve providing the animated values
/// @param {int}		_repeats    Number of loops to perform. Default = 1, set to -1 for infinite repeats.
/// @param {string}		_finished_state	If the owner is stateful (or owns a StateMachine named "states"),
///										you can supply the name of a state here to set when this animation
///										finishes (A finished_trigger will be added for you).
/// @param {struct}		_data		A user defined data struct that will be delivered to all trigger functions
function Animation(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {})
	: DataBuilder() constructor {
	owner				= _obj_owner;
	finished_state		= _finished_state;
	delay				= _delay;
	duration			= _duration;
	duration_rt			= _duration / room_speed;
	animcurve			= _animcurve != undefined ? animcurve_get_ext(_animcurve) : undefined;
	repeats				= _repeats;
	data				= _data ?? {};
	data.animation		= self;
	name				= undefined;
	values				= new Bindable(self);
	
	parent_animation	= undefined; // used for looping through followed_by and loop_to methods
	child_animation		= undefined;
	chain_loop_count	= -1;
	chain_loop_run		= 0;
	chain_loop_target	= undefined;

	func_x				= function(value) { if (__relative_distance) owner.x = __start_x + __move_xdistance * value; else owner.x	= value; };
	func_y				= function(value) { if (__relative_distance) owner.y = __start_y + __move_ydistance * value; else owner.y	= value; };
	func_hspeed			= function(value) { if (__relative_speed) owner.hspeed		= __start_hspeed	 + __hspeed_distance	* value; else owner.hspeed		= value; };
	func_vspeed			= function(value) { if (__relative_speed) owner.vspeed		= __start_vspeed	 + __vspeed_distance	* value; else owner.vspeed		= value; };
	func_speed			= function(value) { if (__relative_speed) owner.speed		= __start_speed		 + __speed_distance		* value; else owner.speed		= value; };
	func_directon		= function(value) { if (__relative_speed) owner.direction	= __start_direction	 + __direction_distance * value; else owner.direction	= value; };
	func_image_alpha	= function(value) { owner.image_alpha	= value; };
	func_image_blend	= function(value) { owner.image_blend	= merge_color(__blend_start, __blend_end, value); };
	func_image_xscale	= function(value) { if (__relative_scale) owner.image_xscale = __start_xscale + __scale_xdistance * value; else owner.image_xscale	= value; };
	func_image_yscale	= function(value) { if (__relative_scale) owner.image_yscale = __start_yscale + __scale_ydistance * value; else owner.image_yscale	= value; };
	func_image_angle	= function(value) { if (__relative_angle) owner.image_angle  = __start_angle  + __rotation_distance * value; else owner.image_angle = value; };
	func_image_index	= function(value) { owner.image_index	= value; };
	func_image_speed	= function(value) { owner.image_speed	= value; };
	func_image_scale	= function(value) { 
		if (__relative_scale) {
			owner.image_xscale = __start_xscale + __scale_xdistance * value;
			owner.image_yscale = __start_yscale + __scale_ydistance * value;
		} else {
			owner.image_xscale = value;
			owner.image_yscale = value;
		}
	};

	// create all value functions (empty) for unknown channels to avoid crashes
	// in case, the animation is used as pure value animator
	if (animcurve != undefined) {
		for (var i = 0, len = array_length(animcurve.channel_names); i < len; i++) {
			var cname  = animcurve.channel_names[i];
			values[$ cname] = 0; // create the values entry
			
			if (vsget(self, "func_" + cname) == undefined)
				set_function(cname, function(v) {}); // create the empty processor function
		}
	}
	
	// these variables are used in the step loop
	__func				= undefined;
	__cname				= "";
	__cvalue			= 0;
	__first_step		= false;
	__play_forward		= true;
	__paused			= false;

	__blend_start		= c_white;
	__blend_end			= c_white;
	
	__relative_distance = false;
	__move_target		= false;
	__move_xdistance	= 0;
	__move_ydistance	= 0;
	
	__relative_scale	= false;
	__scale_target		= false;
	__scale_xdistance	= 0;
	__scale_ydistance	= 0;
	
	__relative_angle	= false;
	__rotation_target	= false;
	__rotation_distance	= 0;
	
	__relative_speed	= false;
	__speed_target		= false;
	__hspeed_distance	= 0;
	__vspeed_distance	= 0;
	__speed_distance	= 0;
	__direction_distance= 0;

	#region TRIGGERS
	static __frame_trigger_class = function(_frame, _trigger, _interval) constructor {
		frame = _frame;
		trigger = _trigger;
		interval = _interval;
	};
		
	/// @func		add_started_trigger(trigger)
	/// @desc	Add a trigger to run when animation starts.
	///					The callback will receive 1 parameter: data
	/// @param {func}	trigger  The callback to invoke.
	static add_started_trigger = function(trigger) {
		if (trigger != undefined) array_push(__started_triggers, trigger);
		return self;
	}
	
	/// @func		add_frame_trigger(trigger)
	/// @desc	Add a trigger to run on frame X.
	///					If you set is_interval to 'true', it will run EVERY x frames.
	///					The callback will receive 2 parameters: data,frame
	/// @param {int}	frame    The frame number, when to do the callback
	/// @param {func}	trigger  The callback to invoke.
	/// @param {bool=false}	is_interval  If true, runs every x frames.
	static add_frame_trigger = function(frame, trigger, is_interval = false) {
		if (trigger != undefined) array_push(__frame_triggers, new __frame_trigger_class(frame, trigger, is_interval));
		return self;
	}
	
	/// @func		add_loop_trigger(trigger)
	/// @desc	Add a trigger to run when the animation finished one loop.
	///					A loop ends at the last frame of an animation.
	///					The callback will receive 1 parameter: data
	/// @param {func}	trigger  The callback to invoke.
	static add_loop_trigger = function(trigger) {
		if (trigger != undefined) array_push(__loop_triggers, trigger);
		return self;
	}
	
	/// @func		add_finished_trigger(trigger)
	/// @desc	Add a trigger to run when animation finishes.
	///					The callback will receive 1 parameter: data
	/// @param {func}	trigger  The callback to invoke.
	static add_finished_trigger = function(trigger) {
		if (trigger != undefined) array_push(__finished_triggers, trigger);
		return self;
	}
	
	/// @func		reset_triggers()
	/// @desc	Remove all registered triggers from this animation.
	static reset_triggers = function() {
		__started_triggers	= [];
		__frame_triggers	= [];
		__loop_triggers		= [];
		__finished_triggers = [];
		return self;
	}
	
	static __invoke_triggers = function(array) {
		for (var i = 0, len = array_length(array); i < len; i++)
			array[@ i](data);
	}
	
	static __invoke_frame_triggers = function(frame) {
		var t;
		for (var i = 0, len = array_length(__frame_triggers); i < len; i++) {
			t = __frame_triggers[@ i];
			if (t.frame == frame || (t.interval && (frame % t.frame == 0))) t.trigger(data, frame);
		}
	}
	#endregion

	/// @func binder()
	/// @desc Gets the PropertyBinder for the values of this animation
	static binder = function() {
		return values.binder();
	}

	/// @func		set_name(_name)
	/// @desc	Gives this animation a specific name. Usage of names is totally optional,
	///					but this allows you to set a unique marker to an animation, which can be
	///					used as criteria in the is_in_animation(...) function.
	///					You can access the name of an animation with .name
	/// @param {string}	_name  The name this animation shall use.
	static set_name = function(_name) {
		name = _name;
		return self;
	}

	/// @func		set_move_distance(xdistance, ydistance)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier for the total
	///					distance you supply here (a "move by" curve).
	///					Both default move functions for x and y respect this setting.
	/// @param {real}	xdistance  Horizontal distance
	/// @param {real}	ydistance  Vertical distance
	static set_move_distance = function(xdistance, ydistance) {
		__relative_distance = true;
		__move_xdistance	= xdistance;
		__move_ydistance	= ydistance;
		return self;
	}

	/// @func		set_move_target(xtarget, ytarget)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier from the current
	///					to the target coordinates you supply here (a "move to" curve).
	///					Both default move functions for x and y respect this setting.
	/// @param {real}	xtarget  Horizontal target position
	/// @param {real}	ytarget  Vertical target position
	static set_move_target = function(xtarget, ytarget) {
		__relative_distance = true;
		__move_target		= true;
		__param_xtarget		= xtarget;
		__param_ytarget		= ytarget;
		__start_x			= owner.x;
		__start_y			= owner.y;
		__move_xdistance	= xtarget - __start_x;
		__move_ydistance	= ytarget - __start_y;
		return self;
	}

	/// @func		set_scale_distance(xdistance, ydistance)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier for the total
	///					distance you supply here (a "scale by" curve).
	///					Both default scale functions for x and y respect this setting.
	/// @param {real}	xdistance  Horizontal scale delta
	/// @param {real}	ydistance  Vertical scale delta
	static set_scale_distance = function(xdistance, ydistance) {
		__relative_scale	= true;
		__scale_xdistance	= xdistance;
		__scale_ydistance	= ydistance;
		return self;
	}

	/// @func		set_scale_target(xtarget, ytarget)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier for the total
	///					distance you supply here (a "scale to" curve).
	///					Both default scale functions for x and y respect this setting.
	/// @param {real}	xtarget  Horizontal scale target
	/// @param {real}	ytarget  Vertical scale target
	static set_scale_target = function(xtarget, ytarget) {
		__relative_scale		= true;
		__scale_target			= true;
		__param_scale_xtarget	= xtarget;
		__param_scale_ytarget	= ytarget;
		__start_xscale			= owner.image_xscale;
		__start_yscale			= owner.image_yscale;
		__scale_xdistance		= xtarget - __start_xscale;
		__scale_ydistance		= ytarget - __start_yscale;
		return self;
	}

	/// @func		set_rotation_distance(degrees)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for image_angle and the curve value shall be a multiplier for the total
	///					distance you supply here (a "rotate by" curve).
	/// @param {real}	degrees  The number of degrees to rotate
	static set_rotation_distance = function(degrees) {
		__relative_angle = true;
		__rotation_distance = degrees;
		return self;
	}

	/// @func		set_rotation_target(degrees)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier from the current
	///					to the target angle you supply here (a "rotate to" curve).
	///					Both default move functions for x and y respect this setting.
	/// @param {real}	degrees  The angle to rotate to
	static set_rotation_target = function(degrees) {
		__relative_angle		= true;
		__rotation_target		= true;
		__param_rotation_target = degrees - __start_angle;
		__start_angle			= owner.image_angle;
		__rotation_distance		= degrees - __start_angle;
		return self;
	}

	/// @func		set_speed_distance(_hspeed = 0, _vspeed = 0, _speed = 0, _direction = 0)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for hspeed/vspeed or speed/direction and the curve value shall be a multiplier for the total
	///					distance you supply here (a "change by" curve).
	///					Think in pairs when using this function. Either supply h/vspeed values or speed/direction,
	///					as all of those influence each other.
	/// @param {real}	_hspeed		The amount to change hspeed over time
	/// @param {real}	_vspeed		The amount to change vspeed over time
	/// @param {real}	_speed		The amount to change speed over time
	/// @param {real}	_direction  The amount to change direction over time
	static set_speed_distance = function(_hspeed = 0, _vspeed = 0, _speed = 0, _direction = 0) {
		__relative_speed		= true;
		__hspeed_distance		= _hspeed;
		__vspeed_distance		= _vspeed;
		__speed_distance		= _speed;
		__direction_distance	= _direction;
		return self;
	}

	/// @func		set_speed_target(_hspeed = 0, _vspeed = 0, _speed = 0, _direction = 0)
	/// @desc	use this function if the animcurve holds a standard 0..1 value
	///					for hspeed/vspeed or speed/direction and the curve value shall be a multiplier for the total
	///					distance you supply here (a "change to" curve).
	///					Think in pairs when using this function. Either supply h/vspeed values or speed/direction,
	///					as all of those influence each other.
	/// @param {real}	_hspeed		The value to set for hspeed over time
	/// @param {real}	_vspeed		The value to set for vspeed over time
	/// @param {real}	_speed		The value to set for speed over time
	/// @param {real}	_direction  The value to set for direction over time
	static set_speed_target = function(_hspeed = 0, _vspeed = 0, _speed = 0, _direction = 0) {
		__relative_speed			= true;
		__speed_target				= true;
		
		__param_hspeed_target		= _hspeed;
		__param_vspeed_target		= _vspeed;
		__param_speed_target		= _speed;
		__param_direction_target	= _direction;
		
		__start_hspeed				= owner.hspeed;
		__start_vspeed				= owner.vspeed;
		__start_speed				= owner.speed;
		__start_direction			= owner.direction;
		
		__hspeed_distance			= _hspeed - __start_hspeed;
		__vspeed_distance			= _vspeed - __start_vspeed;
		__speed_distance			= _speed  - __start_speed;
		__direction_distance		= _direction - __start_direction;
		return self;
	}

	/// @func		set_blend_range(start_color = c_white, end_color = c_white)
	/// @desc	set the two colors that shall be modified during an image_blend curve
	/// @param {color}	start_color  Color on animcurve value = 0. Default = c_white
	/// @param {color}	end_color    Color on animcurve value = 1. Default = c_white
	static set_blend_range = function(start_color = c_white, end_color = c_white) {
		__blend_start = start_color;
		__blend_end	  = end_color;
		return self;
	}

	/// @func					set_function(channel_name, _function)
	/// @desc				Assign a function that takes 1 argument (the value) for a channel
	static set_function = function(channel_name, _function) {
		self[$ "func_" + channel_name] = method(self, _function);
		return self;
	}

	/// @func					set_animcurve(_animcurve)
	/// @desc				Assign a new animcurve to this animation.
	///								ATTENTION: Changing a curve in the middle of an animation
	///								can be used for advanced effects but also be a source of
	///								really unexpected behavior!
	static set_animcurve = function(_animcurve) {
		animcurve = _animcurve != undefined ? animcurve_get_ext(_animcurve) : undefined;
		return self;
	}

	/// @func					set_duration(_duration)
	/// @desc				Change the duration of this animation.
	static set_duration = function(_duration) {
		duration = _duration;
		return self;
	}

	/// @func play_forward()
	/// @desc Animation shall play forward (this is default)
	static play_forward = function() {
		__play_forward = true;
		return self;
	}
	
	/// @func play_backwards()
	/// @desc Animation shall play backwards (Animcurve starts at 1 and goes back to 0)
	static play_backwards = function() {
		__play_forward = false;
		return self;
	}

	/// @func is_playing_forward()
	/// @desc Returns whether the animation is currently in play_forward mode or not
	static is_playing_forward = function() {
		return __play_forward;
	}

	/// @func		pause()
	/// @desc	Pause the animation at the current frame
	static pause = function() {
		__paused = true;
		return self;
	}
	
	/// @func		resume()
	/// @desc	Resume the animation at the frame it has been paused
	static resume = function() {
		__paused = false;
		return self;
	}
	
	/// @func		set_paused(paused)
	/// @desc	Set the pause state
	/// @param {bool}	paused  true to pause, false to resume
	static set_paused = function(paused) {
		__paused = paused;
		return self;
	}

	/// @func		is_paused()
	/// @desc	Check whether this animation is currently paused
	/// @returns {bool} The current pause state
	static is_paused = function() {
		return __paused;
	}

	/// @func		is_active()
	/// @desc	Check if the animation has already started or still in delay countdown
	/// @returns {bool} True, if the animation is running, false if still waiting for initial delay
	static is_active = function() {
		return __active;
	}

	/// @func		get_frame_counter()
	/// @desc	Gets the current running frame count
	///					NOTE: This function returns 0 (zero) while waiting for the initial delay.
	/// @returns {int}	The current frame number
	static get_frame_counter = function() {
		return __frame_counter;
	}

	/// @func		get_remaining_frames()
	/// @desc	Returns the amount of frames left for this animation iteration
	///					In a looping animation with more than one repeat, this returns
	///					the number of frames remaining in the current loop.
	///					NOTE: 
	///					On the LAST FRAME of an iteration, this returns 1 (this one frame remaining)
	///					Before the animations started (delay) 
	///					this returns duration + remaining_delay_frames
	/// @returns {int}	The remaining frames for this animation iteration
	static get_remaining_frames = function() {
		return __active ? (duration - __frame_counter + 1) : (delay - __delay_counter + duration);
	}

	/// @func		__process_final_state(aborted = false)
	static __process_final_state = function(aborted = false) {
		if (!string_is_empty(finished_state)) {
			var st = finished_state;
			with (owner) states.set_state(st);
		}
		
		if (aborted) return;
		
		// First check, if we need to loop...
		if (chain_loop_target != undefined) {
			if (chain_loop_count != -1) chain_loop_run++;
			if (chain_loop_count == -1 || chain_loop_run < chain_loop_count) {
				with (chain_loop_target) reset();
				return; // exit here, no child animations while looping
			} else if (child_animation != undefined) 
				chain_loop_run = 0; // if we are not the last in the chain, we might be called again
		}
		// ...then, if there's a child to activate now
		if (child_animation != undefined) {
			with (child_animation) reset(); // launch the child
		}
	}

	/// @func					step()
	/// @desc				call this every step!
	static step = function() {
		if (__finished || __paused) return;
		
		__time_step  =  DELTA_TIME_SECS;
		__time		 += __time_step;
		__time_total += __time_step;
		
		if (__active) {
			if (__first_step) {
				__first_step = false;
				__invoke_triggers(__started_triggers);
			}

			// calc the new frame...
			__frame_counter = floor(__time * room_speed);
			// ...then detect if we have a frame skip...
			if (__frame_counter > __frame_expected) {
				__frame_expected = __frame_counter - __frame_expected;
				// ...and run all skipped frame triggers
				for (var i = 1; i <= __frame_expected; i++)
					__invoke_frame_triggers(__total_frames + i);
			}
			// finally, set the new expected frame
			__frame_expected = __frame_counter + 1;
			
			// now calculate the regular frame triggers (all missed are already invoked)
			__total_frames  = floor(__time_total * room_speed);
			__invoke_frame_triggers(__total_frames);
			
			if (animcurve != undefined) {
				var pit = __play_forward ? __time : (duration_rt - __time);
				animcurve.update(pit, duration_rt);
				
				for (var i = 0, len = array_length(animcurve.channel_names); i < len; i++) {
					__cname  = animcurve.channel_names[i];
					__cvalue = animcurve.channel_values[i];
					
					values[$ __cname] = __cvalue;
					self[$ "func_" + __cname](__cvalue);
				}
			}
			
			if (__frame_counter >= duration) {
				__invoke_triggers(__loop_triggers);
				if (repeats > 0) {
					__repeat_counter++;
					__finished = __repeat_counter >= repeats;
					if (__finished) { 
						ANIMATIONS.remove(self);
						__unbind_me();
						__invoke_triggers(__finished_triggers);
						__process_final_state();
					} else {
						var keep = __repeat_counter;
						reset();
						__repeat_counter = keep;
					}
				}
				__frame_counter		= 0;
				__frame_expected	= 1;
				__delay_counter		= 0;
				__time				= 0;
				__active			= (delay == 0);
			}
		} else {
			__delay_counter = max(__delay_counter, floor(abs(__time) * room_speed));
			if (__delay_counter >= delay) {
				__active	 = true;
				__time		 = 0;
				__time_total = 0;
			}
			__first_step = __active;
		}
	}
	
	/// @func		followed_by(_delay, _duration, _animcurve, _repeats, _finished_state = undefined)
	/// @desc	Defines a follow-up animation when this animation finishes
	/// @param {int}		_delay      How many frames to wait until animation starts
	/// @param {int}		_duration   Running time of (one loop) of the animation
	/// @param {AnimCurve}	_animcurve  The AnimCurve providing the animated values
	/// @param {int}		_repeats    Number of loops to perform. Default = 1, set to -1 for infinite repeats.
	/// @param {string}		_finished_state	If the owner is stateful (or owns a StateMachine named "states"),
	///										you can supply the name of a state here to set when this animation
	///										finishes (A finished_trigger will be added for you).
	static followed_by = function(_delay, _duration, _animcurve, _repeats, _finished_state = undefined) {
		var anm = new Animation(owner, _delay, _duration, _animcurve, _repeats, _finished_state);
		ANIMATIONS.remove(anm); // do not autostart this one
		anm.parent_animation = self;
		child_animation = anm;
		return anm;
	}
	
	/// @func		loop_to_first(_repeats = -1)
	/// @desc	Jumps to the first animation of the sequence when this animation ends.
	/// @param {int}		_repeats    Number of loops to perform. Default = -1, which means forever
	static loop_to_first = function(_repeats = -1) {
		var anm = self;
		while (anm.parent_animation != undefined)
			anm = anm.parent_animation;
		chain_loop_target = anm;
		chain_loop_count = _repeats;
		return self;
	}
	
	/// @func		loop_to(_name, _repeats = -1)
	/// @desc	Jumps to the named animation of the sequence when this animation ends.
	///					NOTE: You can set a name for an animation through the .set_name method!
	/// @param {string}		_name		Name of the animation to loop to (use .set_name to set a name!)
	/// @param {int}		_repeats    Number of loops to perform. Default = -1, which means forever
	static loop_to = function(_name, _repeats = -1) {
		var anm = self;
		if (anm.name == _name) {
			chain_loop_target = anm;
			chain_loop_count = _repeats;
			return self;
		}
		while (anm.parent_animation != undefined) {
			if (anm.name == _name) {
				chain_loop_target = anm;
				chain_loop_count = _repeats;
				return self;
			}
			anm = anm.parent_animation;
		}
	}
	
	/// @func		finish()
	/// @desc	Fast forward until the end of the animation, invoking all triggers on the way.
	///					The function uses the current delta_time as time step until the end of the animation is reached.
	///					If the animation is paused, the paused state is lifted for the operation.
	///					Repeats will be set to 1, so only the current iteration will be finished.
	///					Both variables (paused and repeats) are set back to their original values when the end of the
	///					sequence is reached.
	///					ATTENTION! This function uses a "while" loop to process frame-by-frame as fast as possible
	///					Use with care in animation sequences (followed_by... etc) as this function will only
	///					fast-forward the _current_ animation, not the entire sequence, so with the next frame, a sequence
	///					will continue with the next animation in the sequence at normal speed.
	static finish = function() {
		if (__finished) return;
		
		var paused_before	= __paused;
		var repeats_before	= repeats;
		repeats				= 1;
		__paused			= false;
		__delay_counter		= delay;
		
		while (!__finished)
			step();
			
		repeats	 = repeats_before;
		__paused = paused_before;
	}
	
	/// @func		abort(_run_finished_triggers = true)
	/// @desc	Stop immediately, but finished trigger WILL fire unless you set the argument to false!
	static abort = function(_run_finished_triggers = true) {
		var was_finished = __finished;
		__finished = true;
		ANIMATIONS.remove(self);
		__unbind_me();
		if (!was_finished) {
			if (_run_finished_triggers)
				__invoke_triggers(__finished_triggers);
			__process_final_state(true);
		}
	}
	
	static __unbind_me = function() {
		if (values.binder_initialized())
			values.binder().unbind_all();
	}
	
	/// @func		reset()
	/// @desc	All back to start. Animation will RUN now (but respect the delay)!
	///					NOTE: The animation direction (forward/backward) will NOT change 
	///					with a reset!
	static reset = function(_incl_triggers = false) {
		ANIMATIONS.add(self);

		// Update data to current values
		__start_x			= owner.x;
		__start_y			= owner.y;
		__start_xscale		= owner.image_xscale;
		__start_yscale		= owner.image_yscale;
		__start_angle		= owner.image_angle;
		__start_hspeed		= owner.hspeed;
		__start_vspeed		= owner.vspeed;
		__start_speed		= owner.speed;
		__start_direction	= owner.direction;

		// re-set the targets, if we need to
		if (__move_target)
			set_move_target(__param_xtarget, __param_ytarget);
		
		if (__scale_target)
			set_scale_target(__param_scale_xtarget, __param_scale_ytarget);
			
		if (__rotation_target)
			set_rotation_target(__param_rotation_target);
			
		if (__speed_target)
			set_speed_target(__param_hspeed_target, __param_vspeed_target, __param_speed_target, __param_direction_target);

		// reset timing
		__time				= 0;
		__time_step			= 0;
		__time_total		= 0;
		__delay_counter		= 0;
		__frame_counter		= 0;
		__frame_expected	= 1;
		__total_frames		= 0;
		__repeat_counter	= 0;
		__active			= delay == 0;
		__finished			= repeats == 0;
		__first_step		= __active;
		__paused			= false;
		
		if (_incl_triggers)
			reset_triggers();
			
		return self;
	}

	toString = function() {
		var me = name_of(owner) ?? "";
		return $"{me}: delay={delay}; duration={duration}; repeats={repeats};";
	}

	reset();
	reset_triggers();

	if (!variable_instance_exists(owner, "states")) {
		finished_state = undefined; // remove the finished state if it is not a owner with states
	}
}

/// @func		animation_clear_pool()
/// @desc	Instantly removes ALL animations from the global ANIMATIONS pool.
function animation_clear_pool() {
	ANIMATIONS.clear();
}

/// @func		animation_get_all(owner = self)
/// @desc	Get all registered animations for the specified owner from the global ANIMATIONS pool.
///					NOTE: Set the owner to <undefined> to retrieve ALL existing animations!
function animation_get_all(owner = self) {
	return __listpool_get_all_owner_objects(ANIMATIONS, owner);
}

/// @func		animation_finish_all(owner = self)
/// @desc	Finish all registered animations for the specified owner.
///					NOTE: Set the owner to <undefined> to finish ALL existing animations!
function animation_finish_all(owner = self) {
	var removers = animation_get_all(owner);
	
	if (DEBUG_LOG_LIST_POOLS)
		with (owner) 
			vlog($"{MY_NAME}: animation_finish_all cleanup: anims_to_remove={array_length(removers)};");
		
	for (var i = 0, len = array_length(removers); i < len; i++) {
		var to_remove = removers[@ i];
		with (to_remove) 
			finish();
	}
}

/// @func		animation_abort_all(owner = self, _run_finished_triggers = true)
/// @desc	Remove all registered animations for the specified owner from the global ANIMATIONS pool.
///					NOTE: Set the owner to <undefined> to abort ALL existing animations!
function animation_abort_all(owner = self, _run_finished_triggers = true) {
	var removers = animation_get_all(owner);
	
	if (DEBUG_LOG_LIST_POOLS)
		with (owner) 
			vlog($"{MY_NAME}: animation_abort_all cleanup: anims_to_remove={array_length(removers)};");

	for (var i = 0, len = array_length(removers); i < len; i++) {
		var to_remove = removers[@ i];
		with (to_remove) 
			abort(_run_finished_triggers);
	}
}

/// @func animation_abort(owner, name, _run_finished_triggers = true)
/// @desc Aborts one specific named animation of a specified owner.
///				 NOTE: If multiple animations with the same name exist, 
///				 only the first one found will be aborted!
/// @returns {bool} True, if an animation has been aborted, otherwise false.
function animation_abort(owner, name, _run_finished_triggers = true) {
	var lst = ANIMATIONS.list;
	for (var i = 0, len = array_length(lst); i < len; i++) {
		var item = lst[@i];
		if (eq(item.owner, owner) && name == item.name)
			with(item) { abort(_run_finished_triggers); return true; }
	}
	return false;
}

/// @func animation_finish(owner, name)
/// @desc Finishes one specific named animation of a specified owner.
///				 NOTE: If multiple animations with the same name exist, 
///				 only the first one found will be finished!
/// @returns {bool} True, if an animation has been finished, otherwise false.
function animation_finish(owner, name) {
	var lst = ANIMATIONS.list;
	for (var i = 0, len = array_length(lst); i < len; i++) {
		var item = lst[@i];
		if (eq(item.owner, owner) && name == item.name)
			with(item) { finish(); return true; }
	}
	return false;
}

/// @func		animation_pause_all(owner = self)
/// @desc	Set all registered animations for the specified owner to paused state.
///					NOTE: Set the owner to <undefined> to pause ALL existing animations!
///					This bulk function is very handy if you have a "pause/resume" feature in your
///					game and you want to "freeze" the scene.
function animation_pause_all(owner = self) {
	var to_set = animation_get_all(owner);
	
	if (DEBUG_LOG_LIST_POOLS)
		with (owner) 
			vlog($"{MY_NAME}: Animation bulk pause: anims_to_set={array_length(to_set)};");
	
	for (var i = 0, len = array_length(to_set); i < len; i++) {
		var next = to_set[@ i];
		with (next) 
			pause();
	}
}

/// @func		animation_resume_all(owner = self)
/// @desc	Set all registered animations for the specified owner to running state.
///					NOTE: Set the owner to <undefined> to resume ALL existing animations!
///					This bulk function is very handy if you have a "pause/resume" feature in your
///					game and you want to "unfreeze" the scene.
function animation_resume_all(owner = self) {
	var to_set = animation_get_all(owner);
	
	if (DEBUG_LOG_LIST_POOLS)
		with (owner) 
			vlog($"{MY_NAME}: Animation bulk resume: anims_to_set={array_length(to_set)};");
	
	for (var i = 0, len = array_length(to_set); i < len; i++) {
		var next = to_set[@ i];
		with (next) 
			resume();
	}
}

/// @func		is_in_animation(owner = self, name = undefined)
/// @desc	Returns true, if there's at least one animation for the specified owner 
///					currently in the global ANIMATIONS pool.
///					If the name is also specified, true is only returned, if the names match.
///					This is useful if you need to know, whether an object is currently running
///					one specific animation.
function is_in_animation(owner = self, name = undefined) {
	var lst = ANIMATIONS.list;
	for (var i = 0, len = array_length(lst); i < len; i++) {
		var item = lst[@i];
		if (item.owner.id == owner.id && (name == undefined || name == item.name))
			return true;
	}

	return false;
}

/// @func			animation_run(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {})
/// @desc		convenience constructor wrapper if you don't need to keep your own pointer
/// @returns {Animation}
function animation_run(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {}) {
	return new Animation(_obj_owner, _delay, _duration, _animcurve, _repeats, _finished_state, _data);
}

/// @func			animation_run_ex(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {})
/// @desc		Runs an animation EXCLUSIVE (i.e. calls "animation_abort_all()" for the owner first.
///						Convenience constructor wrapper if you don't need to keep your own pointer
/// @returns {Animation}
function animation_run_ex(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {}) {
	animation_abort_all(_obj_owner);
	return new Animation(_obj_owner, _delay, _duration, _animcurve, _repeats, _finished_state, _data);
}

/// @func			animation_run_exf(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {})
/// @desc		Runs an animation EXCLUSIVE WITH FINISH (i.e. calls "animation_finish_all()" for the owner first.
///						Convenience constructor wrapper if you don't need to keep your own pointer
/// @returns {Animation}
function animation_run_exf(_obj_owner, _delay, _duration, _animcurve, _repeats = 1, _finished_state = undefined, _data = {}) {
	animation_finish_all(_obj_owner);
	return new Animation(_obj_owner, _delay, _duration, _animcurve, _repeats, _finished_state, _data);
}

/// @func	animate_sprite(_sprite, _layer_name_or_depth, _x, _y, _delay, _duration, _animcurve, _repeats = 1, _sprite_data = {}, _anim_data = {})
/// @desc	Similar to animation run, it even returns an animation, but you don't need an object to animate,
///			instead, a sprite_index is enough and a pooled instance of __sprite_anim_runner will be used to
///			run the animation. It returns to the pool, when the animation is finished.
///			Works even for ANIMATION CHAINS! That's why this function returns the created animation and not
///			the pooled runner object. You can obtain the pooled runner object from the .owner property of the
///			animation returned.
///			NOTE: There are 2 structs you may supply:
///			_sprite_data will be sent to the onPoolActivate of the __sprite_anim_runner. You can modify the sprite
///						 with this struct. All green image_* variables (index, blend, speed, alpha, angle, scale) will
///						 be taken into account
///			_anim_data  will be sent to the created Animation as data object and is available in all your triggers you
///						attach to the animation
/// @returns {Animation}
function animate_sprite(_sprite, _layer_name_or_depth, _x, _y, _delay, _duration, _animcurve, _repeats = 1, _sprite_data = {}, _anim_data = {}) {
	var runner = pool_get_instance(__RAPTOR_SPRITE_ANIM_POOL, __sprite_anim_runner, _layer_name_or_depth, _sprite_data);
	if (is_string(_layer_name_or_depth))
		layer_add_instance(layer_get_id(_layer_name_or_depth), runner);
	else
		runner.depth = _layer_name_or_depth;
	
	runner.sprite_index = _sprite;
	runner.x = _x;
	runner.y = _y;
	return animation_run(runner, _delay, _duration, _animcurve, _repeats, undefined, _anim_data);
}

/// @func			__animation_empty(_obj_owner, _delay, _duration, _repeats = 1, _data = {})
/// @desc		Convenience function to create a delay/duration/callback animation
///						without an animcurve, but you have still ALL callbacks available
///						(started, finished, frames, etc). It just has no animation.
///						You can use this to easily delay or repeat actions without the need of
///						actually design a real animation.
///						Can be seen as a comfortable ALARM implementation with more options than the builtin alarms.
/// @returns {Animation}
function __animation_empty(_obj_owner, _delay, _duration, _repeats = 1, _data = {}) {
	return new Animation(_obj_owner, _delay, _duration, undefined, _repeats, undefined, _data);
}
