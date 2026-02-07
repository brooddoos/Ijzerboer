extends CanvasLayer
@onready var fade: AnimationPlayer = $Mask/Fade
@onready var mask: ColorRect = $Mask

var busy := false
var current_scene := ""
const DEFAULT_MASK := preload("res://assets/images/ui/transition/transition.png")

signal fade_out_finished
signal fade_in_finished

func _ready() -> void:
	current_scene = get_tree().get_current_scene().get_name()

func fade_in(custom_mask = ""):
	if custom_mask != "" and ResourceLoader.exists(custom_mask): #vr int geval als we weer alle files herorganiseren
		mask.material.set_shader_parameter('mask',load(custom_mask))
	else:
		mask.material.set_shader_parameter('mask',DEFAULT_MASK)
	
	get_tree().paused = false
	fade.play("FadeIn")
	await fade_in_finished
	busy = false

func fade_out(custom_mask = "") -> void:
	if busy:
		return
	busy = true
	
	var scene_path = get_tree().current_scene.scene_file_path
	Gamestate.last_scene = scene_path
	
	if custom_mask != "" and ResourceLoader.exists(custom_mask): #vr int geval als we weer alle files herorganiseren
		mask.material.set_shader_parameter('mask',load(custom_mask))
	else:
		mask.material.set_shader_parameter('mask',DEFAULT_MASK)
	
	fade.play("FadeOut")
	await fade_out_finished

func _on_fade_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		fade_out_finished.emit()
	elif anim_name == "FadeIn":
		fade_in_finished.emit()
