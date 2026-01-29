extends Node3D
var checkpoint
var finish
var time
func _ready() -> void:
	start()
func start():
	countdown()
	#time.start()
func countdown():
	$UI/Countdown/Three.show()
	await(get_tree().create_timer(1).timeout)
	$UI/Countdown/Three.hide()
	$UI/Countdown/Two.show()
	await(get_tree().create_timer(1).timeout)
	$UI/Countdown/Two.hide()
	$UI/Countdown/One.show()
	await(get_tree().create_timer(1).timeout)
	$UI/Countdown/One.hide()
	$UI/Countdown/Go.show()
	await(get_tree().create_timer(1).timeout)
	$UI/Countdown/Go.hide()
