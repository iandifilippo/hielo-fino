shader_type spatial;
render_mode specular_schlick_ggx;

// AGUA CON OLAS SUAVES. TODO SE AJUSTA DESDE EL INSPECTOR
uniform vec4 color_profundo : source_color = vec4(0.02, 0.09, 0.22, 1.0);
uniform vec4 color_claro : source_color = vec4(0.08, 0.32, 0.55, 1.0);
uniform float velocidad = 0.6;
uniform float altura_ola = 0.06;
uniform float tamano_ola = 0.8;
uniform float fuerza_reflejos = 0.35;

varying vec3 pos_mundo;

float ola(vec2 p, float t) {
	return sin(p.x * 1.3 + t) * 0.5
		+ sin(p.y * 1.7 - t * 1.2) * 0.5
		+ sin((p.x + p.y) * 0.9 + t * 0.7) * 0.4;
}

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += ola(pos_mundo.xz * tamano_ola, TIME * velocidad) * altura_ola;
}

void fragment() {
	vec2 p = pos_mundo.xz * tamano_ola;
	float t = TIME * velocidad;
	float e = 0.05;
	float dx = ola(p + vec2(e, 0.0), t) - ola(p - vec2(e, 0.0), t);
	float dz = ola(p + vec2(0.0, e), t) - ola(p - vec2(0.0, e), t);
	NORMAL_MAP = vec3(0.5 - dx * 2.0, 0.5 - dz * 2.0, 1.0);

	float h = ola(p, t) * 0.5 + 0.5;
	ALBEDO = mix(color_profundo.rgb, color_claro.rgb, h * 0.6);

	// REFLEJOS DE LUZ QUE SE MUEVEN
	float c = abs(sin(p.x * 3.0 + t * 1.5) + sin(p.y * 3.3 - t * 1.3)) * 0.5;
	EMISSION = color_claro.rgb * pow(c, 6.0) * fuerza_reflejos;

	ROUGHNESS = 0.05;
	METALLIC = 0.1;
	SPECULAR = 0.9;
}
