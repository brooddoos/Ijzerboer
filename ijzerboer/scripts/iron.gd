extends StaticBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"/root/Campaign/UI/Control/Values".update_cargo()
	var models = $Models.get_children()
	var model = models.pick_random()
	model.show()
	$Area3D.entered.connect(_on_body_entered)
	
	if Gamestate.car_stats["gps_metal_detector"]:
		$Area3D/marker.visible = true
	else:
		$Area3D/marker.visible = false

func _on_body_entered():
	if Gamestate.cargo < Gamestate.car_stats["max_cargo"]:
		Gamestate.cargo += 1
		self.queue_free()
		$"/root/Campaign/SpawnLocations".spawn_iron( )
