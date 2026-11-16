class_name CamaraJuego
extends Camera3D

# SACUDIDA CORTA DE LA CÁMARA

var _fuerza := 0.0

func sacudir(fuerza: float) -> void:
	_fuerza = maxf(_fuerza, fuerza)

func _process(delta: float) -> void:
	if _fuerza <= 0.001:
		h_offset = 0.0
		v_offset = 0.0
		return
	h_offset = randf_range(-_fuerza, _fuerza)
	v_offset = randf_range(-_fuerza, _fuerza)
	_fuerza = move_toward(_fuerza, 0.0, delta * 0.4)
