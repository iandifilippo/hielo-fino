class_name Niveles
extends RefCounted

# PAQUETE Y NIVEL QUE SE ESTÁN JUGANDO
static var pack := "facil"
static var actual := 0

# LETRAS: . AGUA, N NIEVE, I INICIO, H HIELO (AGUANTA 2), G GRIETA (AGUANTA 1), M META
const FACIL := preload("res://scripts/niveles/facil.gd")
const RETO := preload("res://scripts/niveles/reto.gd")

static func lista() -> Array:
	match pack:
		"facil":
			return FACIL.LISTA
		"reto":
			return RETO.LISTA
	return []

static func nivel() -> Dictionary:
	return lista()[actual]

static func cantidad() -> int:
	return lista().size()
