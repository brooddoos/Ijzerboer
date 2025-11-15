extends Control
@onready var splashtext: Label = $VBoxContainer/splashtext
@onready var title: RichTextLabel = $VBoxContainer/title
@onready var _3_dsplashtext: Label3D = $"../../logo/3dsplashtext"

const splashTexts = [ #voeg later mss meer toe, idk
	"im uhhh the iron metal collector man",
	"Man, man, man, ... miserie, miserie",
	"a great source of iron",
	"a not so great source of iron",
	"im picking up metals wow",
]

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	splashtext.text = " "
	_3_dsplashtext.text = splashTexts[rng.randi_range(0,len(splashTexts)-1)]
	title.text = " "

func _on_play_pressed() -> void:
	push_error("ijzer ijzer ijzer ijzer")
	# voeg hier load code toe vr game start

func _on_options_pressed() -> void:
	print("euhhh nrml gezien zijn er instelling mr kheb nog niets gedaan eig")

func _on_exit_pressed() -> void:
	get_tree().quit()
