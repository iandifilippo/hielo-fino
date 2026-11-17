class_name Estilo
extends RefCounted

# ESTILO DE LOS BOTONES: HIELO CON BORDES REDONDOS

static func caja(fondo: Color, borde: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fondo
	s.border_color = borde
	s.set_border_width_all(2)
	s.set_corner_radius_all(14)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s

static func boton(b: Button) -> void:
	b.add_theme_stylebox_override("normal", caja(Color(0.12, 0.22, 0.4), Color(0.45, 0.7, 1.0)))
	b.add_theme_stylebox_override("hover", caja(Color(0.18, 0.32, 0.55), Color(0.75, 0.9, 1.0)))
	b.add_theme_stylebox_override("pressed", caja(Color(0.08, 0.16, 0.3), Color(0.45, 0.7, 1.0)))
	b.add_theme_stylebox_override("disabled", caja(Color(0.1, 0.13, 0.2), Color(0.25, 0.3, 0.4)))
	var foco := caja(Color(0, 0, 0, 0), Color(0.9, 0.97, 1.0))
	foco.draw_center = false
	foco.set_border_width_all(3)
	b.add_theme_stylebox_override("focus", foco)
	b.add_theme_font_size_override("font_size", 26)
	b.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0))
	b.add_theme_color_override("font_hover_color", Color(1, 1, 1))
