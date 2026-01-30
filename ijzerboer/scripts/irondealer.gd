extends Node3D

func _ready() -> void:
	$Area3D.entered.connect(_on_body_entered)
func _on_body_entered():
	Gamestate.BEF += Gamestate.cargo * randi_range(40,80)
	$"../UI/Values".update_currency()
	Gamestate.cargo = 0
	$"../UI/Values".update_cargo()
