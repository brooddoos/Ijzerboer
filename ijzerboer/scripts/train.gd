extends Node3D
#@onready var train := $Path3D/PathFollow3D/HLE16
@onready var crossings = $Crossings.get_children()
@onready var trainpaths = $Trains.get_children()

var wait_time := 30 #in s
var speed = 40 #in m/s
var close_dinstance = 200 #in m

var trainlocation
var distance
var crossinglocation
var crossingstates := {}
var pathlength := {}
var pathfollow := {}
var audio := {}
var model := {}
var waiting := {}
var stop := {}

func _ready():
	for crossing in crossings:
		crossingstates[crossing]="open"
	for trainpath in trainpaths:
		pathfollow[trainpath]=trainpath.get_node("PathFollow3D")
		pathlength[trainpath]=trainpath.curve.get_baked_length()
		audio[trainpath]=trainpath.get_node("PathFollow3D/AudioStreamPlayer3D")
		model[trainpath]=trainpath.get_node("PathFollow3D/HLE16")
		waiting[trainpath]=false
		stop[trainpath] = false

func train_wait(trainpath):
	model[trainpath].hide()
	audio[trainpath].playing = false
	
	await get_tree().create_timer(wait_time).timeout
	
	pathfollow[trainpath].progress_ratio = 0.0
	model[trainpath].show()
	audio[trainpath].playing = true
	waiting[trainpath] = false
	stop[trainpath] = false

func _process(delta: float) -> void:
	for trainpath in trainpaths:
		trainlocation = pathfollow[trainpath].global_position
		if waiting[trainpath] and not stop[trainpath]:
			stop[trainpath] = true
			waiting[trainpath] = false
			train_wait(trainpath) # want euhh await and _process gn nie samen
			continue
		elif stop[trainpath]:
			continue
			
		if waiting[trainpath] or stop[trainpath]: #WHY DOESNT THE TRAIN SHUT THE HELL UP
			audio[trainpath].playing = false
		else:
			if not audio[trainpath].playing:
				audio[trainpath].playing = true
		
		pathfollow[trainpath].progress += speed * delta
		if pathfollow[trainpath].progress_ratio >= 1.0:
			pathfollow[trainpath].progress_ratio = 1.0
			waiting[trainpath] = true
		
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
	
