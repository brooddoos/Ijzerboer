extends Control
@onready var buttons = [
	$PanelContainer/VBoxContainer2/CustomLicensePlate/LicensePlateButton, 
	$PanelContainer/VBoxContainer2/UpgradeLoad/CargoButton, 
	$PanelContainer/VBoxContainer2/UpgradeEngine/EngineButton]
@onready var area_3d: Area3D = $"../../Garage/Area3D"

func _ready() -> void:
	area_3d.entered.connect(_on_body_entered)
	area_3d.exited.connect(_on_body_exited)
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	update_buttons()

func _on_body_entered():
	self.show()

func _on_body_exited():
	self.hide()

func _on_button_pressed(button):
	match button.name:
		"LicensePlateButton":
			Gamestate.BEF -= button.get_meta("price")
			update_buttons()
			$"../Values".update_currency()
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
