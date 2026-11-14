class_name Reloj
extends Label

# RELOJ DEL HUD. CON LÍMITE CUENTA HACIA ATRÁS (MODO RETO)

var limite := 0.0

func mostrar(tiempo: float) -> void:
	var seg := int(tiempo)
	if limite > 0.0:
		seg = ceili(maxf(limite - tiempo, 0.0))
	text = "%d:%02d" % [seg / 60, seg % 60]

func se_acabo(tiempo: float) -> bool:
	return limite > 0.0 and tiempo >= limite
