/// Selective Outline Shader v1.0.0
/// @jujuadams 2019/07/04

attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vSurfaceUV;

void main()
{
    gl_Position  = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.xyz, 1.0);
    
    v_vColour    = in_Colour;
    v_vTexcoord  = in_TextureCoord;
    v_vSurfaceUV = 0.5 * vec2(gl_Position.x, -gl_Position.y) + 0.5;
}
