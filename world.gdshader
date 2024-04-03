shader_type spatial;

uniform vec3 color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 loc = UV;// + mod(TIME / 10.0, 1.0);
	vec2 colors = step(0.5, mod(16.0 * loc, 1));
	ALBEDO = vec3(colors.x) * vec3(colors.y) + vec3(1.0 - colors.x) * vec3(1.0 - colors.y);
	ALBEDO = ALBEDO * color;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
