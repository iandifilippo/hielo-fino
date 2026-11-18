extends Control

# Menú principal: Jugar y Salir.
# Al pulsar Jugar se abre un segundo menú: Fácil, Difícil y Reto.

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

	# ---------- Menú 1: Jugar / Salir ----------
	caja_principal = VBoxContainer.new()
	caja_principal.add_theme_constant_override("separation", 20)
	caja.add_child(caja_principal)

	btn_jugar = _crear_boton("Jugar", _on_jugar)
	caja_principal.add_child(btn_jugar)
	caja_principal.add_child(_crear_boton("Salir", _on_salir))

	# ---------- Menú 2: elegir dificultad ----------
	caja_dificultad = VBoxContainer.new()
	caja_dificultad.add_theme_constant_override("separation", 20)
	caja_dificultad.visible = false
	caja.add_child(caja_dificultad)

	var subtitulo := Label.new()
	subtitulo.text = "Elige la dificultad"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 28)
	caja_dificultad.add_child(subtitulo)

	btn_facil = _crear_boton("Fácil", _elegir.bind("facil"))
	caja_dificultad.add_child(btn_facil)
	caja_dificultad.add_child(_crear_boton("Difícil", _elegir.bind("dificil")))
	var reto := _crear_boton("Reto", _elegir.bind("reto"))
	reto.tooltip_text = "Contra el reloj: 5 niveles y cada uno con menos tiempo"
	caja_dificultad.add_child(reto)
	caja_dificultad.add_child(_crear_boton("Volver", _on_volver))

	btn_jugar.grab_focus()

func _crear_boton(texto: String, accion: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(260, 60)
	b.pressed.connect(accion)
	return b

func _unhandled_input(event: InputEvent) -> void:
	# Esc en el menú de dificultad vuelve al menú principal
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
