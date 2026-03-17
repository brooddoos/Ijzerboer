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

@onready var smoke: GPUParticles3D = $Car/Mesh/Smoke
@onready var smoke_2: GPUParticles3D = $Car/Mesh/Smoke2
@onready var van_model: MeshInstance3D = $Car/Mesh/Van
@onready var back_license_plate: Label3D = $Car/Mesh/Van/BackLicensePlate
@onready var front_license_plate: Label3D = $Car/Mesh/Van/FrontLicensePlate

@onready var needle: Sprite2D = $"../UI/Control/Spedometer/Needle"
@onready var speed_lines: ColorRect = $"../UI/Control/Spedometer/LineLayer/SpeedLines"
@onready var minimap: Control = $"../UI/Control/Minimap"
@onready var minimap_cam: Camera3D = $"../UI/Control/Minimap/TextureRect/SubViewportContainer/SubViewport/MinimapCam"
@onready var pointer: TextureRect = $"../UI/Control/Minimap/TextureRect/pointer"

#@onready var pivot := $Car/pivot
@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var back_view := $Car/BackCamera
@onready var left_view := $Car/LeftCamera
@onready var right_view := $Car/RightCamera
@onready var up_view := $Car/TopCamera
@onready var down_view := $Car/FrontCamera

@onready var skid: AudioStreamPlayer3D = $Car/Skid

# Movement settings
var max_speed :int= 25.0 + Gamestate.car_upgrades["engine"] * 5
var max_reverse_speed := 25.0

var default_acceleration = 10	
var default_steering := 40.0 	

var drift_acceleration := 0.75 	# this is a multiplier, meaning if its set to 0.75, itll reduce the default acceleration by 25%
var drift_steering := 2.0 		# this is also a multipier

var grip := 20.0 				# amount of grip the tires have
var brake_mult := 0.98			# how hard the car brakes (The code basically does current_speed*brake_mult, so don't make it too low)
var full_turn_speed := 15.0		# the turn speed is normally determined by the cars speed, this is the speed needed to get full steering

# Misc. variables i.e. they're just here so they can be initialized
var speed_input := 0.0
var turn_input := 0.0

var steering:float = default_steering
var acceleration:float = default_acceleration
var smoothing:float = 1.0
var drift_pressed := false
var is_drifting := false
var was_already_drifting := false
var used_cam_pos = back_view

func _ready() -> void:
	if brake_mult >= 1:
		brake_mult = 0.98
	back_license_plate.text = Gamestate.car_upgrades["licenseplate"]
	front_license_plate.text = Gamestate.car_upgrades["licenseplate"]
	#$Car/Pointer.visible = true #for minimap

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
	$"../UI/Control/Spedometer/Spedometer".text = str(speed) + " KM/H"
	if minimap:
		minimap_cam.position.x = car.global_position.x
		minimap_cam.position.z = car.global_position.z
		pointer.rotation = car.rotation.y*-1 + 135
	
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
	## physics
	#some variables that can be used anywhere here
	var sideways_speed = get_sideways_speed()
	var speed:float = ball.linear_velocity.length()
	var forward_vector = car.transform.basis.z
	var forward_speed = ball.linear_velocity.dot(car.global_transform.basis.z)
	
	# Input
	speed_input = Input.get_axis("brake", "accelerate") * acceleration + (Input.get_axis("brake", "accelerate"))
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
		
	# Camera
	if Input.is_action_pressed("left_view"):
		used_cam_pos = left_view
	elif Input.is_action_pressed("right_view"):
		used_cam_pos = right_view
	elif Input.is_action_pressed("up_view"):
		used_cam_pos = up_view
	elif Input.is_action_pressed("down_view"):
		used_cam_pos = down_view
	else:
		used_cam_pos = back_view
	var target_pos = lerp(camera_3d.global_position, used_cam_pos.global_position, 0.1)

	if target_pos.distance_to(car.global_position) > 10.0:
		target_pos = car.global_position + (target_pos - car.global_position).normalized() * 10.0

	camera_3d.global_position = target_pos
	camera_3d.look_at(car.global_position)

	#pivot.global_position = target_pos
	#pivot.look_at(car.global_position)
	#pivot.rotate_object_local(Vector3.UP, deg_to_rad(180))
	#camera_3d.look_at(car.global_position)
	
	## Visuals
	# GUI Handling
	handleGUI(int(speed))
	
	# All FX related with drifting
	is_drifting = (drift_pressed and ground_ray.is_colliding() and speed > 10.0 and sideways_speed > 2.0)
	

	smoke.emitting = is_drifting
	smoke_2.emitting = is_drifting
	
	if is_drifting and not skid.playing:
		skid.play()

	elif not is_drifting and skid.playing:
		skid.stop()

	# Tilt effect
	if turn_input != 0:
		van_model.rotation.z = clamp(van_model.rotation.z + turn_input * -0.05,deg_to_rad(-5),deg_to_rad(5))
	else:
		van_model.rotation.z = lerp(van_model.rotation.z, 0.0, 0.1)

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
	if Input.is_action_just_pressed("drift") and ball.linear_velocity.length() > 10.0:
		drift_pressed = true
		steering = default_steering * drift_steering
		acceleration = default_acceleration * drift_acceleration

	if Input.is_action_just_released("drift"):
		steering = default_steering
		acceleration = default_acceleration
		drift_pressed = false
		was_already_drifting = false
		skid.stop()
