extends Control

## WARNING: THIS HAS TO BE SOME OF THE *WORST* CODE IVE EVER WRITTEN, BUT IT WORKS FOR NOW
### tldr: do not touch anything

@onready var buttons = [ #kobe kneem uwe approach, tevrede lmao
	$VBox/Saves/Save1, 
	$VBox/Saves/Save2, 
	$VBox/Saves/Save3, 
	$VBox/Options/Delete, 
	$VBox/Options/Copy, 
]
@onready var return_button: Button = $VBox/Options/Return
@onready var title: Label = $VBox/Title
@onready var advice: Label = $VBox/Advice
@onready var delete_confirm: ConfirmationDialog = $DeleteConfirm

var file_mode = "load"
var slot = 0

var save_file_existence = []

func refresh_file_existence():
	save_file_existence = [
		FileAccess.file_exists(Savesystem.SAVE_LOCATION + "slot1.json"),
		FileAccess.file_exists(Savesystem.SAVE_LOCATION + "slot2.json"),
		FileAccess.file_exists(Savesystem.SAVE_LOCATION + "slot3.json")
	]

func _ready() -> void:
	refresh_file_existence()
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	return_button.pressed.connect(_on_exit_pressed)
	
	if FileAccess.file_exists("user://savefile.json") and save_file_existence == [false, false, false]:
		print("youre broke get a j asterisk b")
		Savesystem.force_old = true
		Savesystem.load_save(false)
		Savesystem.delete_save()
		Savesystem.force_old = false
		Savesystem.save()

	label_setter("load")

func handle_save_slot(saveslot):
	var index = saveslot-1
	slot = saveslot
	if file_mode == "load":
		Savesystem.current_used_slot = saveslot
		if save_file_existence[index]:
			Savesystem.load_save()
		await Transition.fade_out()
		get_tree().change_scene_to_file("res://scenes/game/Campaign.tscn")
		await Transition.fade_in()
		Savesystem.save()
	elif file_mode == "delete":
		delete_confirm.dialog_text = "Are you sure you want to delete the save file in slot " + str(saveslot) + "?"
		delete_confirm.popup_centered()
		label_setter("load")
	elif file_mode == "copy":
		slot = saveslot
		label_setter("paste")
	elif file_mode == "paste":
		Savesystem.current_used_slot = slot
		Savesystem.load_save(false)
		Savesystem.current_used_slot = saveslot
		await Savesystem.save()
		label_setter("load")

func label_setter(mode):
	if mode == "load":
		refresh_file_existence()
		file_mode = "load"
		title.text = "Choose save file:"
		advice.hide()
		
		for i in range(len(save_file_existence)):
			buttons[i].text = "Slot " + str(i + 1) if save_file_existence[i] else "Empty"
			buttons[i].get_node("LastSaved").visible = save_file_existence[i]
			buttons[i].get_node("Version").visible = save_file_existence[i]
			buttons[i].disabled = false
			
			if save_file_existence[i]:
				Savesystem.current_used_slot = i + 1
				Savesystem.load_save(false)
				
				buttons[i].get_node("Version").text = "v" + Savesystem.contents_to_save["version"]
				buttons[i].get_node("LastSaved").text = "Last saved:\n" + Savesystem.contents_to_save["last_saved"]
		
	elif mode in ["delete","copy","paste"]:
		advice.show()
		for i in range(len(save_file_existence)):
			if mode == "paste":
				buttons[i].disabled = save_file_existence[i]
			else:
				buttons[i].disabled = not save_file_existence[i]
		
		file_mode = mode.to_lower()
		
		if mode == "delete":
			title.text = "Delete save file:"
			advice.text = "Press a savefile to delete it, press delete button to return to default."
			
		elif mode == "copy":
			title.text = "Copy save file:"
			advice.text = "Press a savefile slot then another to one to copy, press copy button to return to default."
				
		elif mode == "paste":
			title.text = "Paste save file:"
			advice.text = "Press the savefile to paste to, press copy button to return to default."

func _on_button_pressed(button):
	if button.name.begins_with("Save"):
		var saveslot := int(button.name.trim_prefix("Save"))
		handle_save_slot(saveslot)
		return
	
	match button.name:
		"Delete":
			if file_mode == "delete":
				label_setter("load")
			else:
				label_setter("delete")
		"Copy":
			if file_mode == "copy":
				label_setter("load")
			else:
				label_setter("copy")
			
func _on_exit_pressed():
	var old = Gamestate.last_scene
	await Transition.fade_out()
	get_tree().change_scene_to_file(old)
	await Transition.fade_in()

func _on_delete_confirm_confirmed() -> void:
	Savesystem.current_used_slot = slot
	Savesystem.delete_save()
	label_setter("load")
