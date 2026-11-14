extends Control

# MENÚ PRINCIPAL Y MENÚ DE DIFICULTAD

var caja_principal: VBoxContainer
var caja_dificultad: VBoxContainer
var btn_jugar: Button
var btn_facil: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fondo := ColorRect.new()
	fondo.color = Color(0.05, 0.08, 0.16)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 20)
	centro.add_child(caja)

	var titulo := Label.new()
	titulo.text = "HIELO FINO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 64)
	caja.add_child(titulo)

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
	# DIFÍCIL Y RETO TODAVÍA NO TIENEN NIVELES
	var dificil := _boton("Difícil (pronto)", _elegir.bind("dificil"))
	dificil.disabled = true
	caja_dificultad.add_child(dificil)
	var reto := _boton("Reto (pronto)", _elegir.bind("reto"))
	reto.disabled = true
	caja_dificultad.add_child(reto)
	caja_dificultad.add_child(_boton("Volver", _on_volver))

	btn_jugar.grab_focus()

func _boton(texto: String, accion: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(260, 60)
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
