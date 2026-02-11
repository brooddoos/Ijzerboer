extends Node3D
@onready var dooranim = $Interior/AnimationPlayer
@onready var play = $CanvasLayer/Play
@onready var options = $CanvasLayer/Options
func _ready():
	$Fireplace.play("default")
	play.pressed.connect(_on_play_pressed)
	options.pressed.connect(_on_options_pressed)
func _on_play_pressed():
	dooranim.play("doorAction")
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/game/Campaign.tscn")
	await Transition.fade_in()
func _on_options_pressed():
	dooranim.play("doorAction_001")
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/start/Options.tscn")
	await Transition.fade_in()
