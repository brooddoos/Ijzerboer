extends Node
@onready var sfx_label: Label = $VBoxContainer/SFX/SFXLabel
@onready var music_label: Label = $VBoxContainer/Music/MusicLabel
@onready var car_label: Label = $VBoxContainer/Car/CarLabel

@onready var music_slider: HSlider = $VBoxContainer/Music/MusicSlider
@onready var car_slider: HSlider = $VBoxContainer/Car/CarSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFX/SFXSlider

var car_audio = AudioServer.get_bus_index("Car")
var sfx_audio = AudioServer.get_bus_index("SFX")
var bgm_audio = AudioServer.get_bus_index("BGM")

func update_label():
	car_slider.value = AudioServer.get_bus_volume_linear(1)*100
	car_label.text = str(int(car_slider.value)) + "%"
	music_slider.value = AudioServer.get_bus_volume_linear(2)*100
	music_label.text = str(int(music_slider.value)) + "%"
	sfx_slider.value = AudioServer.get_bus_volume_linear(3)*100
	sfx_label.text = str(int(sfx_slider.value)) + "%"

func _ready() -> void:
	await Engine.get_main_loop().process_frame
	update_label()

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_label.text = str(int(value)) + "%"
	AudioServer.set_bus_volume_db(sfx_audio , linear_to_db(value/100))

func _on_music_slider_value_changed(value: float) -> void:
	music_label.text = str(int(value)) + "%"
	AudioServer.set_bus_volume_db(bgm_audio , linear_to_db(value/100))

func _on_car_slider_value_changed(value: float) -> void:
	car_label.text = str(int(value)) + "%"
	AudioServer.set_bus_volume_db(car_audio , linear_to_db(value/100))

func _on_button_pressed() -> void:
	AudioServer.set_bus_volume_db(car_audio , -2.5)
	AudioServer.set_bus_volume_db(sfx_audio , -3.8)
	AudioServer.set_bus_volume_db(bgm_audio , -13.0)
	update_label()
