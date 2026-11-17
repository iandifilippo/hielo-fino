extends Node3D

# REGLAS DEL JUEGO Y TECLAS. LO VISUAL ESTÁ EN juego.tscn

@onready var tablero: Node3D = $Tablero
@onready var bloque: Bloque = $Bloque
@onready var camara: CamaraJuego = $Camara
@onready var lbl_titulo: Label = $HUD/Titulo
@onready var lbl_info: Label = $HUD/Info
@onready var lbl_mensaje: Label = $HUD/Mensaje
@onready var lbl_ayuda: Label = $HUD/Ayuda
@onready var reloj: Reloj = $HUD/Tiempo
@onready var sonidos: Sonidos = $Sonidos
@onready var lbl_progreso: Label = $HUD/Progreso
@onready var lbl_aviso: Label = $HUD/Aviso

var datos: Dictionary
var casillas := {}            # Vector2i -> Casilla
var meta := Vector2i.ZERO

var historial := []           # FOTOS PARA DESHACER CON Z
var volteos := 0
var tiempo := 0.0
var estado := "jugando"       # "jugando", "caido", "gano" O "tiempo"
var quieto := 0.0             # SEGUNDOS SIN TOCAR NADA
var entrando := 0.0           # SEGUNDOS QUE DURA LA ENTRADA DEL NIVEL

func _ready() -> void:
	bloque.aparecio.connect(_al_aparecer_bloque)
	cargar_nivel()

# EL BLOQUE CAE AL EMPEZAR: GOLPE Y TEMBLOR
func _al_aparecer_bloque() -> void:
	camara.sacudir(0.05)
	sonidos.tocar("golpe", 0.85)

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
			# ENTRADA EN OLA: PRIMERO LAS DE ARRIBA A LA IZQUIERDA
			c.entrar((x + z) * 0.035)
			casillas[Vector2i(x, z)] = c
			if letra == "I":
				inicio = Vector2i(x, z)
			elif letra == "M":
				meta = Vector2i(x, z)
	bloque.colocar(inicio.x, inicio.y, "S")
	var ultima: float = (filas[0].length() + filas.size()) * 0.035
	bloque.aparecer(ultima + 0.2)
	entrando = ultima + 0.55

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
	var nombres := {"facil": "Fácil", "dificil": "Difícil", "reto": "Reto"}
	lbl_titulo.text = "%s %d: %s" % [nombres[Niveles.pack], Niveles.actual + 1, datos["nombre"]]
	# CONTADOR DE NIVEL ACTUAL / TOTAL
	lbl_progreso.text = "Nivel %d / %d" % [Niveles.actual + 1, Niveles.cantidad()]
	lbl_mensaje.text = ""
	lbl_ayuda.text = ""
	lbl_aviso.text = ""
	if datos.get("sin_caida", false):
		lbl_mensaje.text = "Lleva el bloque PARADO hasta la casilla naranja"
	# MODO RETO: TIEMPO LÍMITE DEL NIVEL
	reloj.limite = float(datos.get("tiempo", 0))
	if reloj.limite > 0.0:
		lbl_mensaje.text = "¡Contra el reloj!  Tienes %d:%02d" % [int(reloj.limite) / 60, int(reloj.limite) % 60]

# ---------- CADA FRAME ----------

