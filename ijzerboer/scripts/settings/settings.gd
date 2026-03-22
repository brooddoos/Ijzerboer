extends Control
@onready var current: Control = $content/Main/Buffer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var fact_label: Label = $bittom/facts

const facts = [
	"Fun fact: The building where you sell your scrap metal is based off of a real Belgian hardware store!",
	"Fun fact: Ijzerboer means Ironfarmer when you translate it literally!",
	"Tip: This is a tip (im so helpful)",
	"Fun fact: Trains are in fact loud.",
	"Handy: Double-clicking buttons can sometimes skip transitions! (we don't know why this happens)",
	"Fun fact: The in-game car is based off of the Mercedes-Benz T1!",
	"Fun fact: This game has already taken 100+ hours to make!",
	"Fun fact: this is a fun fact! (you can guess who won the most helpful award)",
]
var busy = false
var showfact = false
var current_fact = randi_range(0,len(facts)-1)

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
	while true:
		fact_label.text = facts[current_fact]
		current_fact = (current_fact + 1) % len(facts)
		fact_label.reset_size()
		fact_label.global_position.x = 800
		fact_label.global_position.y = 515
		showfact = true
		while showfact:
			await get_tree().process_frame

func _process(delta: float) -> void:
	if fact_label.global_position.x >= -1*fact_label.size.x:
		if anim.is_playing() == false:
			if Input.is_action_pressed("drift"):
				fact_label.global_position.x -= delta*500
			else:
				fact_label.global_position.x -= delta*100
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
		Savesystem.save_settings()
		var old = Gamestate.last_scene
		await Transition.fade_out()
		get_tree().change_scene_to_file(old)
		await Transition.fade_in()

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
