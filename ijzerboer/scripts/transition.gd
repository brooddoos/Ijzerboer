extends CanvasLayer
@onready var fade: AnimationPlayer = $Mask/Fade

var busy := false
var current_scene := ""

signal fade_out_finished
signal fade_in_finished

func _ready() -> void:
	current_scene = get_tree().get_current_scene().get_name()

func fade_in():
	fade.play("FadeIn")
	await fade_in_finished
	busy = false

func fade_out() -> void:
	if busy:
		return
	busy = true
	fade.play("FadeOut")
	await fade_out_finished

func _on_fade_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		fade_out_finished.emit()
	elif anim_name == "FadeIn":
		fade_in_finished.emit()
