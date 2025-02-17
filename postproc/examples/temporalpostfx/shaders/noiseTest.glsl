
uniform sampler2D Texture0;
uniform vec2 RenderSize;


//#define MOD2 vec2(12.9898, 78.233 )
#define MOD2 vec2(443.8975,397.2973)

float iGlobalTime = 0.0;

// should exhibit artefact on some gpu
float noiseInline(vec2 uv){
    return fract(sin(dot(uv.xy,MOD2)) * 43758.5453);
}

// from https://www.shadertoy.com/view/4t2SDh
float noiseSketchfab(vec2 uv){
    float nrnd0 = noiseInline(uv);
    //float nrnd0 = hash12( n + 0.07*t );
    // Convert uniform distribution into triangle-shaped distribution.
    float orig = nrnd0*2.0-1.0;
    nrnd0 = orig*inversesqrt(abs(orig));
    nrnd0 = max(-1.0,nrnd0); // Nerf the NaN generated by 0*rsqrt(0). Thanks @FioraAeterna!
    nrnd0 = nrnd0-sign(orig)+0.5;
    // Result is range [-0.5,1.5] which is
    // useful for actual dithering.
    // convert to [0,1] for histogram.
   return nrnd0;
   //  return (nrnd0 + 0.5) * 0.5;
}

float hash12(vec2 n){
  vec2 p2 = fract(n *MOD2);
        p2 += dot(p2.yx, p2.xy+19.19);
        return fract(p2.x * p2.y);
}

float noiseHash12(vec2 uv){
    float nrnd0 = hash12(uv);
    //float nrnd0 = hash12( n + 0.07*t );
    // Convert uniform distribution into triangle-shaped distribution.
    float orig = nrnd0*2.0-1.0;
    nrnd0 = orig*inversesqrt(abs(orig));
    nrnd0 = max(-1.0,nrnd0); // Nerf the NaN generated by 0*rsqrt(0). Thanks @FioraAeterna!
    nrnd0 = nrnd0-sign(orig)+0.5;
    // Result is range [-0.5,1.5] which is
    // useful for actual dithering.
    // convert to [0,1] for histogram.
   return nrnd0;
  // return (nrnd0 + 0.5) * 0.5;
}

void main(  )
{
	vec2 uv = gl_FragCoord.xy / RenderSize.xy;
    vec2 step = 1.0 / RenderSize.xy;
    float noise = 0.0;
    
    vec2 uvNoise = uv * 2.0 + 0.00007*iGlobalTime;
        if(uv.x < 0.33) noise = noiseInline(uvNoise);
        else if(uv.x > 0.335 && uv.x < 0.66) noise = noiseSketchfab(uvNoise);
        else if(uv.x > 0.665) noise = noiseHash12(uvNoise);
    gl_FragColor = vec4(vec3(noise),1.0);
}