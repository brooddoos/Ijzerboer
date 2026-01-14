extends Node3D

@onready var car = $Car
@onready var ball = $Ball
@onready var ground_ray = $Car/RayCast3D
@onready var needle: Sprite2D = $"../UI/Spedometer/Needle"
@onready var front_right_wheel = $Car/Mesh/FrontRightWheel
@onready var front_left_wheel = $Car/Mesh/FrontLeftWheel
@onready var back_left_wheel: MeshInstance3D = $Car/Mesh/BackLeftWheel
@onready var back_right_wheel: MeshInstance3D = $Car/Mesh/BackRightWheel
@onready var speed_lines: ColorRect = $"../UI/LineLayer/SpeedLines"
@onready var mesh: MeshInstance3D = $Car/Mesh/Van
@onready var license_plate: Label3D = $Car/Mesh/LicensePlate

@onready var drift_2: CPUParticles3D = $Car/Mesh/drift2
@onready var drift: CPUParticles3D = $Car/Mesh/drift

# Movement settings
var default_acceleration = Gamestate.car_stats["acceleration"]	
var accel_multiplier = 0.75 	# for drifting
var default_steering = 30.0 	# degrees
var steer_multiplier = 2.0 		# for drifting
var grip = 20.0 				# amount of grip the tires have
var brake_mult = 0.98			# lower = brakes faster, higher slower DONT make it more than one (itll accelerate instead of brake)
var full_turn_speed = 15.0			# speed needed to gain full steering

# Input
var speed_input := 0.0
var turn_input := 0.0

var steering:float # added so you only need to update one variable (see settings /\)
var acceleration:float # same here
var smoothing:float = 1.0

var is_drifting := false

func _ready() -> void:
	steering = default_steering
	acceleration = default_acceleration
	license_plate.text = Gamestate.car_stats["licenseplate"]

func anti_slip_function(gripf):
	var velocity = ball.linear_velocity
	var forward = car.global_transform.basis.z.normalized()

	var forward_velocity = forward * velocity.dot(forward) #dot() berekent hvl van de snelheid vooruit is
	var sideways_velocity = velocity - forward_velocity #wat overblijft is zijwaarts (dit willen we dus nie)
	
	ball.apply_central_force(-sideways_velocity * gripf)

func get_sideways_speed() -> float: #nah cuz why i cant find a proper function for this
	var velocity = ball.linear_velocity
	var forward = car.global_transform.basis.z.normalized()
	var forward_velocity = forward * velocity.dot(forward)
	var sideways_velocity = velocity - forward_velocity
	return sideways_velocity.length()

func _physics_process(delta):
	# Stick car mesh to the ball's position
	car.global_position = ball.global_position
	
	# Spedometer
	var speed = int(ball.linear_velocity.length())
	$"../UI/Spedometer/Spedometer".text = str(speed) + " KM/H"
	var needle_orientation = -150+abs(int(speed))
	needle.rotation = deg_to_rad(clamp(needle_orientation, -155, 150))
	if needle_orientation > 150.0:
		needle.rotation += deg_to_rad(int(needle_orientation) % 10)
	
	var target = clamp(float(speed-30) / 1000.0, 0.0, 0.065)
	var current = float(speed_lines.material.get_shader_parameter("line_density"))
	speed_lines.material.set_shader_parameter("line_density", lerp(current, target, 0.02))
	
	# Input
	speed_input = Input.get_axis("brake", "accelerate") * acceleration
	turn_input = deg_to_rad(steering) * Input.get_axis("steer_right", "steer_left")
	
	# Apply movement force
	var forward = car.transform.basis.z
	
	if turn_input != 0: #tilt effect for turning
		mesh.rotation.z = clamp(mesh.rotation.z + turn_input * -0.05,deg_to_rad(-5),deg_to_rad(5))
		license_plate.rotation.z = clamp(license_plate.rotation.z + turn_input * 0.05,deg_to_rad(-5),deg_to_rad(5))
		
	else:
		mesh.rotation.z = lerp(mesh.rotation.z, 0.0, 0.1)
		license_plate.rotation.z = lerp(license_plate.rotation.z, 0.0, 0.1)
	
	var dir = sign(ball.linear_velocity.dot(car.global_transform.basis.z))
	
	var turn_speed_temp = 0.0
	if ball.linear_velocity.length() <2.0:
		turn_speed_temp = 0.0
	elif ball.linear_velocity.length() < full_turn_speed and dir > 0.0:
		turn_speed_temp = abs(ball.linear_velocity.length())/full_turn_speed
	else:
		turn_speed_temp = 1.0
		
	car.rotate_y(turn_input * dir * delta * turn_speed_temp)
		
	var sideways_speed = get_sideways_speed()
	var is_actually_drifting = (is_drifting and ground_ray.is_colliding() and ball.linear_velocity.length() > 5.0 and sideways_speed > 1.5)
	if is_actually_drifting: #with speed accounted and shit
		drift_2.emitting = true
		drift.emitting = true
		if not $Car/Skid.playing:
			$Car/Skid.play()
	else:
		drift_2.emitting = false
		drift.emitting = false
		$Car/Skid.stop()
		
	if ground_ray.is_colliding():
		ball.apply_central_force(forward * speed_input)
		if steering == default_steering:
			smoothing = clamp(smoothing+delta,0.0,1.0)
			anti_slip_function(grip*smoothing) #prevent the car from slipping
		else:
			smoothing = 0.0
			anti_slip_function(grip/20)
	else:
		drift_2.emitting = false
		drift.emitting = false
	
	# wheels
	front_right_wheel.rotation.y = turn_input
	front_left_wheel.rotation.y = turn_input+deg_to_rad(180)
	
	var wheelRotation = ball.linear_velocity.dot(forward) * delta
	front_right_wheel.rotation.x += wheelRotation
	front_left_wheel.rotation.x -= wheelRotation
	back_right_wheel.rotation.x += wheelRotation
	back_left_wheel.rotation.x -= wheelRotation


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("honk"):
		$Car/Honk.play()
	if event.is_action_released("honk"):
		$Car/Honk.stop()
	if event.is_action_pressed("lights"):
		$Car/Mesh/FrontLeftLight.visible = not $Car/Mesh/FrontLeftLight.visible
		$Car/Mesh/FrontRightLight.visible = not $Car/Mesh/FrontRightLight.visible
	if event.is_action_pressed("drift"):
		steering = default_steering*steer_multiplier
		acceleration = default_acceleration*accel_multiplier
		is_drifting = true
	if event.is_action_released("drift"):
		steering = default_steering
		acceleration = default_acceleration
		acceleration = default_acceleration*accel_multiplier
		is_drifting = false
		$Car/Skid.stop()

func _process(_delta):
	license_plate.text = Gamestate.car_stats["licenseplate"]
	var forward_speed = ball.linear_velocity.dot(car.global_transform.basis.z)
	if Input.is_action_pressed("brake") and forward_speed > 5.0:
		ball.linear_velocity *= brake_mult
