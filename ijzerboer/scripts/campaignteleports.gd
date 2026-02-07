extends Node3D

@onready var garage = $Garage/Area3D.entered.connect(_on_garage_entered)

func _ready() -> void:
	if Gamestate.last_scene == "res://scenes/Garage.tscn":
		Gamestate.time += 200

func _on_garage_entered():
	await Transition.fade_out("res://assets/images/ui/transition/transition_garage.png")
	get_tree().change_scene_to_packed(load("res://scenes/Garage.tscn"))
	await Transition.fade_in("res://assets/images/ui/transition/transition_garage.png")
