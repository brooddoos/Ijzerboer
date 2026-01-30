extends Node3D

@onready var buttons = [
$UI/Menu/Content/buttons/VBoxContainer/CustomLicensePlate/LicensePlateButton, 
$UI/Menu/Content/buttons/UpgradeLoad/CargoButton, 
$UI/Menu/Content/buttons/UpgradeEngine/EngineButton]
@onready var values = $UI/Values
@onready var exitbutton = $UI/Menu/Content/ExitButton
@onready var music: AudioStreamPlayer = $Music
@onready var license: Label = $UI/Menu/Content/buttons/VBoxContainer/TextureRect/license

var car = load(Gamestate.car_stats["model"])

func _ready() -> void:
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	exitbutton.pressed.connect(_on_exit_pressed)
	update_buttons()
	#$Vehicle.remove_child($Vehicle/PropCar)
	#$Vehicle.add_child(car.instantiate())
	$Vehicle/AnimationPlayer.play("rotate")
	license.text = Gamestate.car_stats["licenseplate"]
	
func text_input(prompt = ""):
	exitbutton.disabled = true
	var line = LineEdit.new()
	line.placeholder_text = prompt
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.position = Vector2(375, 300)
	line.custom_minimum_size = Vector2(400, 0)
	line.max_length = 9
	
	get_tree().root.add_child(line)
	line.grab_focus()
	
	var text = await line.text_submitted
	line.queue_free()
	exitbutton.disabled = false
	return text

func _on_button_pressed(button):
	match button.name:
		"LicensePlateButton":
			Gamestate.BEF -= button.get_meta("price")
			values.update_currency()
			var plaat = await text_input("Enter your new license plate. (9 characters max.)") #gui komt later, dit werkt voorlopig
			Gamestate.car_stats["licenseplate"] = plaat
			license.text = plaat
		"CargoButton":
			Gamestate.BEF -= button.get_meta("price")
			Gamestate.car_stats["max_cargo"] += 50
			values.update_cargo()
		"EngineButton":
			Gamestate.BEF -= button.get_meta("price")
			Gamestate.car_stats["engine_multiplier"] += 20
	update_buttons()
	values.update_currency()
	$UpgradeSound.play()
	
func _on_exit_pressed():
	await Transition.fade_out()
	get_tree().change_scene_to_packed(load("res://scenes/Campaign.tscn"))
	await Transition.fade_in()
	
func update_buttons():
	for button in buttons:
		var price = button.get_meta("price")
		button.text = str(price)  + " BEF"
		if price <= Gamestate.BEF:
			button.disabled = false
		else:
			button.disabled = true

func _on_music_finished() -> void:
	music.stop()
	music.stream = (load("res://assets/audio/music/original_music/garage/mainloop.wav"))
	music.play()
