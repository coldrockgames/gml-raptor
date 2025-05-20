/// @desc animation timing
if (__subimage_count == 1 || __time_step == 0) exit;

__time += (delta_time * image_speed);
__sub_idx_prev = __sub_idx;
__sub_idx = floor(__time / __time_step) % __subimage_count;

if (__sub_idx < __sub_idx_prev) 
	__time = __time % __time_step;
