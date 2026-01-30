extends Node3D

@onready var one: Sprite2D = $UI/Countdown/One
@onready var two: Sprite2D = $UI/Countdown/Two
@onready var three: Sprite2D = $UI/Countdown/Three
@onready var go: Sprite2D = $UI/Countdown/Go

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
	
func fade_in_and_out(sprite:Sprite2D,time:float):
	sprite.show()
	sprite.self_modulate.a = 1.0
	allTween(Tween.TRANS_EXPO,sprite, "modulate:a", 0.0, time)
	await tween.finished
	await(get_tree().create_timer(time/3).timeout)
	sprite.hide()

func countdown():
	await fade_in_and_out(three,1.0)
	await fade_in_and_out(two,1.0)
	await fade_in_and_out(one,1.0)
	await fade_in_and_out(go,2.0)
