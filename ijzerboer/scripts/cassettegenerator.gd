#t maakt me geen schijt uit dat dit hella inefficent is, it works so dont touch it
extends Control
signal newTape
@onready var cassette1: Node3D = $SubViewportContainer/SubViewport/Node3D/cassettelowpoly
@onready var cassette2: Node3D = $SubViewportContainer/SubViewport/Node3D/Cassette

@export var generatedTapes:Dictionary = { #gvd er is geen betere manier, gl future me frfr 🙏🙏
	"ost1": { "title": "Ijzerman music\nVOLUME 1", "type" : 1 , "speed" : 2, "rotateright" : true, },
	"ost2": { "title": "insert very original song title", "type" : 2 , "speed" : 2, "rotateright" : true, },
}

const TAPETEMPLATE := {	"template": { "title": "if you see this then\nthegamebroke", "type" : 1 , "speed" : 2, "rotateright" : true, },}
#you HVAE to respect this template or the cassettes will die

var index:int = 0
var currentTape = {}
var tape_keys := []

func _ready() -> void:
	if "template" in generatedTapes:
		generatedTapes.erase("template")
	tape_keys = generatedTapes.keys()
	currentTape = generatedTapes[tape_keys[index]]
	emit_signal("newTape", currentTape)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			index = (index + 1) % tape_keys.size()
			currentTape = generatedTapes[tape_keys[index]]
			emit_signal("newTape", currentTape)
