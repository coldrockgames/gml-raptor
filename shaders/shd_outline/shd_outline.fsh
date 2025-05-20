///
/// variable-pixel-width outline shader
/// Based on juju adams' selective outline and improved with alpha fading and variable thickness
/// even on HTML5 target
///
///		(c)2022- coldrock.games, @grisgram at github
///		Please respect the MIT License for this Library.
///
///

const float ALPHA_THRESHOLD      = 1.0/255.0;
const float BRIGHTNESS_THRESHOLD = 1.0;
const float MAX_OUTLINE_STRENGTH = 10.0;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vSurfaceUV;

uniform sampler2D u_sSpriteSurface;
uniform vec2 u_vTexel;
uniform vec3 u_vOutlineColour1;
uniform vec3 u_vOutlineColour2;
uniform vec2 u_vThickness;
uniform vec4 u_vPulse;

vec4 unpackGMColour(vec3 colourAlpha, float aVal)
{
    vec4 result = vec4(0.0, 0.0, 0.0, aVal * colourAlpha.y * 255.0);
    result.b = floor( colourAlpha.x / 65536.0);
    result.g = floor((colourAlpha.x - result.b*65536.0)/256.0);
    result.r = floor( colourAlpha.x - result.b*65536.0 - result.g*256.0);
    return result/255.0;
}

float getBrightness(vec3 colour)
{
    return max(max(colour.r, colour.g), colour.b);
}

void main()
{
    vec4  spriteSample  = texture2D(u_sSpriteSurface, v_vSurfaceUV);
	//float spritePow = pow(1.0 / spriteSample.a, 3.0);
	if (spriteSample.a > ALPHA_THRESHOLD) 
		spriteSample.a = 0.5 * u_vOutlineColour1.z + 0.541;
		//spriteSample.a = u_vOutlineColour1.z * spritePow;
		//spriteSample.a = 0.5 * u_vOutlineColour1.z + 0.5;
		//spriteSample.a = u_vOutlineColour1.z + spriteSample.a * u_vOutlineColour1.z;
	float alphaVal		= 0.0;	// set by both for loops below (decides alpha fading)
    float edgeAlphaMax	= 0.0;

	// Pulse implementation: vec4(min,max,freq,time)
	// one wave (one frequency) goes min-max-min
	float pmin  = u_vPulse[0];
	float pmax  = u_vPulse[1];
	float pfreq = u_vPulse[2];
	float ptime = u_vPulse[3];

	float pit = mod(ptime, pfreq) / pfreq;
	if (pit > 0.5) pit = 1.0 - pit;	
	float thickness = ceil(pmin + (pmax - pmin) * pit);

	// The "continue" and "breaks" in the loops below are for HTML/WEBGL compatibility
	// A WebGL shader must be compiled with a constant range in "for" loops.
	// So I defined a max-width of 10 for the outline but skip all values 
	// below and above the desired range. A minor performance loss and a great comfort gain

	if (u_vThickness.y == 1.0) { // Alpha fading = true
		float pxCount = thickness * thickness;
		float pxHit = 0.0; 
		float curA = 0.0;
		for(float dX = -MAX_OUTLINE_STRENGTH; dX <= MAX_OUTLINE_STRENGTH; dX += 1.0)
		{
			if (dX < -thickness) continue;
			
		    for(float dY = -MAX_OUTLINE_STRENGTH; dY <= MAX_OUTLINE_STRENGTH; dY += 1.0)
		    {
				if (dY < -thickness) continue;
				
				curA = texture2D(u_sSpriteSurface, v_vSurfaceUV + vec2(dX, dY)*u_vTexel).a;
				if (curA >= ALPHA_THRESHOLD) pxHit++;
		        edgeAlphaMax = max(edgeAlphaMax, curA);
				
				if (dY >= thickness) break;
		    }
			
			if (dX >= thickness) break;
		}
		alphaVal = pxHit/pxCount;
	} else { // no alpha fading
	    for(float dX = -MAX_OUTLINE_STRENGTH; dX <= MAX_OUTLINE_STRENGTH; dX += 1.0)
	    {
			if (dX < -thickness) continue;
			
	        for(float dY = -MAX_OUTLINE_STRENGTH; dY <= MAX_OUTLINE_STRENGTH; dY += 1.0)
	        {
				if (dY < -thickness) continue;
	            edgeAlphaMax = max(edgeAlphaMax, texture2D(u_sSpriteSurface, v_vSurfaceUV + vec2(dX, dY)*u_vTexel).a);
				if (dY >= thickness) break;
	        }
			
			if (dX >= thickness) break;
	    }
		alphaVal = edgeAlphaMax;
	}
    
    float appSurfBrightness = getBrightness(texture2D(gm_BaseTexture, v_vTexcoord).rgb);
    
//    gl_FragColor = vec4(0.0);
    
    if (spriteSample.a < ALPHA_THRESHOLD && 
		edgeAlphaMax >= ALPHA_THRESHOLD && 
		appSurfBrightness < BRIGHTNESS_THRESHOLD) {
		vec4 c1 = unpackGMColour(u_vOutlineColour1, alphaVal);
		vec4 c2 = unpackGMColour(u_vOutlineColour2, alphaVal);
		pit *= 2.0;
        gl_FragColor = c1 * (1.0 - pit) + c2 * pit;
    } else
	    gl_FragColor = spriteSample;
}

