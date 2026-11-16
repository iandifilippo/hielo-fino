shader_type sky;

// CIELO DE NOCHE CON DEGRADADO Y ESTRELLAS
uniform vec3 color_arriba : source_color = vec3(0.01, 0.02, 0.07);
uniform vec3 color_horizonte : source_color = vec3(0.10, 0.18, 0.35);
uniform float cantidad_estrellas = 0.996;   // MÁS CERCA DE 1 = MENOS ESTRELLAS
uniform float brillo_estrellas = 1.2;

float azar(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

void sky() {
	float alto = clamp(EYEDIR.y, 0.0, 1.0);
	vec3 color = mix(color_horizonte, color_arriba, pow(alto, 0.5));

	// ESTRELLAS QUE TITILAN
	vec3 celda = floor(EYEDIR * 180.0);
	float r = azar(celda);
	if (r > cantidad_estrellas && EYEDIR.y > 0.05) {
		float titila = 0.6 + 0.4 * sin(TIME * 2.0 + r * 60.0);
		color += vec3(brillo_estrellas * titila);
	}
	COLOR = color;
}
