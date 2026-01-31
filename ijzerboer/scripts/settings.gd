extends PanelContainer

@onready var fps_slider: HSlider = $MarginContainer/VBoxContainer/content/settings/content/FPS/FPSSlider
@onready var fps_label: Label = $MarginContainer/VBoxContainer/content/settings/content/FPS/FPSLabel
@onready var v_sync_label: Label = $MarginContainer/VBoxContainer/content/settings/content/VSync/VSyncLabel
@onready var fullscreen_label: Label = $MarginContainer/VBoxContainer/content/settings/content/Fullscreen/FullscreenLabel

@onready var sfx_label: Label = $MarginContainer/VBoxContainer/content/settings/content/SFX/SFXLabel
@onready var music_label: Label = $MarginContainer/VBoxContainer/content/settings/content/Music/MusicLabel
@onready var car_label: Label = $MarginContainer/VBoxContainer/content/settings/content/Car/CarLabel


var car_audio = AudioServer.get_bus_index("Car")
var sfx_audio = AudioServer.get_bus_index("SFX")
var bgm_audio = AudioServer.get_bus_index("BGM")

func _on_fps_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Engine.max_fps = int(fps_slider.value)

func _on_fps_slider_value_changed(value: float) -> void:
	if value == 300:
		fps_label.text = "Unlimited"
	elif value == 0:
		fps_label.text = "Auto"
	else:
		fps_label.text = str(int(value))

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		v_sync_label.text = "Enabled"
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		v_sync_label.text = "Disabled"

func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_label.text = "Enabled"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_label.text = "Disabled"

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
