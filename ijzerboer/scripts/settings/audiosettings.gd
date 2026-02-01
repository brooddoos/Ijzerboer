extends Node
@onready var sfx_label: Label = $VBoxContainer/SFX/SFXLabel
@onready var music_label: Label = $VBoxContainer/Music/MusicLabel
@onready var car_label: Label = $VBoxContainer/Car/CarLabel


var car_audio = AudioServer.get_bus_index("Car")
var sfx_audio = AudioServer.get_bus_index("SFX")
var bgm_audio = AudioServer.get_bus_index("BGM")

func percentVolumeTodB(percent: float) -> float: #Grabbed it straight from my other game cuz im not rewriting
	if percent <= 0.0:
		return -80.0
	return 50.0 * log(percent / 100.0) / log(10)

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_label.text = str(int(value)) + "%"
	AudioServer.set_bus_volume_db(sfx_audio , percentVolumeTodB(value))

func _on_music_slider_value_changed(value: float) -> void:
	music_label.text = str(int(value)) + "%"
	AudioServer.set_bus_volume_db(bgm_audio , percentVolumeTodB(value))

func _on_car_slider_value_changed(value: float) -> void:
	car_label.text = str(int(value)) + "%"
	AudioServer.set_bus_volume_db(car_audio , percentVolumeTodB(value))
