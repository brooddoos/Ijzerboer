extends Area3D

signal entered(body: Node)
signal exited(body: Node)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body: Node):
	entered.emit()

func _on_body_exited(_body: Node):
	exited.emit()
