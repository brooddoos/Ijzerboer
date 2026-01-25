extends Node3D
@onready var buttons = [
	$UI/PanelContainer/VBoxContainer2/CustomLicensePlate/LicensePlateButton, 
	$UI/PanelContainer/VBoxContainer2/UpgradeLoad/CargoButton, 
	$UI/PanelContainer/VBoxContainer2/UpgradeEngine/EngineButton]
@onready var values = $UI/Values
@onready var exitbutton = $UI/PanelContainer/VBoxContainer2/ExitButton
var car = load(Gamestate.car_stats["model"])
func _ready() -> void:
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	exitbutton.pressed.connect(_on_exit_pressed)
	update_buttons()
	$Vehicle.add_child(car.instantiate())
	$Vehicle/AnimationPlayer.play("rotate")

func text_input(prompt = ""):
	var line = LineEdit.new()
	line.placeholder_text = prompt
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.position = Vector2(20, 20)
	line.custom_minimum_size = Vector2(400, 0)
	line.max_length = 9
	
	get_tree().root.add_child(line)
	line.grab_focus()
	
	var text = await line.text_submitted
	line.queue_free()
	return text


func _on_button_pressed(button):
	match button.name:
		"LicensePlateButton":
			Gamestate.BEF -= button.get_meta("price")
			var plaat = await text_input("Enter your new license plate. (Maximum of 9 characters)") #gui komt later, dit werkt voorlopig
			Gamestate.car_stats["licenseplate"] = plaat
		"CargoButton":
			Gamestate.BEF -= button.get_meta("price")
			Gamestate.car_stats["max_cargo"] += 50
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
