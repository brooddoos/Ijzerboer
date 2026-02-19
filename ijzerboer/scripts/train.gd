extends Node3D
@onready var path := $Path3D
@onready var pathfollow := $Path3D/PathFollow3D
@onready var pathlength = path.curve.get_baked_length()
@onready var train := $Path3D/PathFollow3D/HLE16
@onready var audiostreamplayer := $Path3D/PathFollow3D/AudioStreamPlayer3D
var waiting := false

func _process(delta: float) -> void:
	if waiting:
		return
	pathfollow.progress += 40 * delta
	if pathfollow.progress_ratio >= 1.0:
		pathfollow.progress_ratio = 1.0
		wait()
		
func wait():
	waiting = true
	train.hide()
	audiostreamplayer.playing = false
	await get_tree().create_timer(30).timeout
	pathfollow.progress_ratio = 0.0
	waiting = false
	train.show()
	audiostreamplayer.playing = true
	
