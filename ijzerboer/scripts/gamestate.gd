extends Node
var map := ""
var cargo := 0
var BEF := 1000 
var car_stats := {
	"engine_multiplier" = 1,
	"max_cargo" = 10,
	"licenseplate" = "123_ABC",
	"model" = "res://scenes/cami.tscn"
}
var tapes:= {
	1: { "title": "Jungle Mixtape\nVOLUME 1", "file":"res://assets/audio/music/jungle.ogg"},
	2: { "title": "Asleep and Dreaming\nBy: Arcologies ", "file":"res://assets/audio/music/asleepanddreaming.mp3"},
	3: { "title": "Mega Dance Mix", "file":"res://assets/audio/music/megadance.ogg"},
}
var campaign := {
	"position" = Vector3(0,0,0)
}
var rally := {
	"time" = {}
}
