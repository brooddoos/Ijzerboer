extends Control
@onready var cassette: Control = $"../Cassette"

var paused := false
var inTransition := false
var tween

var ogLen:int
var customSongs:Dictionary = {}
 
func _ready() -> void:
	$".".position.y = 730.0
	ogLen = 0
	for tape in cassette.tapes.values():
		if tape.has("default"):
			ogLen += 1

	hide()
	
	if OS.has_feature("web"): #eh wrm zoude we t op web late alst toch nie supported is
		$ColorRect/VBoxContainer/music.hide()
		$ColorRect/VBoxContainer/clear.hide()

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

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
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

func _on_button_pressed() -> void:
	await Transition.fade_out()
	var mainmenu = load("res://scenes/Menu.tscn") as PackedScene
	get_tree().paused = false
	get_tree().change_scene_to_packed(mainmenu)
	await Transition.fade_in()

func _on_music_pressed() -> void:
	if OS.has_feature("web"):
		OS.alert("This feature is not and probably will never be supported on Web. Please download a Windows or Linux build to use this feature. Also, you're not supposed to be here? How did you manage to get this message?", "Error")
		return
	$FileDialog.popup_centered()

func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	var current_length = len(cassette.tapes)
	var addQueue = {}
	for i in range(len(paths)):
		var title:String = paths[i-1].get_file().get_basename()
		if title.contains(" - "):
			title = title.replace(" - ","\nBy: ")
		addQueue[current_length+i+1] = { "title": title, "file":paths[i-1]}
	cassette.tapes.merge(addQueue)
	customSongs.merge(addQueue)
	
	var msg = "Succesfully added "+str(len(addQueue))+" songs to playlist!\nAdded:"
	
	for i in addQueue:
		msg += "\n- - -\n" + addQueue[i]["title"]
	show_info(msg, "Success")
	

func _on_clear_pressed() -> void:
	if not ogLen == len(cassette.tapes):
		var keys_to_remove := []
		for key in cassette.tapes.keys():
			if key > ogLen:
				keys_to_remove.append(key)
		for key in keys_to_remove:
			cassette.tapes.erase(key)
		
		show_info("Successfully cleared all custom songs.", "Cleared")
	else:
		show_info("You gotta add some songs before clearing 'em.", "No songs")


func _on_resume_pressed() -> void:
	allTween(Tween.TRANS_EXPO,$".","position:y",730,0.25)
	await tween.finished
	inTransition = false
	tween.kill()
	
	paused = false
	get_tree().paused = false
	hide()
