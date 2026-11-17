class_name Sonidos
extends Node

# EFECTOS DE SONIDO DEL JUEGO. LOS .wav LOS GENERA herramientas/generar_sonidos.py

const ARCHIVOS := {
	"golpe": "res://sonidos/golpe.wav",
	"grieta": "res://sonidos/grieta.wav",
	"rotura": "res://sonidos/rotura.wav",
	"salpicadura": "res://sonidos/salpicadura.wav",
	"volteo": "res://sonidos/volteo.wav",
	"estrella": "res://sonidos/estrella.wav",
}
const VOLUMEN := {"golpe": -10.0, "grieta": -4.0, "rotura": -3.0, "salpicadura": -2.0, "volteo": -14.0, "estrella": -6.0}

var _jugadores := {}

func _ready() -> void:
	for nombre in ARCHIVOS:
		var p := AudioStreamPlayer.new()
		p.stream = load(ARCHIVOS[nombre])
		p.volume_db = VOLUMEN.get(nombre, 0.0)
		add_child(p)
		_jugadores[nombre] = p

func tocar(nombre: String, tono := 1.0) -> void:
	var p: AudioStreamPlayer = _jugadores.get(nombre)
	if p == null:
		return
	p.pitch_scale = tono
	p.play()
