extends Control
@onready var current: Control = $content/Main/Buffer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var fact_label: Label = $bittom/facts

const facts = [
	"Fun fact: The building where you sell your iron is based off of a real Belgian hardware store!",
	"Fun fact: Ijzerboer means Ironfarmer when you translate it literally!",
	"Tip: This is a tip (im so helpful)",
	"Fun fact: Trains are in fact loud.",
	"Handy: Double-clicking buttons can sometimes skip transitions! (we dont know why this happens)",
	"Fun fact: The in-game car is based off of the Mercedes-Benz T1!",
]
var busy = false
var showfact = false

func _ready():
	$content/Buttons/Cassette.pressed.connect(_on_button_pressed.bind($content/Main/Cassette))
	$content/Buttons/Video.pressed.connect(_on_button_pressed.bind($content/Main/Video))
	$content/Buttons/Audio.pressed.connect(_on_button_pressed.bind($content/Main/Audio))
	$content/Buttons/Credits.pressed.connect(_on_button_pressed.bind($content/Main/Credits))
	$content/Buttons/Return.pressed.connect(_on_return_pressed)
	
	for child in $content/Main.get_children():
		child.hide()
	current.show()
	
	anim.play("fadein")
	
	fact_loop()

func fact_loop():
	fact_label.text = facts[randi_range(0,len(facts) - 1)]
	fact_label.position.x = 1000
	showfact = true
	while showfact:
		await get_tree().process_frame
	fact_loop()

func _process(delta: float) -> void:
	if fact_label.position.x >= -2000:
		fact_label.position.x -= delta*100
	else:
		showfact = false
	$bg/SubViewport/Camera3D.rotate_y(deg_to_rad(2*delta))

func _on_button_pressed(category):
	if not anim.is_playing():
		current.hide()
		category.show()
		current = category

func _on_return_pressed():
	if not busy and not anim.is_playing():
		busy = true
		var old = Gamestate.last_scene
		await Transition.fade_out()
		get_tree().change_scene_to_file(old)
		await Transition.fade_in()

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
