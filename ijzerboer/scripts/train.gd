extends Node3D
@onready var path := $Path3D
@onready var pathfollow := $Path3D/PathFollow3D
@onready var pathlength = path.curve.get_baked_length() 
@onready var train := $Path3D/PathFollow3D/HLE16
@onready var audiostreamplayer := $Path3D/PathFollow3D/AudioStreamPlayer3D
@onready var crossings = $Crossings.get_children()

var wait_time := 30 #in s
var speed = 40 #in m/s
var close_dinstance = 200 #in m
var waiting := false
var trainlocation
var distance
var crossinglocation
var crossingstates := {}
func _ready():
	for crossing in crossings:
		crossingstates[crossing]="open"
func _process(delta: float) -> void:
	trainlocation = $Path3D/PathFollow3D.global_position
	if waiting:
		return
	pathfollow.progress += speed * delta
	if pathfollow.progress_ratio >= 1.0:
		pathfollow.progress_ratio = 1.0
		wait()
		
	## crossing
	for crossing in crossings:
		crossinglocation = crossing.global_position
		distance = trainlocation.distance_to(crossinglocation)
		if distance < close_dinstance and crossingstates[crossing] == "open":
			crossing.get_node("AnimationPlayer").play_backwards("PlaneAction")
			crossingstates[crossing] = "closed"
		elif distance > close_dinstance and crossingstates[crossing] == "closed":
			crossing.get_node("AnimationPlayer").play("PlaneAction")
			crossingstates[crossing] = "open"
		else:
			pass
func wait():
	waiting = true
	train.hide()
	audiostreamplayer.playing = false
	await get_tree().create_timer(wait_time).timeout
	pathfollow.progress_ratio = 0.0
	waiting = false
	train.show()
	audiostreamplayer.playing = true
	
