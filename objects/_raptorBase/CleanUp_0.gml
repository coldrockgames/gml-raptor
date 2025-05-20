/// @desc Log remove/destroy

binder.unbind_all();
BROADCASTER.remove_owner(self);
animation_abort_all(self);
ds_list_destroy(__topmost_object_list);

if (log_create_destroy)
	vlog($"{MY_NAME} removed/destroyed.");
