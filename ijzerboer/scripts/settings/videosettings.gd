extends Node
@onready var fps_slider := $VBoxContainer/FPS/FPSSlider
@onready var fps_label: Label = $VBoxContainer/FPS/FPSLabel
@onready var v_sync_label: Label = $VBoxContainer/VSync/VSyncLabel
@onready var fullscreen_label: Label = $VBoxContainer/Fullscreen/FullscreenLabel

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
