extends Control

# Menú principal: Jugar y Salir.

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

	var jugar := Button.new()
	jugar.text = "Jugar"
	jugar.custom_minimum_size = Vector2(260, 60)
	jugar.pressed.connect(_on_jugar)
	caja.add_child(jugar)

	var salir := Button.new()
	salir.text = "Salir"
	salir.custom_minimum_size = Vector2(260, 60)
	salir.pressed.connect(_on_salir)
	caja.add_child(salir)

	jugar.grab_focus()

func _on_jugar() -> void:
	Niveles.actual = 0
	get_tree().change_scene_to_file("res://escenas/juego.tscn")

func _on_salir() -> void:
	get_tree().quit()
