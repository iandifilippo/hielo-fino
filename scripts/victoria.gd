class_name Victoria
extends Control

# PANTALLA DE VICTORIA: LAS ESTRELLAS SALEN UNA POR UNA

signal estrella_mostrada(numero: int)

var _estrellas: Array[Label] = []
var _pista: Label

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	centro.add_child(caja)

	var titulo := _texto("¡Lo lograste!", 48)
	caja.add_child(titulo)

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 12)
	caja.add_child(fila)
	for i in 3:
		var e := _texto("★", 80)
		e.custom_minimum_size = Vector2(96, 96)
		e.pivot_offset = Vector2(48, 48)
		fila.add_child(e)
		_estrellas.append(e)

	_pista = _texto("Pulsa Espacio para seguir", 24)
	caja.add_child(_pista)

func _texto(t: String, tam: int) -> Label:
	var l := Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_constant_override("outline_size", 10)
	l.add_theme_color_override("font_outline_color", Color(0.03, 0.06, 0.14))
	return l

func ocultar() -> void:
	visible = false

func mostrar(cuantas: int) -> void:
	visible = true
	_pista.visible = false
	for e in _estrellas:
		e.modulate = Color(1, 1, 1, 0.15)
		e.scale = Vector2.ONE
	# CADA ESTRELLA GANADA SALTA CON UN PEQUEÑO REBOTE
	for i in cuantas:
		await get_tree().create_timer(0.35).timeout
		if not visible:
			return
		var e := _estrellas[i]
		e.modulate = Color(1, 0.85, 0.2)
		e.scale = Vector2(0.3, 0.3)
		var tw := create_tween()
		tw.tween_property(e, "scale", Vector2(1.25, 1.25), 0.15)
		tw.tween_property(e, "scale", Vector2.ONE, 0.12)
		estrella_mostrada.emit(i)
	await get_tree().create_timer(0.3).timeout
	_pista.visible = visible
