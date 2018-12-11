shader_type spatial;

varying vec3 n;

void vertex() {
	n = NORMAL;
}

void fragment() {
	if (n.y == 1.0) {
		ALPHA = 1.0;
	} else {
		ALPHA = 0.0;
	}
}