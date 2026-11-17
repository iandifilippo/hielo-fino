class_name Bloque
extends Node3D
 
# El bloque de hielo de 1 x 1 x 2. Parado ocupa 1 casilla, acostado ocupa 2.
# o = "S" parado, "X" acostado a lo largo de X, "Z" acostado a lo largo de Z.
# La malla (Malla) está en la escena bloque.tscn.
 
signal termino_volteo
signal aparecio
 
@export var duracion := 0.2   # segundos por volteo
 
var bx := 0
var bz := 0
var o := "S"
var moviendo := false
var _hundir: Tween
var _entrada: Tween
 
func colocar(x: int, z: int, ori: String) -> void:
	bx = x
	bz = z
	o = ori
	if _hundir and _hundir.is_valid():
		_hundir.kill()
	if _entrada and _entrada.is_valid():
		_entrada.kill()
	transform = transform_de(x, z, ori)
	visible = true
 
func celdas() -> Array[Vector2i]:
	return celdas_de(bx, bz, o)
 
static func celdas_de(x: int, z: int, ori: String) -> Array[Vector2i]:
	if ori == "S":
		return [Vector2i(x, z)]
	if ori == "X":
		return [Vector2i(x, z), Vector2i(x + 1, z)]
	return [Vector2i(x, z), Vector2i(x, z + 1)]
 
# A dónde queda el bloque si se voltea hacia dir (x a la derecha, y hacia la cámara)
static func siguiente(x: int, z: int, ori: String, dir: Vector2i) -> Array:
	if ori == "S":
		if dir.x == 1: return [x + 1, z, "X"]
		if dir.x == -1: return [x - 2, z, "X"]
		if dir.y == 1: return [x, z + 1, "Z"]
		return [x, z - 2, "Z"]
	if ori == "X":
		if dir.x == 1: return [x + 2, z, "S"]
		if dir.x == -1: return [x - 1, z, "S"]
		return [x, z + dir.y, "X"]
	# ori == "Z"
	if dir.y == 1: return [x, z + 2, "S"]
	if dir.y == -1: return [x, z - 1, "S"]
	return [x + dir.x, z, "Z"]
 
static func transform_de(x: int, z: int, ori: String) -> Transform3D:
	if ori == "S":
		return Transform3D(Basis(), Vector3(x + 0.5, 1.0, z + 0.5))
	if ori == "X":
		return Transform3D(Basis(Vector3(0, 0, 1), PI / 2), Vector3(x + 1.0, 0.5, z + 0.5))
	return Transform3D(Basis(Vector3(1, 0, 0), PI / 2), Vector3(x + 0.5, 0.5, z + 1.0))
 
func voltear(dir: Vector2i, nuevo: Array) -> void:
	moviendo = true
	var d3 := Vector3(dir.x, 0, dir.y)
	# El bloque gira sobre el borde de abajo que está hacia donde se mueve
	var centro := Vector3.ZERO
	for c in celdas():
		centro += Vector3(c.x + 0.5, 0, c.y + 0.5)
	centro /= celdas().size()
	var mitad := 0.5
	if (o == "X" and dir.x != 0) or (o == "Z" and dir.y != 0):
		mitad = 1.0
	var pivote := centro + d3 * mitad
	var eje := Vector3.UP.cross(d3)
	var inicio := transform
	var tw := create_tween()
	tw.tween_method(_rodar.bind(inicio, pivote, eje), 0.0, PI / 2, duracion)
	await tw.finished
	colocar(nuevo[0], nuevo[1], nuevo[2])
	moviendo = false
	termino_volteo.emit()
 
func _rodar(angulo: float, inicio: Transform3D, pivote: Vector3, eje: Vector3) -> void:
	var giro := Transform3D(Basis(eje, angulo), Vector3.ZERO)
	transform = Transform3D(Basis(), pivote) * giro * Transform3D(Basis(), -pivote) * inicio
 
func hundir(profundidad: float, segundos: float) -> void:
	_hundir = create_tween()
	_hundir.tween_property(self, "position:y", position.y - profundidad, segundos)
	# AL TERMINAR SE ESCONDE, ASÍ NO SE MONTA SOBRE LA CASILLA
	_hundir.tween_callback(hide)

# CAE DESDE ARRIBA AL EMPEZAR EL NIVEL
func aparecer(retraso: float) -> void:
	var abajo := position.y
	position.y = abajo + 4.0
	visible = false
	moviendo = true
	_entrada = create_tween()
	_entrada.tween_interval(retraso)
	_entrada.tween_callback(show)
	_entrada.tween_property(self, "position:y", abajo, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_entrada.tween_callback(_al_aparecer)

func _al_aparecer() -> void:
	moviendo = false
	aplastar()
	aparecio.emit()

# SE APLASTA UN POQUITO AL CAER
func aplastar() -> void:
	var m: Node3D = $Malla
	var tw := create_tween()
	tw.tween_property(m, "scale", Vector3(1.08, 0.9, 1.08), 0.06)
	tw.tween_property(m, "scale", Vector3.ONE, 0.12)
