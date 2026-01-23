extends Control
@onready var buttons = [
	$UI/PanelContainer/VBoxContainer2/CustomLicensePlate/LicensePlateButton, 
	$UI/PanelContainer/VBoxContainer2/UpgradeLoad/CargoButton, 
	$UI/PanelContainer/VBoxContainer2/UpgradeEngine/EngineButton]
@onready var area_3d: Area3D = $"../../Garage/Area3D"

func _ready() -> void:
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	update_buttons()

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
			update_buttons()
			$"../Values".update_currency()
			var plaat = await text_input("Enter your new license plate. (Maximum of 9 characters)") #gui komt later, dit werkt voorlopig
			Gamestate.car_stats["licenseplate"] = plaat
			print("test1")
		"CargoButton":
			Gamestate.BEF -= button.get_meta("price")
			Gamestate.car_stats["max_cargo"] += 50
			update_buttons()
			$"../Values".update_currency()
			$"../Values".update_cargo() 
			print("test2")
		"EngineButton":
			Gamestate.BEF -= button.get_meta("price")
			Gamestate.car_stats["acceleration"] += 20
			$"../Values".update_currency()
			print("test3")

func update_buttons():
	for button in buttons:
		var price = button.get_meta("price")
		button.text = str(price)  + "BEF"
		if price <= Gamestate.BEF:
			button.disabled = false
		else:
			button.disabled = true
