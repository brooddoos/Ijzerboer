extends Node3D

@onready var buttons = [
	$UI/Menu/Content/buttons/CustomLicense/CustomLicensePlate/LicensePlateButton,
	$UI/Menu/Content/buttons/UpgradeLoad/CargoButton, 
	$UI/Menu/Content/buttons/UpgradeEngine/EngineButton,
	$UI/Menu/Content/buttons2/GPSMetal/GPSButton,
]

@onready var exitbutton = $UI/Menu/Content/ExitButton
@onready var license: Label = $UI/Menu/Content/buttons/CustomLicense/TextureRect/license

@onready var values = $UI/Values

# -

var mouse_right_down := false
var car = load(Gamestate.car_upgrades["model"])
var old_rotation := 0.0
var in_drag := false
var mx_base

func _ready() -> void:
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	exitbutton.pressed.connect(_on_exit_pressed)
	update_buttons()

	license.text = Gamestate.car_upgrades["licenseplate"]
	
func _process(delta: float) -> void:
	if mouse_right_down:
		var mouse = get_viewport().get_mouse_position()
		var viewport_size = get_viewport().get_visible_rect().size
		var mx = (mouse.x / viewport_size.x - 0.5) * 2.0
		
		if !in_drag:
			in_drag = true
			old_rotation = $Vehicle.rotation.y
			mx_base = mx
		$Vehicle.rotation.y = lerp($Vehicle.rotation.y ,old_rotation + (mx-mx_base) * 2.5, 0.1)
	else:
		if in_drag:
			in_drag = false
		$Vehicle.rotation.y = lerp($Vehicle.rotation.y ,$Vehicle.rotation.y + deg_to_rad(35)*delta*10, 0.1)
	
func text_input(prompt = ""):
	if not exitbutton.disabled:
		exitbutton.disabled = true
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
		exitbutton.disabled = false
		return text
	else:
		return ""

func check_if_fits():
	var max_width = license.size.x
	var font = license.label_settings.font
	
	var start_size = 48
	var min_size = 14
	
	for size in range(start_size, min_size, -1): #will keep making smaller until fits
		license.label_settings.font_size = size
		var text_size = font.get_string_size(license.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size)
		if text_size.x <= max_width:	
			break

func _on_button_pressed(button):
	match button.name:
		"LicensePlateButton":
			Gamestate.BEF -= button.get_meta("Price")
			var plaat = await text_input("Enter your new license plate. (9 characters max.)") #gui komt later, dit werkt voorlopig
			Gamestate.car_upgrades["licenseplate"] = plaat
			license.text = plaat
			values.update_currency()
			check_if_fits()
		"CargoButton":
			Gamestate.BEF -= button.get_meta("Price")
			Gamestate.car_upgrades["cargo"] += 1
			values.update_cargo()
		"EngineButton":
			Gamestate.BEF -= button.get_meta("Price")
			Gamestate.car_upgrades["engine"] += 1
		"GPSButton":
			Gamestate.BEF -= button.get_meta("Price")
			Gamestate.car_upgrades["gps_metal_detector"] = true
			
	update_buttons()
	values.update_currency()
	$UpgradeSound.pitch_scale = randf_range(0.9,1.1)
	$UpgradeSound.play()
	
	
func _on_exit_pressed():
	await Savesystem.save()
	await Transition.fade_out("res://assets/images/ui/transition/transition_garage.png")
	get_tree().change_scene_to_packed(load("res://scenes/game/Campaign.tscn"))
	await Transition.fade_in("res://assets/images/ui/transition/transition_garage.png")
	
func update_buttons():
	for button in buttons:
		var price = button.get_meta("Price")
		@warning_ignore("shadowed_global_identifier")
		var max 
		var current
		var cash = Gamestate.BEF
		var level = button.get_parent().get_node_or_null("Level")
		button.text = str(price)  + " BEF"
		if button.has_meta("Max") and button.has_meta("Gamestate"):
			max = button.get_meta("Max")
			current = Gamestate.car_upgrades[button.get_meta("Gamestate")]
		if max and current:
			if max != current and price <= cash:
				button.disabled = false
			else:
				button.disabled = true
			if max == current:
				button.text = "MAX"
		elif price <= cash:
			button.disabled = false
		else:
			button.disabled = true
			
		if level:
			level.text = "("+str(current)+"/"+str(max)+")"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cashdebug"):
		if OS.is_debug_build(): #vr debug purposes
			var tempcash = await text_input("Enter amount cash (int only)")
			if tempcash.is_valid_int():
				Gamestate.BEF = tempcash
				values.update_currency()
				update_buttons()
	if event.is_action_pressed("escape"):
		if !exitbutton.disabled:
			_on_exit_pressed()
			
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.is_pressed():
			mouse_right_down = true
		elif event.button_index == 2 and not event.is_pressed():
			mouse_right_down = false
