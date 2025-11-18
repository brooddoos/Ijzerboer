extends Node3D
@export var cassette_1: MeshInstance3D
@export var cassette_2: MeshInstance3D
@export var labelText: Label3D
@export var speed:int = 2
@export var rotateRight:bool = false
@export_multiline var title:String = "placeholder placeholder"
	
func setupTape(currentTape): #jesus dit is een rommel, TODO: make this less crap
	if currentTape["type"] == 1 and $".".name == "cassettelowpoly":
		labelText.text = currentTape["title"]
		speed = currentTape["speed"]
		rotateRight = !currentTape["rotateright"]
		$".".visible = true
	elif currentTape["type"] == 2 and $".".name == "Cassette":
		labelText.text = currentTape["title"]
		speed = currentTape["speed"]
		rotateRight = !currentTape["rotateright"]
		$".".visible = true
	else:
		$".".visible = false
	
func _process(delta: float) -> void:
	if rotateRight:
		if $".".name == "cassettelowpoly":
			cassette_1.rotation.x += delta*-speed
			cassette_2.rotation.y += delta*-speed
		else:
			cassette_1.rotation.z += delta*-speed
			cassette_2.rotation.z += delta*-speed
	else:
		if $".".name == "cassettelowpoly":
			cassette_1.rotation.x += delta*speed
			cassette_2.rotation.y += delta*speed
		else:
			cassette_1.rotation.z += delta*speed
			cassette_2.rotation.z += delta*speed

func _on_control_new_tape(currentTape) -> void:
	setupTape(currentTape)
