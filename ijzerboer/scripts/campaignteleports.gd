extends Node3D
@onready var garage = $Garage/Area3D.entered.connect(_on_garage_entered)
func _on_garage_entered():
	await Transition.fade_out()
	get_tree().change_scene_to_packed(load("res://scenes/Garage.tscn"))
	await Transition.fade_in()
