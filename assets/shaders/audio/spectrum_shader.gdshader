shader_type canvas_item;
uniform sampler2D audio_texture;
uniform int sample_rate = 44100;
uniform float start_time = 0.0;
uniform float end_time = 1.0;

uniform float divisor = 1.0;

#include "res://assets/shaders/includes/cmath.gdshaderinc"

vec3 HSV2RGB(vec3 HSV){
	vec3 c = HSV;
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec2 get_sample_at_index(int index, sampler2D wave_texture){
	ivec2 wave_texture_size = textureSize(wave_texture, 0);
	ivec2 sample_coords = ivec2(index%wave_texture_size.x,index/wave_texture_size.x);
	return texelFetch(wave_texture,sample_coords, 0).rg;
}

void fragment() {
	int sample_index = int(round(mix(start_time*float(sample_rate),end_time*float(sample_rate),UV.x)));
	vec2 temp = vec2(0.0);
	int frequency_idx = int(UV.y*512.0);
	for(int k = 0; k < 512; k++){
		vec2 fft_sample = vec2(get_sample_at_index(k+sample_index,audio_texture).r,0.0);
		temp += cmult(fft_sample, cexp(vec2(0.0,-2.0)*PI*float(frequency_idx)*float(k)/512.0));
	}
	float amp = length(temp);
	vec3 hsv = vec3(amp/divisor,1.0,1.0);
	COLOR.rgb = HSV2RGB(hsv);
//	COLOR.rgb = vec3(0.0);
//	COLOR.b = 1.0;
//	COLOR.rgb = vec3(amp);
//	COLOR.r = PI;
}
