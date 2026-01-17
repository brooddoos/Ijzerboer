extends Camera3D

@export var car:Node3D
@export var back_view:Node3D
@export var left_view:Node3D
@export var right_view:Node3D
@export var up_view:Node3D
@export var down_view:Node3D

var used_cam_pos

func _ready() -> void:
	used_cam_pos = back_view

func _physics_process(_delta : float):
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
	
	var target_pos = lerp(global_position, used_cam_pos.global_position, 0.1)

	if target_pos.distance_to(car.global_position) > 10.0:
		target_pos = car.global_position + (target_pos - car.global_position).normalized() * 10.0

	global_position = target_pos
	look_at(car.global_position)
