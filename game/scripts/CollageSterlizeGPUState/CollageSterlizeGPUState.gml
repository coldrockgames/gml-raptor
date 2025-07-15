/// @func CollageSterlizeGPUState()
/// feather ignore all
function CollageSterlizeGPUState() {
	gml_pragma("forceinline");
	var _instance = __CollageGPUStateSingleton()
	if (_instance.isSterilized) {
		__CollageThrow("GPU has been already sterlized! Please call CollageRestoreGPUState()!")
	}
	_instance.isSterilized = true;
	// Get GPU state
	_instance.gpuBlendEnable =		gpu_get_blendenable();
	_instance.gpuBlendMode =		gpu_get_blendmode_ext_sepalpha();
	_instance.gpuColourWrite =		gpu_get_colourwriteenable();
	_instance.gpuAlphaTest =			gpu_get_alphatestenable();
	_instance.gpuTexFilter =			gpu_get_texfilter();
	_instance.gpuFog =					gpu_get_fog();
	_instance.gpuLighting =			draw_get_lighting();
	_instance.gpuColour =				draw_get_color();
	_instance.gpuAlpha =				draw_get_alpha();
	_instance.gpuZWrite =				gpu_get_zwriteenable();
	_instance.gpuZTest =				gpu_get_ztestenable();
	_instance.gpuCullmode =			gpu_get_cullmode();
	_instance.gpuZFunc =				gpu_get_zfunc();
	_instance.gpuFiltering =			gpu_get_tex_filter();
	_instance.gpuMipEnabled =		gpu_get_tex_mip_enable();
	_instance.matrixWorld =			matrix_get(matrix_world);
	_instance.matrixView =				matrix_get(matrix_view);
	_instance.matrixProj =				matrix_get(matrix_projection);
	_instance.shader =					shader_current();
	
	// Change GPU settings
	static _matrixDefault = matrix_build_identity();
	gpu_set_blendenable(false);
	gpu_set_blendmode(bm_normal);
	gpu_set_colourwriteenable(true, true, true, true);
	gpu_set_alphatestenable(false);
	gpu_set_texfilter(false);
	gpu_set_fog(false, c_black, 0, 1);
	draw_set_colour(c_white);
	draw_set_alpha(1);
	gpu_set_zwriteenable(false);
	gpu_set_ztestenable(false);
	gpu_set_cullmode(cull_noculling);
	gpu_set_zfunc(cmpfunc_lessequal);
	gpu_set_tex_filter(false);
	gpu_set_tex_mip_enable(false);
	matrix_set(matrix_world, _matrixDefault);
	matrix_set(matrix_view, _matrixDefault);
	matrix_set(matrix_projection, _matrixDefault);
	shader_reset();
}