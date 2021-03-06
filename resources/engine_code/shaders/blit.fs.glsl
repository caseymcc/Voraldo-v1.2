#version 430 core

in vec2 v_pos;

// sampler for main display texture
uniform sampler2DRect main_display_texture;

// supersampling factor, defined in includes.h
uniform float ssfactor;

out vec4 fragment_output;


// TONEMAPPING MODE
uniform int ACES_behavior;

// APPROX
// --------------------------
vec3 cheapo_aces_approx(vec3 v)
{
	v *= 0.6f;
	float a = 2.51f;
	float b = 0.03f;
	float c = 2.43f;
	float d = 0.59f;
	float e = 0.14f;
	return clamp((v*(a*v+b))/(v*(c*v+d)+e), 0.0f, 1.0f);
}


// OFFICIAL
// --------------------------
mat3 aces_input_matrix = mat3(
	0.59719f, 0.35458f, 0.04823f,
	0.07600f, 0.90834f, 0.01566f,
	0.02840f, 0.13383f, 0.83777f
);

mat3 aces_output_matrix = mat3(
	1.60475f, -0.53108f, -0.07367f,
	-0.10208f,  1.10813f, -0.00605f,
	-0.00327f, -0.07276f,  1.07602f
);

vec3 mul(mat3 m, vec3 v)
{
	float x = m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2];
	float y = m[1][0] * v[1] + m[1][1] * v[1] + m[1][2] * v[2];
	float z = m[2][0] * v[1] + m[2][1] * v[1] + m[2][2] * v[2];
	return vec3(x, y, z);
}

vec3 rtt_and_odt_fit(vec3 v)
{
	vec3 a = v * (v + 0.0245786f) - 0.000090537f;
	vec3 b = v * (0.983729f * v + 0.4329510f) + 0.238081f;
	return a / b;
}

vec3 aces_fitted(vec3 v)
{
	v = mul(aces_input_matrix, v);
	v = rtt_and_odt_fit(v);
	return mul(aces_output_matrix, v);
}


// COLOR TEMP ADJUSTMENT
uniform vec3 temp_adjustment;

mat3 temp_adjust(vec3 c)
{
	mat3 t;
	t[0] = vec3(c.r,   0,   0);
	t[1] = vec3(  0, c.g,   0);
	t[2] = vec3(  0,   0, c.b);
	return t;
}

void main()
{
	vec4 texread_color = texture(main_display_texture, ssfactor*(gl_FragCoord.xy + gl_SamplePosition.xy));
	vec4 running_color = texread_color;

	// temperature correction
	running_color.xyz = temp_adjust(temp_adjustment) * running_color.xyz;

	// luminance preservation
	running_color.xyz *= dot(texread_color.xyz, vec3(0.2126, 0.7152, 0.0722)) / max(dot(running_color.xyz, vec3(0.2126, 0.7152, 0.0722)), 1e-5);

	// tonemapping
	switch(ACES_behavior)
	{
		case 0: // no tonemapping
			break;
		case 1: // cheap version
			running_color.xyz = cheapo_aces_approx(running_color.xyz);
			break;
		case 2: // full version
			running_color.xyz = aces_fitted(running_color.xyz);
			break;
	}

	// fragment output
	fragment_output = running_color;
}
