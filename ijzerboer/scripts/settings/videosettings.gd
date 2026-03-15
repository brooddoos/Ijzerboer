extends Node
@onready var fps_label: Label = $VBoxContainer/FPS/FPSLabel
@onready var v_sync_label: Label = $VBoxContainer/VSync/VSyncLabel
@onready var fullscreen_label: Label = $VBoxContainer/Fullscreen/FullscreenLabel

@onready var v_sync_toggle: CheckButton = $VBoxContainer/VSync/VSyncToggle
@onready var fullscreen_toggle: CheckButton = $VBoxContainer/Fullscreen/FullscreenToggle
@onready var fps_slider: HSlider = $VBoxContainer/FPS/FPSSlider

func _ready() -> void:
	v_sync_toggle.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fps_slider.value = Engine.max_fps
	
	_on_fps_slider_value_changed(fps_slider.value)
	_on_check_button_toggled(v_sync_toggle.button_pressed)
	_on_fullscreen_toggle_toggled(fullscreen_toggle.button_pressed)

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
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		fullscreen_label.text = "Enabled"
	else:
		if DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_label.text = "Disabled"

func text_input(prompt = ""):
	var line = LineEdit.new()
	line.placeholder_text = prompt
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.position = Vector2(380, 300)
	line.custom_minimum_size = Vector2(400, 0)
	line.max_length = 9
	
	get_tree().root.add_child(line)
	line.grab_focus()
	
	var text = await line.text_submitted
	line.queue_free()
	return text

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cashdebug"):
		if OS.is_debug_build():
			var w = int(await text_input("width"))
			var h = int(await text_input("height"))
			
			get_tree().root.content_scale_size = Vector2(w,h)

func _on_resolution_options_item_selected(index: int):
	if index == 0:
		get_viewport().scaling_3d_scale = 1.0
	else:
		get_viewport().scaling_3d_scale = 0.25
