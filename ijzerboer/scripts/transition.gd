extends CanvasLayer
@onready var fade: AnimationPlayer = $Mask/Fade
@onready var mask: ColorRect = $Mask
@onready var loading_message: Label = $Mask/long
@onready var loading_icon: TextureRect = $Mask/icon

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

var load_time := 0.0

func _process(delta: float) -> void:
	var text_color = loading_message.modulate
	
	if loading_icon.visible:
		loading_icon.rotation += delta*5
	else:
		loading_icon.rotation = 0
		
	if busy:
		load_time += delta
		if load_time > 3.0: #oei loading time
			loading_message.show()
			loading_icon.show()
			
			var dots := int(load_time) % 4  # very animated yes
			loading_message.text = "Loading" + ".".repeat(dots)
			
			text_color.a = min(text_color.a + delta * 2.0, 1.0) # this will NOT work bro
			loading_message.modulate = text_color
			loading_icon.modulate = text_color
	else:
		text_color.a = max(text_color.a - delta * 2.0, 0.0)
		loading_message.modulate = text_color
		loading_icon.modulate = text_color
		
		if text_color.a <= 0.1:
			loading_message.hide()
			loading_icon.hide()
		
		load_time = 0.0
