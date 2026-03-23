extends Control
@onready var _3_dsplashtext: Label3D = $"../../Logo/3dsplashtext"
@export var scene:PackedScene
@onready var version_text: Button = $Version/Version
@onready var start: Label = $Start

# cam stuff
@export var camera: Camera3D
var origin:Vector3
var originz
var stength:float = 0.1

var house = preload("res://scenes/start/House.tscn") #om lag te voorkomen

const splashTexts = [ #voeg later mss meer toe, idk
	"Man, man, man, miserie, miserie, miserie!",
	"Hier zijn geen ijzertekorten te bespeuren!",
	"Mijnen infra -fra -fra -fra infrastructuur!",
	"Nu ook op Windows 98!",
	"Tegels, natuursteen, parket, Imp... Ah just nee, miljaar.",
	"Kovy Deukens, wij maken uw België in keuken",
	"Zal't gaan ja?!",
	"Mijn gedacht."
]

var rng = RandomNumberGenerator.new()
var version = ProjectSettings.get_setting("application/config/version")

func _ready() -> void:
	origin = camera.global_position
	_3_dsplashtext.text = splashTexts[rng.randi_range(0,len(splashTexts)-1)]
	version_text.text = "v"+str(version) 

var time := 0.0
func _process(delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var mx = (mouse.x / viewport_size.x - 0.5) * 2.0
	var my = (mouse.y / viewport_size.y - 0.5) * 2.0

	var offset = Vector3(mx * stength, -my * stength, 0)
	camera.global_position = origin + offset
	
	time += delta
	
	start.modulate.a = abs(sin(time))
	
	if time >= 15 and start.modulate.a < 0.05:
		start.text = "  Press START (the spacebar lol)  "
	
var transitioning := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not transitioning:
		transitioning = true
		$"../../Camera3D/AnimationPlayer".play("camera_anim") # play camera movement
		
		var tween = self.create_tween().set_parallel(true)
		tween.tween_property(self, "scale", self.scale * 2, 1)
		tween.tween_property(self, "modulate:a", 0, 1)
		await tween.finished
		self.hide() 
		
		while $"../../Camera3D/AnimationPlayer".current_animation_position < 1.75:
			await get_tree().process_frame  # wait one frame
			
		await Transition.fade_out()
		get_tree().paused = false
		get_tree().change_scene_to_packed(house)
		await Transition.fade_in()


func _on_version_pressed() -> void:
	OS.shell_open("https://github.com/brooddoos/ijzerboer/releases/tag/v"+str(version))

func _on_company_text_pressed() -> void:
	OS.shell_open("https://github.com/brooddoos")
