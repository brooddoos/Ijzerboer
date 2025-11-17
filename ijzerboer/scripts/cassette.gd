extends Node3D
@export var cassette_1: MeshInstance3D
@export var cassette_2: MeshInstance3D
@export var labelText: Label3D
@export var speed:int = 2
@export var rotateRight:bool = false
@export_multiline var title:String = "placeholder placeholder"

func _ready() -> void:
	labelText.text = title
	
func _process(delta: float) -> void:
	if rotateRight:
		cassette_1.rotation.z += delta*-speed
		cassette_2.rotation.z += delta*-speed
	else:
		cassette_1.rotation.z += delta*speed
		cassette_2.rotation.z += delta*speed
