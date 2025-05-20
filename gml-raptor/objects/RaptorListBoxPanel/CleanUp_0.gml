/// @desc event
event_inherited();

listbox = undefined;

if (myscrollbar != undefined) {
	instance_destroy(myscrollbar);
	myscrollbar = undefined;
}

array_foreach(myitems, function(_item) { instance_destroy(_item); });