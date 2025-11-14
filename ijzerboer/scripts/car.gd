extends MeshInstance3D
@onready var startpoint_1: Node3D = $"../startpoint1"
@onready var endpoint_1: Node3D = $"../endpoint1"
@onready var endpoint_2: Node3D = $"../endpoint2"
@onready var startpoint_2: Node3D = $"../startpoint2"
@onready var car: MeshInstance3D = $"."
@export var speed = 10

var rng = RandomNumberGenerator.new()
var driving = false
var destination:Vector3 = Vector3(0,0,0)
var counter = 0
var arrivedCount = 0
var isDrun = false

func randint(minimu:int, maximu:int) -> int: #im used to python :P
	return rng.randi_range(minimu, maximu)

func _ready() -> void:
	car.position = startpoint_1.position
	car.rotation = startpoint_2.rotation
	destination = endpoint_1.position

func _process(delta: float) -> void:
	counter += 1
	var direction = (destination - car.position)
	if direction.length() < 0.1: #ge zijt aangekomen maat
		if destination == endpoint_1.position:
			car.position = startpoint_2.position
			car.rotation = startpoint_2.rotation
			destination = endpoint_2.position
		elif destination == endpoint_2.position:
			car.position = startpoint_1.position
			car.rotation = startpoint_1.rotation
			destination = endpoint_1.position
		else:
			push_error("gvd auto zit te malfunctioneren")
		return
		
	if arrivedCount + 600 <= counter: 
		direction = direction.normalized()
		car.look_at(destination, Vector3.UP)
		if isDrun:
			car.rotation.y -= deg_to_rad(180+randint(-90,90))
		else:
			car.rotation.y -= deg_to_rad(180)
		car.position += direction * speed * delta
	else:
		isDrun = randint(1,1) == 1
