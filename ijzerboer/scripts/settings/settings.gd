extends Control
@onready var current = $content/Main/Video
var busy = false

func _ready():
	$content/Buttons/Cassette.pressed.connect(_on_button_pressed.bind($content/Main/Cassette))
	$content/Buttons/Video.pressed.connect(_on_button_pressed.bind($content/Main/Video))
	$content/Buttons/Audio.pressed.connect(_on_button_pressed.bind($content/Main/Audio))
	$content/Buttons/Credits.pressed.connect(_on_button_pressed.bind($content/Main/Credits))
	$content/Buttons/Return.pressed.connect(_on_return_pressed)
	
	for child in $content/Main.get_children():
		child.hide()
	current.show()

func _on_button_pressed(category):
	current.hide()
	category.show()
	current = category

func _on_return_pressed():
	if not busy:
		busy = true
		var old = Gamestate.last_scene
		await Transition.fade_out()
		get_tree().change_scene_to_file(old)
		await Transition.fade_in()
