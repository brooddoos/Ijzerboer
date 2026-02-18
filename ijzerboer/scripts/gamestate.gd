extends Node

var last_scene := "res://scenes/Menu.tscn" #Which scene to return to from settings

var map := ""
var cargo := 0
var BEF := 1000 
var time := 21600.0
var car_stats := {
	"engine" = 1,
	"cargo" = 1,
	"licenseplate" = "123-ABC",
	"model" = "res://scenes/cami.tscn",
	"gps_metal_detector" = false,
}

var permanently_disabled_buttons = []

var current_tape := 0
var tapes:= [
	{ "title": "Jungle Mixtape\nVOLUME 1", "file":"res://assets/audio/music/jungle.ogg", "default": true},
	{ "title": "Asleep and Dreaming\nBy: Arcologies ", "file":"res://assets/audio/music/asleepanddreaming.mp3", "default": true},
	{ "title": "Mega Dance Mix", "file":"res://assets/audio/music/megadance.ogg", "default": true},
]
var flippos:= {

}

var campaign := {
	"position" = Vector3(100,0,0)
}

var rally := {
	"time" = {}
}
