extends Control
@onready var cassette: Node3D = $SubViewportContainer/SubViewport/Node3D/Cassette
@onready var animation_player = $SubViewportContainer/SubViewport/Node3D/Cassette/AnimationPlayer
@onready var title: Label3D  = $SubViewportContainer/SubViewport/Node3D/Cassette/label/text
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var cassette_start_pos = cassette.position.y
@onready var cassette_up := false
@export var current_tape = Gamestate.current_tape
var tapes = Gamestate.tapes
var tween

func load_music(path:String):
	if path.begins_with("res://"):
		audio.stream = load(path)
		return
	else: #is a user music 
		if path.ends_with("mp3"):
			var mp3 = AudioStreamMP3.load_from_file(path)
			audio.stream = mp3
		elif path.ends_with(".ogg"):
			var ogg = AudioStreamOggVorbis.load_from_file(path)
			audio.stream = ogg
		elif path.ends_with(".wav"):
			var wav = AudioStreamWAV.load_from_file(path)
			audio.stream = wav
		else:
			push_error("Audio is only supported in the MP3, OGG or WAV filetypes: " + path)
			return

func allTween(transistionType:Tween.TransitionType,object,property:String,vars,time:float): #zoda we nie 10x dezelfde functie opnieuw moete schrijven
	tween = get_tree().create_tween()
	tween.set_trans(transistionType)
	tween.tween_property(object, property, vars, time)

func _ready() -> void:
	if current_tape > len(tapes):
		current_tape = 1
		Gamestate.currentTape = 1
	title.text = tapes[current_tape]["title"]
	
	if !title.text.contains("\n"):
		title.text = title.text + "\n "
	cassette.position.y = cassette_start_pos - 0.05
	cassette_up = false
	load_music(tapes[current_tape]["file"])
	audio.play(0)
	animation_player.play("cassette_animation")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("info"):
		cassette_up = not cassette_up
		if cassette_up:
			allTween(Tween.TRANS_EXPO,cassette,"position:y",cassette_start_pos - 0.01 ,0.25)
		else:
			allTween(Tween.TRANS_EXPO,cassette,"position:y",cassette_start_pos - 0.05,0.25)

	if event.is_action_pressed("cassette"):
		current_tape = (current_tape % len(tapes)) + 1
		Gamestate.current_tape = current_tape

		allTween(Tween.TRANS_EXPO,cassette,"position:y",cassette_start_pos - 0.1,0.25)
		await tween.finished
		title.text = tapes[current_tape]["title"]
		if !title.text.contains("\n"):
			title.text = title.text + "\n "
			
		allTween(Tween.TRANS_EXPO,cassette,"position:y",cassette_start_pos - 0.05,0.25)
		cassette_up = false
		audio.stop()
		load_music(tapes[current_tape]["file"])
		audio.play(0)


func _on_audio_stream_player_finished() -> void:
	current_tape = (current_tape % len(tapes)) + 1
	Gamestate.current_tape = current_tape

	allTween(Tween.TRANS_EXPO,cassette,"position:y",cassette_start_pos - 0.1,0.25)
	await tween.finished
	title.text = tapes[current_tape]["title"]
	if !title.text.contains("\n"):
		title.text = title.text + "\n "
		
	allTween(Tween.TRANS_EXPO,cassette,"position:y",cassette_start_pos - 0.05,0.25)
	cassette_up = false
	audio.stop()
	load_music(tapes[current_tape]["file"])
	audio.play(0)
