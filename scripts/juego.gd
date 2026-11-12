extends Node3D

# Arma el nivel, lee las teclas y aplica las reglas de Hielo Fino.

var datos: Dictionary
var casillas := {}            # Vector2i -> Casilla
var meta := Vector2i.ZERO
var bloque: Bloque
var tablero: Node3D
var camara: Camera3D

var historial := []           # cómo estaba todo antes de cada volteo (para Z)
var volteos := 0
var tiempo := 0.0
var estado := "jugando"       # "jugando", "caido" o "gano"
var quieto := 0.0             # segundos sin tocar nada (para la ayuda del tutorial)

var lbl_titulo: Label
var lbl_info: Label
var lbl_mensaje: Label
var lbl_ayuda: Label

func _ready() -> void:
	_crear_mundo()
	_crear_hud()
	cargar_nivel(Niveles.actual)

# ---------- armar la escena ----------

func _crear_mundo() -> void:
	var entorno := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.08, 0.16)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.62, 0.8)
	env.ambient_light_energy = 0.6
	entorno.environment = env
	add_child(entorno)

	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-55, -30, 0)
	luz.shadow_enabled = true
	add_child(luz)

	var agua := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(80, 80)
	agua.mesh = plano
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.04, 0.12, 0.25)
	agua.material_override = mat
	agua.position = Vector3(0, -0.8, 0)
	add_child(agua)

	camara = Camera3D.new()
	add_child(camara)

	tablero = Node3D.new()
	add_child(tablero)

	bloque = Bloque.new()
	add_child(bloque)

func _crear_hud() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)
	lbl_titulo = _label(capa, Vector2(20, 15), 28)
	lbl_info = _label(capa, Vector2(20, 55), 20)
	lbl_mensaje = _label(capa, Vector2(20, 95), 24)
	lbl_mensaje.add_theme_color_override("font_color", Color(1, 0.8, 0.4))
	lbl_ayuda = _label(capa, Vector2(20, 135), 22)
	var teclas := _label(capa, Vector2(20, 175), 16)
	teclas.text = "Flechas / WASD: voltear   Z: deshacer   R: reiniciar   Esc: menú"

func _label(padre: Node, pos: Vector2, tam: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", tam)
	padre.add_child(l)
	return l

# ---------- cargar un nivel ----------

func cargar_nivel(i: int) -> void:
	datos = Niveles.LISTA[i]
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
			var c := Casilla.new()
			c.position = Vector3(x + 0.5, -0.15, z + 0.5)
			tablero.add_child(c)
			c.configurar(letra)
			casillas[Vector2i(x, z)] = c
			if letra == "I":
				inicio = Vector2i(x, z)
			elif letra == "M":
				meta = Vector2i(x, z)
	bloque.colocar(inicio.x, inicio.y, "S")

	# La cámara mira al centro del tablero desde arriba y adelante
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
	lbl_titulo.text = "Nivel %d: %s" % [i + 1, datos["nombre"]]
	lbl_mensaje.text = ""
	lbl_ayuda.text = ""
	if i == 0:
		lbl_mensaje.text = "Lleva el bloque PARADO hasta la casilla naranja"

# ---------- cada frame ----------

func _process(delta: float) -> void:
	if estado != "gano":
		tiempo += delta
	quieto += delta
	if Niveles.actual == 0 and volteos == 0 and quieto > 4.0:
		lbl_ayuda.text = "Usa las flechas  ←  ↑  ↓  →  (o W A S D)"
	lbl_info.text = "Volteos: %d   (par: %d)     Tiempo: %.1f s" % [volteos, datos["par"], tiempo]

# ---------- teclas ----------

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
			cargar_nivel(Niveles.actual)
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			if estado == "gano":
				siguiente_nivel()
		KEY_ESCAPE:
			get_tree().change_scene_to_file("res://escenas/menu.tscn")

# ---------- reglas ----------

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
		return   # en el tutorial el borde no deja caer

	_guardar()
	var viejas := bloque.celdas()
	volteos += 1
	lbl_ayuda.text = ""
	await bloque.voltear(dir, sig)

	# Las casillas que ya aguantaron todo se rompen cuando el bloque se va
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
	if Niveles.actual >= Niveles.LISTA.size():
		Niveles.actual = 0
		get_tree().change_scene_to_file("res://escenas/menu.tscn")
	else:
		cargar_nivel(Niveles.actual)
