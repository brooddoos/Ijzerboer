extends Node3D
@onready var cash_sfx: AudioStreamPlayer3D = $Area3D/cash_sfx


func _ready() -> void:
	$Area3D.entered.connect(_on_body_entered)
func _on_body_entered():
	if Gamestate.cargo > 0:
		cash_sfx.play()

	Gamestate.BEF += Gamestate.cargo * randi_range(40,80)
	$"../UI/Values".update_currency()
	Gamestate.cargo = 0
	$"../UI/Values".update_cargo()
