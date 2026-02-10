extends Node3D


var checkpoint
var finish
var time

var tween


func allTween(transistionType:Tween.TransitionType,object,property:String,vars,time:float): #zoda we nie 10x dezelfde functie opnieuw moete schrijven
	tween = get_tree().create_tween()
	tween.set_trans(transistionType)
	tween.tween_property(object, property, vars, time)

func _ready() -> void:
	start()
func start():
	countdown()
	#time.start()


## countdown
@onready var one: Sprite2D = $UI/Countdown/One
@onready var two: Sprite2D = $UI/Countdown/Two
@onready var three: Sprite2D = $UI/Countdown/Three
@onready var go: Sprite2D = $UI/Countdown/Go
func fade_in_and_out(sprite:Sprite2D):
	sprite.show()
	sprite.self_modulate.a = 1.0
	allTween(Tween.TRANS_EXPO,sprite, "modulate:a", 0.0, 1)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	sprite.hide()

func countdown():
	$UI/Countdown/Horn.stream = load("res://assets/audio/GetSet!.wav")
	$UI/Countdown/Horn.play()
	await fade_in_and_out(three)
	$UI/Countdown/Horn.play()
	await fade_in_and_out(two)
	$UI/Countdown/Horn.play()
	await fade_in_and_out(one)
	$UI/Countdown/Horn.stream = load("res://assets/audio/go.wav")
	$UI/Countdown/Horn.play()
	await fade_in_and_out(go)
