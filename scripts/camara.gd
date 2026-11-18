class_name CamaraJuego
extends Camera3D

# CÁMARA DEL JUEGO: GIRA CON LAS FLECHAS Y SE SACUDE EN LOS GOLPES

@export var velocidad_giro := 1.8      # RADIANES POR SEGUNDO
@export var velocidad_zoom := 0.8

var centro := Vector3.ZERO
var lejos := 8.0
var angulo := 0.0
var zoom := 1.0
var _fuerza := 0.0

# APUNTA AL CENTRO DEL TABLERO Y VUELVE A LA VISTA DE FRENTE
func enfocar(c: Vector3, tam: float) -> void:
	centro = c
	lejos = tam
	angulo = 0.0
	zoom = 1.0
	_ubicar()

func _ubicar() -> void:
	var d := Vector3(0, lejos * 0.75 + 3.0, lejos * 0.55 + 3.0) * zoom
	position = centro + d.rotated(Vector3.UP, angulo)
	look_at(centro)

# CUÁNTOS CUARTOS DE VUELTA LLEVA (0 A 3), PARA QUE W SIEMPRE SEA "ADELANTE"
func cuartos() -> int:
	return posmod(roundi(angulo / (PI / 2.0)), 4)

func sacudir(fuerza: float) -> void:
	_fuerza = maxf(_fuerza, fuerza)

func _process(delta: float) -> void:
	# FLECHAS: GIRAR ALREDEDOR DEL TABLERO Y ACERCAR O ALEJAR
	var antes := Vector2(angulo, zoom)
	if Input.is_key_pressed(KEY_LEFT):
		angulo -= velocidad_giro * delta
	if Input.is_key_pressed(KEY_RIGHT):
		angulo += velocidad_giro * delta
	if Input.is_key_pressed(KEY_UP):
		zoom = maxf(zoom - velocidad_zoom * delta, 0.5)
	if Input.is_key_pressed(KEY_DOWN):
		zoom = minf(zoom + velocidad_zoom * delta, 1.8)
	if Vector2(angulo, zoom) != antes:
		_ubicar()

	# SACUDIDA
	if _fuerza <= 0.001:
		h_offset = 0.0
		v_offset = 0.0
		return
	h_offset = randf_range(-_fuerza, _fuerza)
	v_offset = randf_range(-_fuerza, _fuerza)
	_fuerza = move_toward(_fuerza, 0.0, delta * 0.4)
