/*
	Utility functions to work with sequences.
	
	Sequences are a powerful tool but they lack some QoL features.
	The functions in this script shall help a bit.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

#macro SEQUENCE_CUSTOM_ATTRIBUTES		"__raptor_attributes"
#macro SEQUENCE_CUSTOM_INSTANCES		"__raptor_instances"

/// @func							seq_create_with_attributes(sequence, layer, x, y)
/// @desc						Create a sequence instance with the specified parameters and return the instance.
///										This function will add the __raptor_attributes struct to the instance.
/// @param {objecttype} sequence		The object type to create an instance of
/// @param {layer} layer				The layer on which to create the instance
/// @param {real} x						x-position
/// @param {real} y						y-position
///	@returns {struct}					The instance struct of this sequence.
function seq_create_with_attributes(sequence, layer, x, y) {
	var seq = layer_sequence_create(layer, x, y, sequence);
	var inst = layer_sequence_get_instance(seq);
	inst.name = sequence_get(sequence).name;
	inst[$ SEQUENCE_CUSTOM_ATTRIBUTES] = {};
	vlog($"Created sequence: sequence='{sequence_get(sequence).name}'; elementID={inst.elementID};");
	return inst;
}

/// @func						seq_create_for_instance(sequence,objecttype,instance,store_as_name = "")
/// @desc					A convenience shortcut function that creates a sequence on the layer and
///									position of the instance and even replaces the specified objecttype in 
///									the sequence with the instance.
///									This function will add the __raptor_attributes struct to the instance.
/// @param {objecttype} sequence	The object type to create an instance of
/// @param {objecttype} object		The object type IN the sequence to be replaced
/// @param {instance} instance		The instance to replace it with
/// @param {string=""} store_as_name	(Optional) a custom name to store the instance
///	@returns {struct}				The instance struct of this sequence.
function seq_create_for_instance(sequence,object,instance,store_as_name = "") {
	var inst = seq_create_with_attributes(sequence,instance.layer,instance.x,instance.y);
	with(instance)
		vlog($"Replacing instance in sequence: sequence='{inst.name}', instance='{MY_NAME}'");
	seq_modify_instance(inst,object,instance,store_as_name);
	return inst;
}

/// @func					seq_get_custom_attributes(sequence)
/// @desc				Gets the struct of all stored custom attributes from a sequence instance.
/// @param {struct} sequence	The instance of the sequence
/// @returns {struct}			The custom attributes
function seq_get_custom_attributes(sequence) {
	return struct_get(sequence,SEQUENCE_CUSTOM_ATTRIBUTES);
}

/// @func					seq_set_attribute(sequence,name,value)
/// @desc				Set the specified custom attribute to the specified value.
/// @param {struct} sequence	The instance of the sequence
/// @param {string} name		The attribute to set
/// @param {any} value			The value to assign
function seq_set_attribute(sequence,name,value) {
	struct_set(seq_get_custom_attributes(sequence),name,value);
}

/// @func					seq_get_attribute(sequence,name)
/// @desc				Gets the specified stored custom attributes from a sequence instance.
/// @param {struct} sequence	The instance of the sequence
/// @param {string} name		The attribute to get
/// @returns {any}				The value of the attribute
function seq_get_attribute(sequence,name) {
	return struct_get(seq_get_custom_attributes(sequence),name);
}

/// @func						seq_modify_instance(sequence,object,instance,store_as_name = "")
/// @desc					Replaces the object in a sequence with a specified living instance.
/// @param {struct} sequence		The instance of the sequence
/// @param {objecttype} object		The object type IN the sequence to be replaced
/// @param {instance} instance		The instance to replace it with
/// @param {string=""} store_as_name	You may specify an alternative to name this instance in the sequence.
///									By default, the object name is used (=the name of whatever you supplied
///									in the instance parameter).
function seq_modify_instance(sequence,object,instance,store_as_name = "") {
	seq_store_instance(sequence, instance, store_as_name);
	sequence_instance_override_object(sequence,object,instance);
}

/// @func					seq_store_instance(sequence, instance, store_as_name = "")
/// @desc				Store any instance in the sequence for later retrieval
/// @param {struct} sequence		The instance of the sequence
/// @param {instance} instance		The instance to store
/// @param {string=""} store_as_name	You may specify an alternative to name this instance in the sequence.
///									By default, the object name is used (=the name of whatever you supplied
///									in the instance parameter).
function seq_store_instance(sequence, instance, store_as_name = "") {
	if (store_as_name == "") store_as_name = object_get_name(instance.object_index);
	sequence[$ SEQUENCE_CUSTOM_INSTANCES][$ store_as_name] = instance;
}

/// @func					seq_get_stored_instance(sequence,stored_name)
/// @desc				Get a stored instance out of a sequence instance
/// @param {struct} sequence	The instance of the sequence
/// @param {string} stored_name	The name of the instance to retrieve (see seq_modify_instance).
/// @returns {instance}			The instance retrieved.
function seq_get_stored_instance(sequence,stored_name) {
	if (!is_string(stored_name)) stored_name = object_get_name(stored_name.object_index);
	return sequence[$ SEQUENCE_CUSTOM_INSTANCES][$ stored_name];
}

/// @func					seq_get_stored_instances(sequence)
/// @desc				Gets the struct of all stored instances from a sequence instance.
/// @param {struct} sequence	The instance of the sequence
/// @returns {struct}			The stored instances
function seq_get_stored_instances(sequence) {
	return struct_get(sequence,SEQUENCE_CUSTOM_INSTANCES);
}

/// @func					seq_destroy(sequence)
/// @desc				Shortcut for layer_sequence_destroy(sequence.elementID)
/// @param {struct} sequence	The instance of the sequence to destroy
function seq_destroy(sequence) {
	vlog($"Destroying sequence: sequence='{sequence.name}'; elementID={sequence.elementID};");
	layer_sequence_destroy(sequence.elementID);
}