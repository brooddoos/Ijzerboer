extends Node3D
@onready var dooranim = $Interior/AnimationPlayer
@onready var play = $CanvasLayer/Control/Play
@onready var options = $CanvasLayer/Control/Options

var oldflicker := 1.0
var newflicker := 1.0

func _ready():
	$Fireplace.play("default")
	$Fireplace/AudioStreamPlayer.play()
	play.pressed.connect(_on_play_pressed)
	options.pressed.connect(_on_options_pressed)

func _physics_process(_delta: float) -> void:
	newflicker = randf_range(0.6,1.4)
	$Fireplace/OmniLight3D.light_energy = lerp(oldflicker, newflicker , 0.5)
	oldflicker = newflicker
	
func _on_play_pressed():
	dooranim.play("doorAction")
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/start/saveselection.tscn")
	await Transition.fade_in()
	
func _on_options_pressed():
	dooranim.play("doorAction_001")
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/start/Options.tscn")
	await Transition.fade_in()
