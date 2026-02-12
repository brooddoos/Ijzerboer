extends Node3D
@onready var cash: AudioStreamPlayer3D = $Area3D/CashSound


func _ready() -> void:
	$Area3D.entered.connect(_on_body_entered)
func _on_body_entered():
	if Gamestate.cargo > 0:
		cash.play()

	Gamestate.BEF += Gamestate.cargo * randi_range(40,80)
	$"../UI/Values".update_currency()
	Gamestate.cargo = 0
	$"../UI/Values".update_cargo()
