extends Node3D

@onready var buttons = [
	$UI/Menu/Content/buttons/CustomLicense/CustomLicensePlate/LicensePlateButton, 
	$UI/Menu/Content/buttons/UpgradeLoad/CargoButton, 
	$UI/Menu/Content/buttons/UpgradeEngine/EngineButton,
	$UI/Menu/Content/buttons2/GPSMetal/GPSButton,
]

@onready var engine_label: Label = $UI/Menu/Content/buttons/UpgradeEngine/Label
@onready var cargo_label: Label = $UI/Menu/Content/buttons/UpgradeLoad/Label

@onready var exitbutton = $UI/Menu/Content/ExitButton
@onready var license: Label = $UI/Menu/Content/buttons/CustomLicense/TextureRect/license

@onready var music: AudioStreamPlayer = $Music
@onready var values = $UI/Values

# - CONFIG -
var max_engine_upgrade = 30
var engine_upgrade_multiplier = 20

var max_cargo_upgrade = 100
var cargo_upgrade_amount = 50

var car = load(Gamestate.car_stats["model"])
var permanently_disabled_buttons = Gamestate.permanently_disabled_buttons

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
	if not exitbutton.disabled:
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
	else:
		return ""

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
			
			var cargo_level := int(Gamestate.car_stats["max_cargo"] / cargo_upgrade_amount) + 1
			cargo_label.text = "Upgrade Load Capacity (Lvl %d/%d) " % [cargo_level, max_cargo_upgrade]
			
			Gamestate.car_stats["max_cargo"] += cargo_upgrade_amount
			if Gamestate.car_stats["max_cargo"] >= max_cargo_upgrade * cargo_upgrade_amount:
				permanently_disabled_buttons.append("CargoButton")
				
			values.update_cargo()
		"EngineButton":
			Gamestate.BEF -= button.get_meta("price")
			
			var engine_level := int(Gamestate.car_stats["engine_multiplier"] / engine_upgrade_multiplier) + 1
			engine_label.text = "Upgrade Engine (Lvl %d/%d)" % [engine_level, max_engine_upgrade]
			
			Gamestate.car_stats["engine_multiplier"] += engine_upgrade_multiplier
			if Gamestate.car_stats["engine_multiplier"] >= max_engine_upgrade * engine_upgrade_multiplier:
				permanently_disabled_buttons.append("EngineButton")
		"GPSButton":
			Gamestate.BEF -= button.get_meta("price")
			Gamestate.car_stats["gps_metal_detector"] = true
			permanently_disabled_buttons.append("GPSButton")
			
	update_buttons()
	values.update_currency()
	$UpgradeSound.play()
	
func _on_exit_pressed():
	Gamestate.permanently_disabled_buttons = permanently_disabled_buttons
	await Transition.fade_out()
	get_tree().change_scene_to_packed(load("res://scenes/game/Campaign.tscn"))
	await Transition.fade_in()
	
func update_buttons():
	for button in buttons:
		if button.name in permanently_disabled_buttons:
			button.disabled = true
			button.text = "MAX"
			continue
		
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
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cashdebug"):
		if OS.is_debug_build(): #vr debug purposes
			var tempcash = await text_input("Enter amount cash (int only)")
			if tempcash.is_valid_int():
				Gamestate.BEF = tempcash
				values.update_currency()
				update_buttons()
