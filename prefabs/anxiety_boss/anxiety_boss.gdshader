shader_type canvas_item;

uniform float progress = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), progress);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
