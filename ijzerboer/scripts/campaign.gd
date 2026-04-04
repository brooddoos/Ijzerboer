extends Node3D
@onready var garage = $Garage/Area3D.entered.connect(_on_garage_entered)

func _ready() -> void:
	var car = load("res://scenes/game/Car.tscn")
	var car_instance = car.instantiate()
	self.add_child(car_instance)
	car_instance.position = Gamestate.campaign["position"]
	Savesystem.ingame = true
	$Fisheye.show()

func _on_garage_entered():
	Gamestate.campaign["position"] = $Garage/RespawnPoint.global_position
	await Transition.fade_out("res://assets/images/ui/transition/transition_garage.png")
	get_tree().change_scene_to_packed(load("res://scenes/game/Garage.tscn"))
	await Transition.fade_in("res://assets/images/ui/transition/transition_garage.png")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cashdebug"):
		Gamestate.cargo = Gamestate.car_upgrades["cargo"] * 5
		$UI/Control/Values.update_cargo()
