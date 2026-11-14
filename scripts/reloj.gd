class_name Reloj
extends Label

# RELOJ DEL HUD. CON LÍMITE CUENTA HACIA ATRÁS (MODO RETO)

var limite := 0.0

func mostrar(tiempo: float) -> void:
	var seg := int(tiempo)
	if limite > 0.0:
		seg = ceili(maxf(limite - tiempo, 0.0))
	text = "%d:%02d" % [seg / 60, seg % 60]
	# ROJO EN LOS ÚLTIMOS 10 SEGUNDOS
	if limite > 0.0 and limite - tiempo <= 10.0:
		add_theme_color_override("font_color", Color(1, 0.35, 0.3))
	else:
		remove_theme_color_override("font_color")

func se_acabo(tiempo: float) -> bool:
	return limite > 0.0 and tiempo >= limite
