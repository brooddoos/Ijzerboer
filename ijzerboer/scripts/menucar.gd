extends Node3D
@onready var startpoint_1: Node3D = $"../StartPoint1"
@onready var endpoint_1: Node3D = $"../EndPoint1"
@onready var endpoint_2: Node3D = $"../EndPoint2"
@onready var startpoint_2: Node3D = $"../StartPoint2"
@onready var car: Node3D = $"."
@export var speed = 10

@export var front_right_wheel: MeshInstance3D
@export var front_left_wheel: MeshInstance3D
@export var back_left_wheel: MeshInstance3D
@export var back_right_wheel: MeshInstance3D

## if you read this: please improve the spaghetti
var destination:Vector3 = Vector3(0,0,0)
#related to driving state
var driving = false
var drunk = false
# related to arriving and departing
var counter = 0
var arrivedCount = 0
var offset = 600

func _ready() -> void:
	if speed != 0:
		car.position = startpoint_1.position
		car.rotation = startpoint_2.rotation
		destination = endpoint_1.position
	else:
		$AudioStreamPlayer3D.stop()

func _process(delta: float) -> void:
	if speed == 0:
		return
		
	counter += 1
	var direction = (destination - car.position)
	if (direction.length() < 0.1 or direction.length() > 100) and arrivedCount + offset <= counter: #if arrived
		if destination == endpoint_1.position:
			car.position = startpoint_2.position
			car.rotation = startpoint_2.rotation
			destination = endpoint_2.position
		elif destination == endpoint_2.position:
			car.position = startpoint_1.position
			car.rotation = startpoint_1.rotation
			destination = endpoint_1.position
		else:
			push_error("Car's malfunctioning.")
			
		arrivedCount = counter
		offset = randi_range(0,750)
		return
		
	if arrivedCount + offset <= counter or arrivedCount == 0: 
		direction = direction.normalized()
		car.look_at(destination, Vector3.UP)
		if drunk:
			car.rotation.y -= deg_to_rad(180+randi_range(-90,90))
			car.position += direction * speed*2 * delta
		else:
			car.rotation.y -= deg_to_rad(180)
			car.position += direction * speed * delta
	else:
		drunk = randi_range(0,2) == 1
		
		
	front_right_wheel.rotation.x += speed*delta
	front_left_wheel.rotation.x -= speed*delta
	back_right_wheel.rotation.x += speed*delta
	back_left_wheel.rotation.x -= speed*delta
	
