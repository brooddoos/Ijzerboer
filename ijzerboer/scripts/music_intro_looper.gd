extends AudioStreamPlayer

@export var Intro:AudioStream
@export var Loop:AudioStream
@onready var music: AudioStreamPlayer = $"."

func _ready() -> void:
	music.stream = Intro
	music.play()

func _on_finished() -> void:
	music.stop()
	music.stream = Loop
	music.play()
