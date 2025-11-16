extends Control
@onready var settings: PanelContainer = $Settings
@onready var _3_dsplashtext: Label3D = $"../../logo/3dsplashtext"
@onready var buttons: PanelContainer = $Buttons

const splashTexts = [ #voeg later mss meer toe, idk
	"im uhhh the iron metal collector man",
	"Man, man, man, ... miserie, miserie",
	"a great source of iron",
	"a not so great source of iron",
	"im picking up metals wow",
]

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	_3_dsplashtext.text = splashTexts[rng.randi_range(0,len(splashTexts)-1)]

func _on_play_pressed() -> void:
	Transition.changescene()

func _on_options_pressed() -> void:
	buttons.visible = !buttons.visible
	settings.visible = !settings.visible
	
func _on_exit_pressed() -> void:
	get_tree().quit()
