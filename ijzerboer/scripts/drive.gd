extends Node3D

@onready var car = $Car
@onready var ball = $Ball
@onready var ground_ray = $Car/RayCast3D

@onready var front_right_wheel: MeshInstance3D = $Car/Mesh/FrontRightWheel
@onready var front_left_wheel: MeshInstance3D = $Car/Mesh/FrontLeftWheel
@onready var back_left_wheel: MeshInstance3D = $Car/Mesh/BackLeftWheel
@onready var back_right_wheel: MeshInstance3D = $Car/Mesh/BackRightWheel
@onready var right_headlight: MeshInstance3D = $Car/Mesh/FrontRightLight
@onready var left_headlight: MeshInstance3D = $Car/Mesh/FrontLeftLight

@onready var drift: CPUParticles3D = $Car/Mesh/drift
@onready var drift_2: CPUParticles3D = $Car/Mesh/drift2
@onready var van_model: MeshInstance3D = $Car/Mesh/Van
@onready var license_plate: Label3D = $Car/Mesh/LicensePlate

@onready var needle: Sprite2D = $"../UI/Spedometer/Needle"
@onready var speed_lines: ColorRect = $"../UI/Spedometer/LineLayer/SpeedLines"

# Movement settings
var max_speed := 200.0
var max_reverse_speed := 25.0

var default_acceleration = 20	
var default_steering := 40.0 	

var drift_acceleration := 0.75 	# this is a multiplier, meaning if its set to 0.75, itll reduce the default acceleration by 25%
var drift_steering := 2.0 		# this is also a multipier

var grip := 20.0 				# amount of grip the tires have
var brake_mult := 0.98			# how hard the car brakes (The code basically does current_speed*brake_mult, so don't make it too low)
var full_turn_speed := 15.0		# the turn speed is normally determined by the cars speed, this is the speed needed to get full steering

var engine_multiplier = Gamestate.car_stats["engine_multiplier"]
# Misc. variables i.e. they're just here so they can be initialized
var speed_input := 0.0
var turn_input := 0.0

var steering:float = default_steering
var acceleration:float = default_acceleration
var smoothing:float = 1.0
var drift_pressed := false
var is_drifting := false
var was_already_drifting := false

func _ready() -> void:
	if brake_mult >= 1:
		brake_mult = 0.98
	license_plate.text = Gamestate.car_stats["licenseplate"]

func reduce_sideways_slipping(gripf):
	var velocity = ball.linear_velocity
	var forward = car.global_transform.basis.z.normalized()

	var forward_velocity = forward * velocity.dot(forward)
	var sideways_velocity = velocity - forward_velocity

	var grip_force = (-sideways_velocity * gripf).limit_length(40.0)
	ball.apply_central_force(grip_force)


func get_sideways_speed() -> float:
	var velocity = ball.linear_velocity
	var forward = car.global_transform.basis.z.normalized()
	var forward_velocity = forward * velocity.dot(forward)
	var sideways_velocity = velocity - forward_velocity
	return sideways_velocity.length()

func handleGUI(speed:int): #intermediate function to make _physics_process() look nicer
	$"../UI/Spedometer/Spedometer".text = str(speed) + " KM/H"
	var needle_orientation = -150+abs(int(speed))
	needle.rotation = deg_to_rad(clamp(needle_orientation, -155, 150))
	if needle_orientation > 150.0:
		needle.rotation += deg_to_rad(int(needle_orientation) % 10)
	
	var target = clamp(float(speed-30) / 1000.0, 0.0, 0.065)
	var current = float(speed_lines.material.get_shader_parameter("line_density"))
	speed_lines.material.set_shader_parameter("line_density", lerp(current, target, 0.02))

func calculateTurn(speed, direction) -> float:
	var turn_speed_temp:float = 0.0
	if speed <2.0:
		turn_speed_temp = 0.0
	elif speed < full_turn_speed and direction > 0.0:
		turn_speed_temp = abs(speed)/full_turn_speed
	else:
		turn_speed_temp = 1.0
	return turn_speed_temp

