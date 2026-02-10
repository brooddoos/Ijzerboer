extends Node3D
var iron_scene = load("res://scenes/game/Iron.tscn")
func spawn_iron():
	#Get random spawn location
	var spawnlocations = get_children()
	
	for spawn in spawnlocations.duplicate():
		if spawn.get_child_count() > 0:
			spawnlocations.erase(spawn)
			
	var spawnlocation = spawnlocations.pick_random()
	var iron_instance = iron_scene.instantiate()
	spawnlocation.add_child(iron_instance) 
	iron_instance.global_transform = spawnlocation.global_transform
	print("iron spawned")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_iron()
	spawn_iron()
	spawn_iron()
