/// @desc call set_table to use this object!
event_inherited();

__table = undefined;
__surface = undefined;

__startup_x = x;
__startup_y = y;
__align_h_multi = (screen_align_h == fa_left ? 0 : (screen_align_h == fa_center ? 0.5 : 1));
__align_v_multi = (screen_align_v == fa_top  ? 0 : (screen_align_v == fa_middle ? 0.5 : 1));
surfw = 0;
surfh = 0;

__release_surface = function() {
	if (__surface != undefined) surface_free(__surface);
	__surface = undefined;
}

set_table = function(_highscoretable) {
	__table = _highscoretable;
	
	__release_surface();
	if (__table == undefined || __table.size() == 0) 
		return;
	
	var maxw_rank	= 0;
	var maxw_name	= 0;
	var maxw_score	= 0;
	var maxw_time	= 0;
	var maxw_create = 0;

	surfw = 0;
	surfh = 0;
	
	var tmp = __table.data.entries[@ 0];
	var _render_score = (render_score && tmp != undefined && tmp.data.Score != undefined);
	var _render_time  = (render_time  && tmp != undefined && tmp.data.Time  != undefined);
		
	var draw_from_rank = max(0, from_rank - 1);
	var draw_to_rank = (to_rank < 0 ? __table.size() : to_rank);
	
	for (var i = draw_from_rank; i < draw_to_rank; i++) {
		if (i == 0 && rank_1_font != noone)	draw_set_font(rank_1_font); else
		if (i == 1 && rank_2_font != noone)	draw_set_font(rank_2_font); else
		if (i == 2 && rank_3_font != noone)	draw_set_font(rank_3_font); else
			draw_set_font(rank_default_font);
		
		var rankidx = i + 1;
		var sranks		= __table.get_rank_list(rankidx,rankidx,rank_prefix_character);
		var snames		= __table.get_name_list(rankidx,rankidx);
		var sscores		= __table.get_score_list(rankidx,rankidx, score_decimals);
		var stimes		= __table.get_time_list(rankidx,rankidx);
		var screateds	= __table.get_created_list(rankidx,rankidx);
		
		if (render_rank) maxw_rank = max(maxw_rank, string_width(sranks) + space_between_columns);
		maxw_name = max(maxw_name, string_width(snames) + space_between_columns);
		if (_render_score) maxw_score = max(maxw_score, string_width(sscores) + space_between_columns);
		if (_render_time) maxw_time= max(maxw_time, string_width(stimes) + space_between_columns);
		if (render_create_date) maxw_create = max(maxw_create, string_width(screateds) + space_between_columns);

		surfw = max(surfw, maxw_rank + maxw_name + maxw_score + maxw_time + maxw_create + 2 * space_between_columns);
		surfh += space_between_rows + max(
			string_height(sranks),
			string_height(snames),
			string_height(sscores),
			string_height(stimes),
			string_height(screateds)
		);
	}
	
	var curx = space_between_columns;
	var cury = space_between_rows / 2;
	var lineh = 0;
	
	__surface = surface_create(surfw, surfh);
	surface_set_target(__surface);
	
	if (draw_debug_frame)
		draw_clear_alpha(c_green, 0.2);
	else
		draw_clear_alpha(c_black, render_background_darken);
		
	draw_set_alpha(1);
	
	for (var i = draw_from_rank; i < draw_to_rank; i++) {
		if (i == 0 && rank_1_font != noone)	draw_set_font(rank_1_font); else
		if (i == 1 && rank_2_font != noone)	draw_set_font(rank_2_font); else
		if (i == 2 && rank_3_font != noone)	draw_set_font(rank_3_font); else
			draw_set_font(rank_default_font);
		
		if (i == 0)	draw_set_color(rank_1_color); else
		if (i == 1)	draw_set_color(rank_2_color); else
		if (i == 2)	draw_set_color(rank_3_color); else
			draw_set_color(rank_default_color);
		
		var rankidx = i + 1;
		var sranks		= __table.get_rank_list(rankidx,rankidx,rank_prefix_character);
		var snames		= __table.get_name_list(rankidx,rankidx);
		var sscores		= __table.get_score_list(rankidx,rankidx, score_decimals);
		var stimes		= __table.get_time_list(rankidx,rankidx);
		var screateds	= __table.get_created_list(rankidx,rankidx);
		
		if (render_rank) {
			draw_text(curx + maxw_rank - space_between_columns - string_width(sranks), cury, sranks);
			curx += maxw_rank;
			lineh = max(lineh, string_height(sranks));
		}
		
		draw_text(curx, cury, snames);
		curx += maxw_name;
		lineh = max(lineh, string_height(sranks));

		if (_render_score) {
			draw_text(curx + maxw_score - space_between_columns - string_width(sscores), cury, sscores);
			curx += maxw_score;
			lineh = max(lineh, string_height(sscores));
		}

		if (_render_time) {
			draw_text(curx + maxw_time - string_width(stimes), cury, stimes);
			curx += maxw_time;
			lineh = max(lineh, string_height(stimes));
		}

		if (render_create_date) {
			draw_text(curx + maxw_create - string_width(screateds), cury, screateds);
			curx += maxw_create;
			lineh = max(lineh, string_height(screateds));
		}

		curx = space_between_columns;
		cury += lineh + space_between_rows;
		lineh = 0;
	}
	
	surface_reset_target();
}

update = function() {
	set_table(__table);
}

__ensure_surface_is_ready = function() {
	if (__table == undefined)
		return false;
	if (__surface == undefined || !surface_exists(__surface)) {
		update();
		return __surface != undefined && surface_exists(__surface);
	}
	return true;
}