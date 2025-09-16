/*
    The SkinManager holds all loaded ui skins in a ds_map and you can switch your ui on-the-fly.
	This is especially useful if your game has... epoches or other permanently changing states that
	demand different graphics for your ui.	
*/

#macro UI_SKINS					global.__ui_skins
#macro SKIN						UI_SKINS.active_skin

#macro __DEFAULT_UI_SKIN_NAME	"default"
#macro __RAPTOR_PRE_SKIN_APPLY	"__raptor_skin_applied"
#macro __RAPTOR_PRE_LATE_APPLY	"__raptor_late_applied"

#macro ENSURE_SKINS				if (!variable_global_exists("__ui_skins")) UI_SKINS = new UiSkinManager(); \
								if (UI_SKINS.get_skin(__DEFAULT_UI_SKIN_NAME) == undefined) \
								UI_SKINS.add_skin(new DefaultSkin(__DEFAULT_UI_SKIN_NAME), true);

function UiSkinManager() constructor {
	construct(UiSkinManager);
	
	_skins = {
	};
	
	active_skin = undefined;
	
	/// @func add_skin(_skin, _activate_now = false)
	static add_skin = function(_skin, _activate_now = false) {
		var was_active = ((active_skin != undefined) && (active_skin.name == _skin.name));
		_skins[$ _skin.name] = _skin;
		ilog($"UiSkinManager registered skin '{_skin.name}'");
		if (_activate_now || was_active)
			activate_skin(_skin.name);
	}

	/// @func refresh_skin()
	/// @desc Invoked from RoomController in RoomStart event to transport the
	///				 active skin from room to room
	static refresh_skin = function() {
		if (active_skin != undefined)
			activate_skin(active_skin.name);
	}
	
	/// @func activate_skin(_skin_name)
	static activate_skin = function(_skin_name) {
		var sk = vsget(_skins, _skin_name);
		if (sk != undefined) {
			active_skin = sk;
			__assign_all_skin_sprites();
			ilog($"UiSkinManager activated skin '{sk.name}'");
		} else {
			elog($"** ERROR ** UiSkinManager could not activate skin '{_skin_name}' (SKIN-NOT-FOUND)");
		}
	}
	
	/// @func remove_skin(_skin_name)
	static remove_skin = function(_skin_name) {
		if (_skin_name == __DEFAULT_UI_SKIN_NAME) {
			elog($"** ERROR ** UiSkinManager can not remove the '{__DEFAULT_UI_SKIN_NAME}' skin!");
			return;
		}
		var inst = vsget(_skins, _skin_name);
		if (inst != undefined) {
			inst.delete_map();
			variable_struct_remove(_skins, _skin_name);
			ilog($"UiSkinManager removed skin '{_skin_name}'");
		}
	}
	
	/// @func get_skin(_skin_name)
	static get_skin = function(_skin_name) {
		return vsget(_skins, _skin_name);
	}

	static __assign_all_skin_sprites = function() {
		var names = struct_get_names(active_skin.skin);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var key = names[@i];
			var oidx = asset_get_index(key);
			if (oidx > -1)
				with(oidx) SKIN.apply_skin(self);
		}
	}
}

ENSURE_LOGGER;
ENSURE_THEMES;
ENSURE_SKINS;
