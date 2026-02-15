extends Control
var paused := false
var inTransition := false
var tween

var ogLen:int
var customSongs:Dictionary = {}
 
func _ready() -> void:
	$ColorRect/VBoxContainer/Settings.pressed.connect(_on_settings_pressed)
	await Engine.get_main_loop().process_frame
	if Gamestate.last_scene == "res://scenes/Settings.tscn":
		toggle_menu()

func show_info(msg: String, title: String = "Info"):
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = msg
	dialog.force_native = true
	add_child(dialog)
	dialog.popup_centered()

func allTween(transistionType:Tween.TransitionType,object,property:String,vars,time:float): #zoda we nie 10x dezelfde functie opnieuw moete schrijven
	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(transistionType)
	tween.tween_property(object, property, vars, time)

func toggle_menu():
	if not inTransition:
		inTransition = true
		if not paused:
			paused = true
			get_tree().paused = true
			show()
			
			allTween(Tween.TRANS_EXPO,$".","position:y",0,0.25)
			await tween.finished
			tween.kill()
			inTransition = false
		else:
			allTween(Tween.TRANS_EXPO,$".","position:y",730,0.25)
			await tween.finished
			inTransition = false
			tween.kill()
			
			paused = false
			get_tree().paused = false
			hide()

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		toggle_menu()

func _on_button_pressed() -> void: #exit
	Savesystem.save()
	await Transition.fade_out()
	var mainmenu = load("res://scenes/start/Start.tscn") as PackedScene
	get_tree().paused = false
	get_tree().change_scene_to_packed(mainmenu)
	await Transition.fade_in()

func _on_settings_pressed():
	await Transition.fade_out()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start/Options.tscn")
	await Transition.fade_in()

func _on_resume_pressed() -> void:
	allTween(Tween.TRANS_EXPO,$".","position:y",730,0.25)
	await tween.finished
	inTransition = false
	tween.kill()
	
	paused = false
	get_tree().paused = false
	hide()
