extends Node3D
@onready var path := $Path3D
@onready var pathfollow := $Path3D/PathFollow3D
@onready var pathlength = path.curve.get_baked_length() 
@onready var train := $Path3D/PathFollow3D/HLE16
@onready var audiostreamplayer := $Path3D/PathFollow3D/AudioStreamPlayer3D
@onready var crossinglocation = $Crossing.global_position
var waiting := false
var wait_time := 30 #in s
var speed = 40 #in m/s
var trainlocation
var distance
var closed = false
func _process(delta: float) -> void:
	trainlocation = $Path3D/PathFollow3D.global_position
	if waiting:
		return
	pathfollow.progress += speed * delta
	if pathfollow.progress_ratio >= 1.0:
		pathfollow.progress_ratio = 1.0
		wait()
	distance = trainlocation.distance_to(crossinglocation)
	## barrier
	if distance < 100 and closed == false:
		$Crossing/AnimationPlayer.play_backwards("PlaneAction")
		closed = true
	elif distance > 100 and closed == true:
		$Crossing/AnimationPlayer.play("PlaneAction")
		closed = false
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
	