func _physics_process(delta):
	#some variables that can be used anywhere here
	var sideways_speed = get_sideways_speed()
	var speed:float = ball.linear_velocity.length()
	var forward_vector = car.transform.basis.z
	var forward_speed = ball.linear_velocity.dot(car.global_transform.basis.z)
	
	# Input
	speed_input = Input.get_axis("brake", "accelerate") * acceleration
	turn_input = deg_to_rad(steering) * Input.get_axis("steer_right", "steer_left")
	
	# Car mechanics / physics
	car.global_position = ball.global_position # Stick car mesh to the ball's position

	var dir = sign(forward_speed)
	car.rotate_y(turn_input * dir * delta * calculateTurn(speed,dir))

	if ground_ray.is_colliding():
		ball.apply_central_force(forward_vector * speed_input)
		var stability = min(speed * speed * 0.02, 60.0) # idk ik keek een video over racing games en meer gravity improved handling ofz
		ball.apply_central_force(-car.global_transform.basis.y * stability)

		if steering == default_steering:
			smoothing = clamp(smoothing+delta,0.0,1.0)
			reduce_sideways_slipping(grip*smoothing) #prevent the car from slipping
		else:
			smoothing = 0.0
			reduce_sideways_slipping(grip/20)
	
	#limit speed
	if forward_speed > max_speed:
		ball.linear_velocity = ball.linear_velocity.normalized() * max_speed
	elif forward_speed < -max_reverse_speed:
		ball.linear_velocity = ball.linear_velocity.normalized() * max_reverse_speed

	#braking (this is here so it gets calculated when the rest also gets calculated)
	if Input.is_action_pressed("brake") and forward_speed > 5.0:
		ball.linear_velocity *= brake_mult

	#----------------------------#
	#Anything under here is for cosmetic purposes and what not, above is the actual physics
	#----------------------------#

	# GUI Handling
	handleGUI(int(speed))

	# All FX related with drifting
	is_drifting = (drift_pressed and ground_ray.is_colliding() and speed > 10.0 and sideways_speed > 2.0)
	drift_2.emitting = is_drifting
	drift.emitting = is_drifting
	if not $Car/Skid.playing:
		was_already_drifting = true #dit werkt nog nie helemaal :P
		if was_already_drifting:
			$Car/Skid.play(0.8)
		else:
			$Car/Skid.playing = is_drifting
	elif is_drifting == false:
		$Car/Skid.playing = false

	# Tilt effect
	if turn_input != 0:
		van_model.rotation.z = clamp(van_model.rotation.z + turn_input * -0.05,deg_to_rad(-5),deg_to_rad(5))
		license_plate.rotation.z = clamp(license_plate.rotation.z + turn_input * 0.05,deg_to_rad(-5),deg_to_rad(5))
	else:
		van_model.rotation.z = lerp(van_model.rotation.z, 0.0, 0.1)
		license_plate.rotation.z = lerp(license_plate.rotation.z, 0.0, 0.1)

	# wheels spinning
	var true_turn  = deg_to_rad(default_steering*(drift_steering/1.5)) * Input.get_axis("steer_right", "steer_left")
	front_right_wheel.rotation.y = true_turn
	front_left_wheel.rotation.y = true_turn + deg_to_rad(180)
	
	var wheel_rotation = forward_speed * delta
	front_right_wheel.rotation.x += wheel_rotation
	front_left_wheel.rotation.x -= wheel_rotation
	back_right_wheel.rotation.x += wheel_rotation
	back_left_wheel.rotation.x -= wheel_rotation

func _input(event: InputEvent) -> void:
	if event.is_action("honk"):
		$Car/Honk.playing = event.is_pressed()
	if event.is_action_pressed("lights"):
		left_headlight.visible = not right_headlight.visible
		right_headlight.visible = left_headlight.visible #this is here to ensure that they're both either on or off 

func _process(_delta):
	license_plate.text = Gamestate.car_stats["licenseplate"] #TODO: make this into a signal, this is extremely inefficient lmao

	if Input.is_action_just_pressed("drift") and ball.linear_velocity.length() > 10.0:
		drift_pressed = true
		steering = default_steering * drift_steering
		acceleration = default_acceleration * drift_acceleration

	if Input.is_action_just_released("drift"):
		steering = default_steering
		acceleration = default_acceleration
		drift_pressed = false
		was_already_drifting = false
		$Car/Skid.stop()
