extends Control
@onready var current = $Main/Audio
func _ready():
	$Buttons/Cassette.pressed.connect(_on_button_pressed.bind($Main/Cassette))
	$Buttons/Video.pressed.connect(_on_button_pressed.bind($Main/Video))
	$Buttons/Audio.pressed.connect(_on_button_pressed.bind($Main/Audio))
	
	$Buttons/Return.pressed.connect(_on_return_pressed)
func _on_button_pressed(category):
	current.hide()
	category.show()
	current = category
func _on_return_pressed():
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	await Transition.fade_in()
