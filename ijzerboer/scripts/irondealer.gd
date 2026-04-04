extends Node3D
@onready var cash: AudioStreamPlayer3D = $Area3D/CashSound


func _ready() -> void:
	$Area3D.entered.connect(_on_body_entered)
func _on_body_entered():
	if Gamestate.cargo > 0:
		cash.play()
		
		var price = randi_range(40,80)
		
		if not Dialog.already_in_dialog:
			Dialog.dialog_name = "Hobo Employee"
			Dialog.show_dialog("Wow, thanks for the " + str(Gamestate.cargo) + " kg of scrap metal! At the current rate of " + str(price) + " BEF per kilogram, you'll receive " + str(Gamestate.cargo * price) + " BEF!")			
		
		Gamestate.BEF += Gamestate.cargo * price
		$"../UI/Control/Values".update_currency()
		Gamestate.cargo = 0
		$"../UI/Control/Values".update_cargo()
