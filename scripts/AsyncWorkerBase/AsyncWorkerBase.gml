/*
    Runs any task async.
	
	TREAT THIS AS ABSTRACT BASE CLASS.
	YOU MUST OVERRIDE THE start() FUNCTION TO MAKE THIS CLASS DO ANYTHING.
	SEE THE __FILE_ASYNC_WORKER CLASSES FOR AN IMPLEMENTATION EXAMPLE.
	
	This base class offers a builder pattern and allows a series of callbacks to
	be added (multiple on_finished and on_failed callbacks) and a transaction mode.
	
	Transaction mode means, no callbacks are invoked automatically, you have to call them
	through .invoke_finished or .invoke_failed after your work is done, even if this is split
	across several objects.
	The Savegame System of raptor uses the transaction mode when loading a game, as the file
	is read at one point, then the room changes to the restored room and loading continues in 
	the new room. Only after restoring all objects is finished, the callbacks get invoked.

*/

/// @func	AsyncWorkerBase(_topic = "AsyncWorker") : DataBuilder() constructor
function AsyncWorkerBase(_topic = "AsyncWorker") : DataBuilder() constructor {
	construct(AsyncWorkerBase);

	started					= false;
	transactional			= false;
	
	__finished_callbacks	= [];
	__failed_callbacks		= [];
	
	__topic					= _topic;

	/// @func	on_start()
	/// @desc	Starts the async operation. You will receive either on_finished or on_failed
	///			when the operation is complete.
	on_start = function() {
	}

	/// @func	start()
	start = function() {
		if (started) return self;
		started = true;
		on_start();
		return self;
	}

	/// @func	on_cleanup()
	/// @desc	Perform struct cleanup and destroy buffers
	on_cleanup = function() {
	}

	/// @func	cleanup()
	cleanup = function() {
		on_cleanup();
		return self;
	}
	
	/// @func	set_transaction_mode(_transactional)
	/// @desc	By default false, but if you activate this, the .on_finished and .on_failed
	///			callbacks will NOT be launched automatically, instead, you have to call
	///			.invoke_finished()/.invoke_failed() manually to launch the registered callbacks.
	///			Use this feature in delayed/split file operations that shall not autocomplete.
	static set_transaction_mode = function(_transactional) {
		transactional = _transactional;
		ilog($"{name_of(self, false)} transaction mode for '{__topic}' is now {(transactional ? "ON" : "OFF")}");
		return self;
	}

	/// @func	invoke_finished(_data = undefined)
	/// @desc	NOTE: Works only in transactional mode!
	///			Invokes the finished callbacks now (see set_transaction_mode)
	static invoke_finished = function(_data = undefined) {
		if (transactional) {
			ilog($"{name_of(self, false)} invoking transactional .on_finished callbacks");
			TRY		__invoke_array(__finished_callbacks, _data);
			CATCH	__invoke_array(__failed_callbacks, _data);
			FINALLY	cleanup();
			ENDTRY
		} else
			__invoke_array(__finished_callbacks, _data);

		return self;
	}

	/// @func	invoke_failed()
	/// @desc	NOTE: Works only in transactional mode!
	///			Invokes the failed callbacks now (see set_transaction_mode)
	static invoke_failed = function() {
		if (transactional) {
			ilog($"{name_of(self, false)} invoking transactional .on_failed callbacks");
			TRY		__invoke_array(__failed_callbacks);
			CATCH 
			FINALLY	cleanup();
			ENDTRY
		} else
			__invoke_array(__failed_callbacks);
			
		return self;
	}
	
	/// @func	on_finished(_callback)
	/// @desc	Set the function to be called when the file access finishes successfully.
	///			The callback receives 1 argument: 
	///				result (the raptor_data loaded from file or undefined if nothing could be loaded)
	static on_finished = function(_callback) {
		array_push(__finished_callbacks, _callback);
		return self;
	}

	/// @func	on_failed(_callback)
	/// @desc	Set the function to be called when the file access fails.
	///			The callback receives no arguments
	static on_failed = function(_callback) {
		array_push(__failed_callbacks, _callback);
		return self;
	}

	static __invoke_array = function(_array, _arg = undefined) {
		if (_arg == undefined)
			for (var i = 0, len = array_length(_array); i < len; i++)
				_array[@i](data);
		else
			for (var i = 0, len = array_length(_array); i < len; i++)
				_array[@i](_arg, data);
	}
	
}