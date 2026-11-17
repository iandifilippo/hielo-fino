class_name Casilla
extends Node3D
 
# Una casilla del tablero: nieve, hielo, hielo agrietado o hoyo meta.
# La malla (Malla) y las grietas (Grieta) están en la escena casilla.tscn.
# Los tres materiales se escogen en el Inspector.
 
@export var mat_nieve: Material
@export var mat_hielo: Material
@export var mat_meta: Material
 
var tipo := "N"
var golpes := 0          # cuántas veces ha aterrizado el bloque encima
var roto := false
 
@onready var malla: MeshInstance3D = $Malla
@onready var grieta: Node3D = $Grieta
var _luz: OmniLight3D
 
func configurar(t: String) -> void:
	tipo = t
	if tipo == "M":
		malla.material_override = mat_meta
		_latir()
	elif tipo == "H" or tipo == "G":
		malla.material_override = mat_hielo
	else:
		malla.material_override = mat_nieve
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
	grieta.visible = (tipo == "H" or tipo == "G") and restantes() == 1

# TIEMBLA MEDIO SEGUNDO PARA AVISAR QUE SE VA A ROMPER
func temblar() -> void:
	var tw := create_tween()
	for i in 10:
		tw.tween_property(malla, "position:x", randf_range(-0.04, 0.04), 0.045)
	tw.tween_property(malla, "position:x", 0.0, 0.05)

# SUBE DESDE EL AGUA AL EMPEZAR EL NIVEL
func entrar(retraso: float) -> void:
	var destino := position.y
	position.y = destino - 1.5
	var tw := create_tween()
	tw.tween_interval(retraso)
	tw.tween_property(self, "position:y", destino, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# LA META BRILLA Y LATE PARA QUE EL OJO SE VAYA A ELLA
func _latir() -> void:
	_luz = OmniLight3D.new()
	_luz.light_color = Color(1.0, 0.6, 0.2)
	_luz.omni_range = 2.5
	_luz.position = Vector3(0, 0.6, 0)
	add_child(_luz)
	var tw := create_tween().set_loops()
	tw.tween_property(_luz, "light_energy", 1.6, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_luz, "light_energy", 0.5, 0.7).set_trans(Tween.TRANS_SINE)
