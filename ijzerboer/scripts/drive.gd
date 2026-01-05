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


@onready var drift_2: CPUParticles3D = $Car/Mesh/drift2
@onready var drift: CPUParticles3D = $Car/Mesh/drift


# Movement settings
var default_acceleration = Gamestate.car_stats["acceleration"]	
var accel_multiplier = 0.75 	# for drifting
var default_steering = 30.0 	# degrees
var steer_multiplier = 2.0 		# for drifting
var turn_minimum = 2.0 			# minimum speed to turn
var grip = 10.0 				# amount of grip the tires have

# Input
var speed_input := 0.0
var turn_input := 0.0

var steering:float # added so you only need to update one variable (see settings /\)
var acceleration:float # same here
var smoothing:float = 1.0

var is_drifting = false

func _ready() -> void:
	steering = default_steering
	acceleration = default_acceleration
	$Car/Mesh/LicensePlate.text = Gamestate.car_stats["licenseplate"]

func anti_slip_function(gripf):
	var velocity = ball.linear_velocity
	var forward = car.global_transform.basis.z.normalized()

	var forward_velocity = forward * velocity.dot(forward) #dot() berekent hvl van de snelheid vooruit is
	var sideways_velocity = velocity - forward_velocity #wat overblijft is zijwaarts (dit willen we dus nie)
	
	ball.apply_central_force(-sideways_velocity * gripf)
	
func _physics_process(delta):
	# Stick car mesh to the ball's position
	car.global_position = ball.global_position
	
	# Spedometer
	var speed = int(ball.linear_velocity.length() * 3.6 / 3.0)
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
		mesh.rotation.z = clamp(
			mesh.rotation.z + turn_input * -0.05,
			deg_to_rad(-5),
			deg_to_rad(5)
		)
	else:
		mesh.rotation.z = lerp(mesh.rotation.z, 0.0, 0.1)
		
	if ball.linear_velocity.length() > turn_minimum:
		var dir = sign(ball.linear_velocity.dot(car.global_transform.basis.z))
		car.rotate_y(turn_input * dir * delta)
		
	if is_drifting and ball.linear_velocity.length() > turn_minimum and turn_input != 0:
		$Car/Mesh/drift2.emitting = true
		$Car/Mesh/drift.emitting = true
	else:
		$Car/Mesh/drift2.emitting = false
		$Car/Mesh/drift.emitting = false
		
	if ground_ray.is_colliding():
		ball.apply_central_force(forward * speed_input)
		if steering == default_steering:
			smoothing = clamp(smoothing+delta,0.0,1.0)
			anti_slip_function(grip*smoothing) #prevent the car from slipping
		else:
			smoothing = 0.0
			anti_slip_function(grip/20)
			#var car_velocity = car.global_transform.basis.z.normalized()
			#drift.look_at(global_transform.origin + car_velocity, Vector3.UP)
			#drift_2.look_at(global_transform.origin + car_velocity, Vector3.UP)
	if not ground_ray.is_colliding():
		drift_2.emitting = false
		drift.emitting = false
		return
	
	# wheels
	front_right_wheel.rotation.y = turn_input
	front_left_wheel.rotation.y = turn_input+deg_to_rad(180)
	
	var wheelRotation = ball.linear_velocity.dot(forward) * delta
	front_right_wheel.rotation.x += wheelRotation
	front_left_wheel.rotation.x += wheelRotation
	back_right_wheel.rotation.x += wheelRotation
	back_left_wheel.rotation.x += wheelRotation
	
	#if OS.is_debug_build():
		#print("Velocity: X: " + str(int(ball.linear_velocity.x)) + " | Y: " + str(int(ball.linear_velocity.y)) + " | Z: " + str(int(ball.linear_velocity.z)))

func _process(_delta):
	#honk
	if Input.is_action_just_pressed("honk"):
		$Car/AudioStreamPlayer3D.play()
	if Input.is_action_just_pressed("lights"):
		$Car/Mesh/FrontLeftLight.visible = not $Car/Mesh/FrontLeftLight.visible
		$Car/Mesh/FrontRightLight.visible = not $Car/Mesh/FrontRightLight.visible
	if Input.is_action_just_pressed("drift"):
		steering = default_steering*steer_multiplier
		acceleration = default_acceleration*accel_multiplier
		is_drifting = true
	if Input.is_action_just_released("drift"):
		steering = default_steering
		acceleration = default_acceleration
		acceleration = default_acceleration*accel_multiplier
		is_drifting = false
