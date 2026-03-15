extends Node
@warning_ignore("integer_division") var last_hour := (int(Gamestate.time) / 3600) % 24
func _physics_process(delta: float) -> void:
	Gamestate.time += delta * 60
	@warning_ignore("integer_division") var seconds = int(Gamestate.time) % 60 
	@warning_ignore("integer_division") var minutes = (int(Gamestate.time) / 60) % 60
	@warning_ignore("integer_division") var hour = (int(Gamestate.time) / 3600) % 24
	$Time.text = "%02d:%02d:%02d" % [hour, minutes, seconds]
	var rings = hour % 12
		
	if last_hour != hour:
		last_hour = hour
		if hour >= 7 and hour <= 22:
			for i in range(0,rings): 
				while get_tree().paused:
					await get_tree().process_frame
				$Bell.play()
				await get_tree().create_timer(1.0).timeout
