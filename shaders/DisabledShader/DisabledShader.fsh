//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 tex = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float gray = dot(tex, vec4(0.299, 0.587, 0.114, 0.0) * 0.50);
	gl_FragColor = vec4(gray, gray, gray, tex.a);
}
