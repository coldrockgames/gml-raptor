/// @desc Log remove/destroy

__binder.unbind_all();
BROADCASTER.remove_owner(self);
animation_abort_all(self);
ds_list_destroy(__topmost_object_list);
