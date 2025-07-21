/// @desc	Animation timing

// Collider functionality
if (__is_parent) {
	if (image_count == 1 || __time_step == 0) exit;

	__time += (delta_time * image_speed);
	__sub_idx_prev = __sub_idx;
	__sub_idx = floor(__time / __time_step) % image_count;

	if (__sub_idx < __sub_idx_prev) 
		__time = __time % __time_step;
} else {
	// mirror only the render-relevant values
	x				= collage_parent.x;
	y				= collage_parent.y;
	image_index		= collage_parent.__sub_idx;
	image_xscale	= collage_parent.image_xscale;
	image_yscale	= collage_parent.image_yscale;
	image_angle		= collage_parent.image_angle;
	
	// manual collision check (this code is faster than it looks!)
	if (collage_parent.__collide_with != undefined) {
		if (__collision_count > 0)
			ds_list_clear(__collision_list);
			
		__collision_count = instance_place_list(
			x, y, 
			collage_parent.__collide_with, 
			__collision_list, 
			false
		);
		
		if (__collision_count > 0) {
			var item;
			for (var i = 0; i < __collision_count; i++) {
				item = __collision_list[|i];
				with(item)	with(other.collage_parent)
					__perform_collision(item);
			}
		}
	}
}


