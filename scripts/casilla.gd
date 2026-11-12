class_name Casilla
extends Node3D

# Una casilla del tablero: nieve, hielo, hielo agrietado o hoyo meta.

const COLOR_NIEVE := Color(0.95, 0.96, 0.98)
const COLOR_HIELO := Color(0.62, 0.82, 0.95)
const COLOR_META := Color(0.96, 0.62, 0.15)

var tipo := "N"
var golpes := 0          # cuántas veces ha aterrizado el bloque encima
var roto := false

var _malla: MeshInstance3D
var _grieta: Node3D

func configurar(t: String) -> void:
	tipo = t
	_malla = MeshInstance3D.new()
	var caja := BoxMesh.new()
	caja.size = Vector3(0.96, 0.3, 0.96)
	_malla.mesh = caja
	var mat := StandardMaterial3D.new()
	if tipo == "M":
		mat.albedo_color = COLOR_META
	elif tipo == "H" or tipo == "G":
		mat.albedo_color = COLOR_HIELO
	else:
		mat.albedo_color = COLOR_NIEVE
	_malla.material_override = mat
	add_child(_malla)
	_grieta = _crear_grieta()
	add_child(_grieta)
	actualizar()

func capacidad() -> int:
	if tipo == "H":
		return 2
	if tipo == "G":
		return 1
	return 999   # nieve, inicio y meta no se rompen

# Le quedan aterrizajes antes de romperse
func restantes() -> int:
	return capacidad() - golpes

func aterrizar() -> void:
	golpes += 1
	actualizar()

# Se llama cuando el bloque se va de esta casilla
func al_salir() -> void:
	if golpes >= capacidad():
		roto = true
		actualizar()

func estado() -> Array:
	return [golpes, roto]

func restaurar(e: Array) -> void:
	golpes = e[0]
	roto = e[1]
	actualizar()

func actualizar() -> void:
	visible = not roto
	# Grietas negras cuando solo le queda 1 aterrizaje
	_grieta.visible = (tipo == "H" or tipo == "G") and restantes() == 1

func _crear_grieta() -> Node3D:
	var g := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	for angulo in [35.0, -50.0, 80.0]:
		var linea := MeshInstance3D.new()
		var caja := BoxMesh.new()
		caja.size = Vector3(0.7, 0.02, 0.05)
		linea.mesh = caja
		linea.material_override = mat
		linea.position = Vector3(0, 0.16, 0)
		linea.rotation_degrees = Vector3(0, angulo, 0)
		g.add_child(linea)
	return g
