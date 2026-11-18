extends Control

# MENÚ PRINCIPAL Y MENÚ DE DIFICULTAD

var caja_principal: VBoxContainer
var caja_dificultad: VBoxContainer
var btn_jugar: Button
var btn_facil: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# FONDO EN DEGRADADO: NOCHE ARRIBA, AZUL HIELO ABAJO
	var degradado := Gradient.new()
	degradado.set_color(0, Color(0.02, 0.04, 0.1))
	degradado.set_color(1, Color(0.1, 0.2, 0.38))
	var textura := GradientTexture2D.new()
	textura.gradient = degradado
	textura.fill_from = Vector2(0, 0)
	textura.fill_to = Vector2(0, 1)
	var fondo := TextureRect.new()
	fondo.texture = textura
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	_crear_nieve()

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 20)
	centro.add_child(caja)

	var titulo := Label.new()
	titulo.text = "HIELO FINO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 72)
	titulo.add_theme_color_override("font_color", Color(0.8, 0.93, 1.0))
	titulo.add_theme_constant_override("outline_size", 14)
	titulo.add_theme_color_override("font_outline_color", Color(0.1, 0.25, 0.5))
	caja.add_child(titulo)

	var lema := Label.new()
	lema.text = "Un puzzle de hielo que se rompe"
	lema.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lema.add_theme_font_size_override("font_size", 20)
	lema.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9))
	caja.add_child(lema)

	# MENÚ 1: JUGAR / SALIR
	caja_principal = VBoxContainer.new()
	caja_principal.add_theme_constant_override("separation", 20)
	caja.add_child(caja_principal)
	btn_jugar = _boton("Jugar", _on_jugar)
	caja_principal.add_child(btn_jugar)
	caja_principal.add_child(_boton("Salir", _on_salir))

	# MENÚ 2: DIFICULTAD
	caja_dificultad = VBoxContainer.new()
	caja_dificultad.add_theme_constant_override("separation", 20)
	caja_dificultad.visible = false
	caja.add_child(caja_dificultad)

	var subtitulo := Label.new()
	subtitulo.text = "Elige la dificultad"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 28)
	caja_dificultad.add_child(subtitulo)

	btn_facil = _boton("Fácil", _elegir.bind("facil"))
	caja_dificultad.add_child(btn_facil)
	caja_dificultad.add_child(_boton("Difícil", _elegir.bind("dificil")))
	var reto := _boton("Reto", _elegir.bind("reto"))
	reto.tooltip_text = "Contra el reloj: cada nivel con menos tiempo"
	caja_dificultad.add_child(reto)
	caja_dificultad.add_child(_boton("Volver", _on_volver))

	btn_jugar.grab_focus()

func _boton(texto: String, accion: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(260, 60)
	Estilo.boton(b)
	b.pressed.connect(accion)
	return b

func _unhandled_input(event: InputEvent) -> void:
	# ESC EN DIFICULTAD VUELVE AL MENÚ 1
	if event.is_action_pressed("ui_cancel") and caja_dificultad.visible:
		_on_volver()
		get_viewport().set_input_as_handled()

func _on_jugar() -> void:
	caja_principal.visible = false
	caja_dificultad.visible = true
	btn_facil.grab_focus()

func _on_volver() -> void:
	caja_dificultad.visible = false
	caja_principal.visible = true
	btn_jugar.grab_focus()

func _elegir(pack: String) -> void:
	Niveles.pack = pack
	Niveles.actual = 0
	get_tree().change_scene_to_file("res://escenas/juego.tscn")

func _on_salir() -> void:
	get_tree().quit()

# COPOS DE NIEVE CAYENDO DESPACIO DETRÁS DEL MENÚ
func _crear_nieve() -> void:
	var ancho := get_viewport_rect().size.x
	var copos := CPUParticles2D.new()
	copos.amount = 90
	copos.lifetime = 14.0
	copos.preprocess = 14.0
	copos.position = Vector2(ancho / 2.0, -20)
	copos.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	copos.emission_rect_extents = Vector2(ancho / 2.0 + 40, 4)
	copos.direction = Vector2(0, 1)
	copos.spread = 15.0
	copos.gravity = Vector2(0, 8)
	copos.initial_velocity_min = 25.0
	copos.initial_velocity_max = 50.0
	copos.scale_amount_min = 2.0
	copos.scale_amount_max = 5.0
	copos.color = Color(1, 1, 1, 0.7)
	add_child(copos)
