extends Node3D
func _ready():
	$Fireplace.play("default")
	$CanvasLayer/Buttons/MarginContainer/HBoxContainer/Play.pressed.connect(_on_play_pressed)
func _on_play_pressed():
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/game/Campaign.tscn")
	await Transition.fade_in()
