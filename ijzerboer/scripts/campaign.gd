extends Node3D
func _ready() -> void:
	var car = load("res://scenes/game/Car.tscn")
	var car_instance = car.instantiate()
	self.add_child(car_instance)
	print(Gamestate.campaign["position"])
	car_instance.position = Gamestate.campaign["position"]
@onready var garage = $Garage/Area3D.entered.connect(_on_garage_entered)
func _on_garage_entered():
	Gamestate.campaign["position"] = $Car/Ball.global_position - Vector3(0,0,10)
	await Transition.fade_out("res://assets/images/transition2.png")
	get_tree().change_scene_to_packed(load("res://scenes/game/Garage.tscn"))
	await Transition.fade_in("res://assets/images/transition2.png")
