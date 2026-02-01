extends Control
@onready var settings: Button = $Buttons/MarginContainer/HBoxContainer/Settings
@onready var _3_dsplashtext: Label3D = $"../../Logo/3dsplashtext"
@onready var buttons: PanelContainer = $Buttons
@export var scene:PackedScene
@onready var version_text: Label = $Version

# cam stuff
@export var camera: Camera3D
var origin:Vector3
var originz
var stength:float = 0.1

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
	version_text.text = " v"+str(version)
	$Buttons/MarginContainer/HBoxContainer/Settings.pressed.connect(_on_settings_pressed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("drift"):
		_3_dsplashtext.text = splashTexts[rng.randi_range(0,len(splashTexts)-1)]
	
	var mouse = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var mx = (mouse.x / viewport_size.x - 0.5) * 2.0
	var my = (mouse.y / viewport_size.y - 0.5) * 2.0

	var offset = Vector3(mx * stength, -my * stength, 0)
	camera.global_position = origin + offset

func _on_play_pressed() -> void:
	await Transition.fade_out()
	get_tree().change_scene_to_packed(scene)
	await Transition.fade_in()

func _on_settings_pressed() -> void:
	await Transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")
	await Transition.fade_in()

func _on_exit_pressed() -> void:
	await Transition.fade_out()
	get_tree().quit()
