extends Control
func _ready():
	update_cargo()
	update_currency()
func update_cargo():
	$Cargo.text = str(Gamestate.cargo) + " / " + str(Gamestate.car_stats["cargo"]) + " KG"
func update_currency():
	$Currency.text = str(Gamestate.BEF) + " BEF"