func _process(delta: float) -> void:
	if entrando > 0.0:
		entrando -= delta
	elif estado == "jugando" or estado == "caido":
		tiempo += delta
	quieto += delta
	if datos.get("sin_caida", false) and volteos == 0 and quieto > 4.0:
		lbl_ayuda.text = "Usa las flechas  ←  ↑  ↓  →  (o W A S D)"
	lbl_info.text = "Volteos: %d   (par: %d)" % [volteos, datos["par"]]
	reloj.mostrar(tiempo)
	if reloj.se_acabo(tiempo) and (estado == "jugando" or estado == "caido"):
		estado = "tiempo"
		lbl_aviso.text = "¡Se acabó el tiempo!\nPulsa R para reintentar"

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
	sonidos.tocar("volteo", randf_range(0.9, 1.15))
	await bloque.voltear(dir, sig)

	# SE ROMPEN AL SALIR SI YA NO AGUANTAN MÁS
	var se_rompio := false
	for c in viejas:
		var k: Casilla = casillas[c]
		var antes := k.roto
		k.al_salir()
		if k.roto and not antes:
			se_rompio = true
			Efectos.pedazos(self, k.global_position)
	if se_rompio:
		sonidos.tocar("rotura", randf_range(0.9, 1.05))
		camara.sacudir(0.07)

	if cae:
		estado = "caido"
		bloque.hundir(3.0, 1.0)
		# AVISO EN EL CENTRO DE LA PANTALLA
		lbl_aviso.text = "¡Te caíste!\nZ para deshacer  ·  R para reiniciar"
		# SALPICADURA CUANDO EL BLOQUE TOCA EL AGUA
		var donde := Vector3(bloque.global_position.x, -0.75, bloque.global_position.z)
		await get_tree().create_timer(0.3).timeout
		if estado == "caido":
			Efectos.salpicadura(self, donde)
			sonidos.tocar("salpicadura", randf_range(0.95, 1.05))
		return

	# GRIETA SI EL HIELO SE AGRIETA, SI NO UN GOLPE SECO
	var se_agrieto := false
	for c in nuevas:
		var k: Casilla = casillas[c]
		k.aterrizar()
		if (k.tipo == "H" or k.tipo == "G") and k.restantes() <= 1:
			se_agrieto = true
	# GOLPE: EL BLOQUE SE APLASTA Y LA CÁMARA TIEMBLA POQUITO
	bloque.aplastar()
	camara.sacudir(0.03)
	if se_agrieto:
		sonidos.tocar("grieta", randf_range(0.92, 1.08))
	else:
		sonidos.tocar("golpe", randf_range(0.9, 1.1))

	if sig[2] == "S" and Vector2i(sig[0], sig[1]) == meta:
		_ganar()
	else:
		_avisar_grietas()

# LAS GRIETAS A UN VOLTEO DE DISTANCIA TIEMBLAN
func _avisar_grietas() -> void:
	var avisadas := {}
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var s := Bloque.siguiente(bloque.bx, bloque.bz, bloque.o, d)
		for c in Bloque.celdas_de(s[0], s[1], s[2]):
			if not casillas.has(c) or avisadas.has(c):
				continue
			var k: Casilla = casillas[c]
			if not k.roto and (k.tipo == "H" or k.tipo == "G") and k.restantes() == 1:
				avisadas[c] = true
				k.temblar()

func _ganar() -> void:
	estado = "gano"
	bloque.hundir(2.0, 0.8)
	var par: int = datos["par"]
	var estrellas := 1
	if volteos <= par:
		estrellas = 3
	elif volteos <= par * 1.5:
		estrellas = 2
	lbl_aviso.text = "¡Lo lograste!  %s\nPulsa Espacio para seguir" % "★".repeat(estrellas)

func _guardar() -> void:
	var foto := {}
	for pos in casillas:
		foto[pos] = casillas[pos].estado()
	historial.push_back({"bloque": [bloque.bx, bloque.bz, bloque.o], "casillas": foto})

func deshacer() -> void:
	if historial.is_empty() or estado == "gano" or estado == "tiempo":
		return
	var foto: Dictionary = historial.pop_back()
	for pos in foto["casillas"]:
		casillas[pos].restaurar(foto["casillas"][pos])
	var b: Array = foto["bloque"]
	bloque.colocar(b[0], b[1], b[2])
	estado = "jugando"
	lbl_aviso.text = ""

func siguiente_nivel() -> void:
	Niveles.actual += 1
	if Niveles.actual >= Niveles.cantidad():
		Niveles.actual = 0
		get_tree().change_scene_to_file("res://escenas/menu.tscn")
	else:
		cargar_nivel()
