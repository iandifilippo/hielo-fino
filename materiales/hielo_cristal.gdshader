shader_type spatial;
render_mode specular_schlick_ggx;

// HIELO FACETADO TIPO CRISTAL. TODO SE AJUSTA DESDE EL INSPECTOR
uniform vec4 color_claro : source_color = vec4(0.72, 0.88, 1.0, 1.0);
uniform vec4 color_oscuro : source_color = vec4(0.30, 0.50, 0.95, 1.0);
uniform float facetas_por_metro = 3.0;   // MÁS ALTO = TRIÁNGULOS MÁS PEQUEÑOS
uniform float inclinacion = 0.6;         // CUÁNTO REFLEJA DISTINTO CADA FACETA
uniform float grosor_borde = 0.035;      // LÍNEAS CLARAS ENTRE FACETAS
uniform float brillo_borde = 0.35;
uniform float brillo_fresnel = 0.5;      // BRILLO EN LOS BORDES
uniform float destellos = 0.6;           // CHISPITAS QUE TITILAN

varying vec3 pos_mundo;
varying vec3 normal_mundo;

float azar(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	normal_mundo = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// PLANO SEGÚN LA CARA (ARRIBA O LADOS)
	vec3 n = abs(normal_mundo);
	vec2 uv = n.y > 0.5 ? pos_mundo.xz : (n.x > 0.5 ? pos_mundo.zy : pos_mundo.xy);
	uv *= facetas_por_metro;

	// CUADRÍCULA DE TRIÁNGULOS
	vec2 celda = floor(uv);
	vec2 f = fract(uv);
	float tri = f.x > f.y ? 1.0 : 0.0;
	vec2 id = vec2(celda.x * 2.0 + tri, celda.y);
	float r1 = azar(id);
	float r2 = azar(id + 17.3);
	float r3 = azar(id + 41.7);

	// CADA FACETA INCLINADA DISTINTO, REFLEJA COMO CRISTAL
	NORMAL_MAP = vec3(0.5 + (r1 - 0.5) * inclinacion, 0.5 + (r2 - 0.5) * inclinacion, 1.0);

	// BORDES CLAROS ENTRE FACETAS
	float d_lado = min(min(f.x, f.y), min(1.0 - f.x, 1.0 - f.y));
	float d_diag = abs(f.x - f.y) * 0.7071;
	float borde = 1.0 - smoothstep(0.0, grosor_borde, min(d_lado, d_diag));

	vec3 color = mix(color_oscuro.rgb, color_claro.rgb, 0.3 + r3 * 0.6);
	ALBEDO = color + borde * brillo_borde;
	ROUGHNESS = 0.08;
	METALLIC = 0.15;
	SPECULAR = 0.8;

	// BRILLO SEGÚN EL ÁNGULO DE LA CÁMARA
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION = color_claro.rgb * fresnel * brillo_fresnel;

	// DESTELLOS EN ALGUNAS FACETAS
	if (r3 > 0.93) {
		float t = pow(sin(TIME * 3.0 + r1 * 20.0) * 0.5 + 0.5, 8.0);
		EMISSION += vec3(1.0) * t * destellos;
	}
}
