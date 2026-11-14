extends Node3D

# REGLAS DEL JUEGO Y TECLAS. LO VISUAL ESTÁ EN juego.tscn

@onready var tablero: Node3D = $Tablero
@onready var bloque: Bloque = $Bloque
@onready var camara: Camera3D = $Camara
@onready var lbl_titulo: Label = $HUD/Titulo
@onready var lbl_info: Label = $HUD/Info
@onready var lbl_mensaje: Label = $HUD/Mensaje
@onready var lbl_ayuda: Label = $HUD/Ayuda
@onready var lbl_tiempo: Label = $HUD/Tiempo
@onready var lbl_progreso: Label = $HUD/Progreso

var datos: Dictionary
var casillas := {}            # Vector2i -> Casilla
var meta := Vector2i.ZERO

var historial := []           # FOTOS PARA DESHACER CON Z
var volteos := 0
var tiempo := 0.0
var estado := "jugando"       # "jugando", "caido" o "gano"
var quieto := 0.0             # SEGUNDOS SIN TOCAR NADA

func _ready() -> void:
	cargar_nivel()

# ---------- CARGAR NIVEL ----------

func cargar_nivel() -> void:
	datos = Niveles.nivel()
	for hijo in tablero.get_children():
		hijo.queue_free()
	casillas.clear()
	var inicio := Vector2i.ZERO
	var filas: Array = datos["filas"]
	for z in filas.size():
		var fila: String = filas[z]
		for x in fila.length():
			var letra := fila[x]
			if letra == ".":
				continue
			var c := preload("res://escenas/casilla.tscn").instantiate() as Casilla
			c.position = Vector3(x + 0.5, -0.15, z + 0.5)
			tablero.add_child(c)
			c.configurar(letra)
			casillas[Vector2i(x, z)] = c
			if letra == "I":
				inicio = Vector2i(x, z)
			elif letra == "M":
				meta = Vector2i(x, z)
	bloque.colocar(inicio.x, inicio.y, "S")

	# CÁMARA MIRANDO AL CENTRO DEL TABLERO
	var ancho: float = filas[0].length()
	var alto: float = filas.size()
	var centro := Vector3(ancho / 2.0, 0, alto / 2.0)
	var lejos := maxf(ancho, alto)
	camara.position = centro + Vector3(0, lejos * 0.75 + 3.0, lejos * 0.55 + 3.0)
	camara.look_at(centro)

	historial.clear()
	volteos = 0
	tiempo = 0.0
	quieto = 0.0
	estado = "jugando"
	var nombres := {"facil": "Fácil"}
	lbl_titulo.text = "%s %d: %s" % [nombres[Niveles.pack], Niveles.actual + 1, datos["nombre"]]
	# CONTADOR DE NIVEL ACTUAL / TOTAL
	lbl_progreso.text = "Nivel %d / %d" % [Niveles.actual + 1, Niveles.cantidad()]
	lbl_mensaje.text = ""
	lbl_ayuda.text = ""
	if datos.get("sin_caida", false):
		lbl_mensaje.text = "Lleva el bloque PARADO hasta la casilla naranja"

# ---------- CADA FRAME ----------

func _process(delta: float) -> void:
	if estado != "gano":
		tiempo += delta
	quieto += delta
	if datos.get("sin_caida", false) and volteos == 0 and quieto > 4.0:
		lbl_ayuda.text = "Usa las flechas  ←  ↑  ↓  →  (o W A S D)"
	lbl_info.text = "Volteos: %d   (par: %d)" % [volteos, datos["par"]]
	# RELOJ DE LA ESQUINA
	var seg := int(tiempo)
	lbl_tiempo.text = "%d:%02d" % [seg / 60, seg % 60]

# ---------- TECLAS ----------

func _unhandled_input(event: InputEvent) -> void:
	var tecla := event as InputEventKey
	if tecla == null or not tecla.pressed or tecla.echo:
		return
	quieto = 0.0
	if bloque.moviendo:
		return
	match tecla.keycode:
		KEY_RIGHT, KEY_D:
			mover(Vector2i(1, 0))
		KEY_LEFT, KEY_A:
			mover(Vector2i(-1, 0))
		KEY_UP, KEY_W:
			mover(Vector2i(0, -1))
		KEY_DOWN, KEY_S:
			mover(Vector2i(0, 1))
		KEY_Z:
			deshacer()
		KEY_R:
			cargar_nivel()
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			if estado == "gano":
				siguiente_nivel()
		KEY_ESCAPE:
			get_tree().change_scene_to_file("res://escenas/menu.tscn")

# ---------- REGLAS ----------

func mover(dir: Vector2i) -> void:
	if estado != "jugando":
		return
	var sig := Bloque.siguiente(bloque.bx, bloque.bz, bloque.o, dir)
	var nuevas := Bloque.celdas_de(sig[0], sig[1], sig[2])
	var cae := false
	for c in nuevas:
		if not casillas.has(c) or casillas[c].roto:
			cae = true
	if cae and datos.get("sin_caida", false):
		return   # EN EL TUTORIAL NO SE PUEDE CAER

	_guardar()
	var viejas := bloque.celdas()
	volteos += 1
	lbl_ayuda.text = ""
	await bloque.voltear(dir, sig)

	# SE ROMPEN AL SALIR SI YA NO AGUANTAN MÁS
	for c in viejas:
		casillas[c].al_salir()

	if cae:
		estado = "caido"
		bloque.hundir(3.0, 1.0)
		lbl_mensaje.text = "¡Te caíste!  Z para deshacer o R para reiniciar"
		return

	for c in nuevas:
		casillas[c].aterrizar()

	if sig[2] == "S" and Vector2i(sig[0], sig[1]) == meta:
		_ganar()

func _ganar() -> void:
	estado = "gano"
	bloque.hundir(2.0, 0.8)
	var par: int = datos["par"]
	var estrellas := 1
	if volteos <= par:
		estrellas = 3
	elif volteos <= par * 1.5:
		estrellas = 2
	lbl_mensaje.text = "¡Nivel completado!  %s   Enter para seguir" % "★".repeat(estrellas)

func _guardar() -> void:
	var foto := {}
	for pos in casillas:
		foto[pos] = casillas[pos].estado()
	historial.push_back({"bloque": [bloque.bx, bloque.bz, bloque.o], "casillas": foto})

func deshacer() -> void:
	if historial.is_empty() or estado == "gano":
		return
	var foto: Dictionary = historial.pop_back()
	for pos in foto["casillas"]:
		casillas[pos].restaurar(foto["casillas"][pos])
	var b: Array = foto["bloque"]
	bloque.colocar(b[0], b[1], b[2])
	estado = "jugando"
	lbl_mensaje.text = ""

func siguiente_nivel() -> void:
	Niveles.actual += 1
	if Niveles.actual >= Niveles.cantidad():
		Niveles.actual = 0
		get_tree().change_scene_to_file("res://escenas/menu.tscn")
	else:
		cargar_nivel()
