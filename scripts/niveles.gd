class_name Niveles
extends RefCounted

# Nivel que se está jugando (lo cambia el menú y el juego)!!!! PRIMERA PARTE
static var actual := 0

# Letras: . agua, N nieve (no se rompe), I inicio (nieve), H hielo (aguanta 2),
# G hielo agrietado (aguanta 1), M hoyo meta (hay que llegar parado)
# TENER EN CUENTA INDICACIÓN
const LISTA := [
	{
		"nombre": "Primeros pasos",
		"par": 5,
		"sin_caida": true,
		"filas": [
			"NNNNNNNNN",
			"NINNNNNNN",
			"NNNNNNNMN",
			"NNNNNNNNN",
		],
	},
	{
		"nombre": "Cuidado con el agua",
		"par": 7,
		"filas": [
			"NNN.......",
			"NINNNN....",
			"NNNNNNNNN.",
			".NNNNNNNNN",
			".....NNMNN",
			"......NNN.",
		],
	},
	{
		"nombre": "Hielo delgado",
		"par": 10,
		"filas": [
			"NNN..........",
			"NIHHHH.......",
			"NNHHHHHH.....",
			"..HHHHHHHHH..",
			".....HHHHHHHH",
			"........HHMHH",
			".........HHH.",
		],
	},
	{
		"nombre": "No pises dos veces",
		"par": 7,
		"filas": [
			"..HHH........",
			"NIHHHHH..HHH.",
			"NNH..HHHHHMHH",
			"..H....HHHHH.",
			"..HHHHHH.....",
		],
	},
	{
		"nombre": "Grietas",
		"par": 7,
		"filas": [
			"NNN.......",
			"NIHGGHH...",
			"NNHGGHHH..",
			"...HHGGHHH",
			"....HGGHMH",
			".....HHHH.",
		],
	},
	{
		"nombre": "Grietas viejas",
		"par": 13,
		"filas": [
			"..........HGH......",
			"NNN....HHHGGG...HHH",
			"NIHHHHGGHGHGGHHHHMH",
			"NNH....HHH..H...HHH",
			".......HHH..H......",
		],
	},
]
