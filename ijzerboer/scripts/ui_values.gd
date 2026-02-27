extends Control
var max_cargo = Gamestate.car_upgrades["cargo"] * 5
func _ready():
	update_cargo()
	update_currency()
func update_cargo():
	$Cargo.text = str(Gamestate.cargo) + " / " + str(max_cargo) + " KG"
func update_currency():
	$Currency.text = str(Gamestate.BEF) + " BEF"
