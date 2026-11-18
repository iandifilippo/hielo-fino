class_name Niveles
extends RefCounted
 
# Paquete y nivel que se están jugando (los cambia el menú y el juego).
static var pack := "facil"
static var actual := 0
 
# Letras: . agua, N nieve (no se rompe), I inicio (nieve), H hielo (aguanta 2),
# G hielo agrietado (aguanta 1), M hoyo meta (hay que llegar parado).
const PACKS := {
	# FÁCIL: solo nieve, nada se agrieta. Puro movimiento.
	"facil": [
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
			"nombre": "Paso a paso",
			"par": 7,
			"filas": [
				"NNM..",
				"NNNNN",
				"..NNI",
				"..NNN",
			],
		},
		{
			"nombre": "Dando vueltas",
			"par": 9,
			"filas": [
				"NN....",
				"NNNNNN",
				".NNNMN",
				"...NIN",
				"...NNN",
			],
		},
		{
			"nombre": "El pasillo largo",
			"par": 12,
			"filas": [
				".N....",
				".N....",
				".N....",
				"NNNNIN",
				"NNN...",
				"NMN...",
			],
		},
		{
			"nombre": "La esquina",
			"par": 14,
			"filas": [
				"M.NNN",
				"NNNIN",
				"NNNNN",
				"NN...",
				".N...",
				".N...",
			],
		},
	],
	# DIFÍCIL: hielo y grietas desde el nivel 1.
	"dificil": [
		{
			"nombre": "El centro",
			"par": 22,
			"filas": [
				"....HHHHG...MHHH",
				"H...HG.HG......H",
				"NNGGG..GHHG...HH",
				"NIGHHG..HHGH..HH",
				"NNHH....GGHHH.GH",
				".H.......HHHGHHH",
				"..........GHHHHG",
				".........GGHHHHH",
			],
		},
		{
			"nombre": "Grietas por todos lados",
			"par": 22,
			"filas": [
				"......HHGGHGHHHH",
				"NN....GGGGH..HGG",
				"NIH....GGGH..GGG",
				"NHH..G.G.HH..HH.",
				"HGG.HGHGGH...GGH",
				".GGGGHGH.HG.HHH.",
				"..HHGH..GH..GGH.",
				".GHHH....G.GHHMH",
			],
		},
		{
			"nombre": "Un solo camino",
			"par": 24,
			"filas": [
				"..HMHGHHHHHHHHHH",
				"......HG..G...HH",
				".............HHH",
				"....H.....HGGHGH",
				".H..H....HHGGH.G",
				"NNHHH.....GHH...",
				"NIHHHHGG.HGHG...",
				"NNGHGHHGHGHHG...",
			],
		},
		{
			"nombre": "Grietas viejas",
			"par": 25,
			"filas": [
				"......HH.HHHGGH",
				".....GHHH.GHHHH",
				"....HGGG.GMHGGH",
				".....H.H.G.H..H",
				"...G.H.HHHHH..G",
				"GGHHGH.GGGHH...",
				"NNGHHH.GG.GG...",
				"NIHHHH.........",
				"NNG............",
			],
		},
		{
			"nombre": "Mil grietas",
			"par": 26,
			"filas": [
				".GH.GHGG.HG....",
				"HHNHGGGNGNNN...",
				"GG...GNGNGNN...",
				"H.HNG......NHHH",
				"HGGNNN..G.HN...",
				"HINNNNH.NGMNG..",
				"NGNNNHH.GGHG...",
			],
		},
	],
	# RETO: cuenta regresiva ("tiempo", en segundos). Cada nivel da menos tiempo que el anterior.
	"reto": [
		{
			"nombre": "Hielo viejo",
			"par": 14,
			"tiempo": 150,
			"filas": [
				"NN...HH......",
				"NIHHGGH.G.H..",
				"NNHHGHHHHHHHH",
				"HG.H.G.H..GHH",
				"........GMHHH",
				"........HHHHG",
				"........HGH..",
			],
		},
		{
			"nombre": "Dos caminos",
			"par": 14,
			"tiempo": 130,
			"filas": [
				".........GH.H",
				".H......HMHHG",
				".NNG......HHH",
				"HNIGHH.....HH",
				".NNHHH...HHHH",
				".H.HHGHHGHHHH",
				"...HH.H.H.HHH",
			],
		},
		{
			"nombre": "El rodeo",
			"par": 15,
			"tiempo": 110,
			"filas": [
				"....GGHGGHHHH",
				"..GHHHHH..GHH",
				"..HHHH...HHMG",
				"HHHH.......G.",
				"HHI..........",
				"HHHH.........",
			],
		},
		{
			"nombre": "Sin vuelta atrás",
			"par": 16,
			"tiempo": 90,
			"filas": [
				"......MHHHHHG",
				".......HH.HGH",
				"............H",
				".H..........H",
				".NN.G......GG",
				".NIHGGHHHGHHH",
				"HNN.GHHGHHHHH",
			],
		},
		{
			"nombre": "Última carrera",
			"par": 19,
			"tiempo": 70,
			"filas": [
				".GI......G.",
				"GMHHG.G.GNH",
				".GHGNNNHNHH",
				"..GNGNH.GNG",
				"...HNNHHGG.",
			],
		},
	],
}
 
static func nivel() -> Dictionary:
	return PACKS[pack][actual]
 
static func cantidad() -> int:
	return PACKS[pack].size()
