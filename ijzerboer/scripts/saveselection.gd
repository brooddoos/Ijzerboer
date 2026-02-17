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
	
	if FileAccess.file_exists("user://savefile.json") and save_file_existence == [false, false, false]: # check if old savefiles exist and user hasnt created new ones
		print("Pre v0.4.1 savefile detected: converting")
		Savesystem.force_old = true
		Savesystem.load_save(false) # load from old save without applying to gamestate
		Savesystem.delete_save() # delete old saave
		Savesystem.force_old = false
		Savesystem.save()
	
	label_setter("load")

func handle_save_slot(saveslot):
	var index = saveslot-1
	slot = saveslot #used for cross function features
	if file_mode == "load":
		Savesystem.current_used_slot = saveslot
		if save_file_existence[index]:
			Savesystem.load_save()
		else: # no savefile, create new
			Savesystem.contents_to_save = Savesystem.DEFAULT_CONTENTS_TO_SAVE.duplicate(true) # to prevent default values from being modified
			Savesystem.save(false)
			Savesystem.load_save()
		
		await Transition.fade_out()
		get_tree().change_scene_to_file("res://scenes/game/Campaign.tscn")
		await Transition.fade_in()
		Savesystem.save() #for integrity purposes
	elif file_mode == "delete":
		delete_confirm.dialog_text = "Are you sure you want to delete the save file in slot " + str(saveslot) + "?"
		delete_confirm.popup_centered()
		#rest of delete logic handled by _on_delete_confirm_confirmed()
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
		
		for i in save_file_existence.size(): # NOTE: .size() is way better for loops
			buttons[i].text = "Slot " + str(i + 1) if save_file_existence[i] else "Empty"
			buttons[i].get_node("LastSaved").visible = save_file_existence[i]
			buttons[i].get_node("Version").visible = save_file_existence[i]
			buttons[i].disabled = false
			
			if save_file_existence[i]:
				var info = Savesystem.get_save_info(i + 1)
				buttons[i].get_node("Version").text = "v" + info["version"]
				buttons[i].get_node("LastSaved").text = "Last saved:\n" + info["last_saved"]
		
	elif mode in ["delete","copy","paste"]:
		advice.show()
		for i in save_file_existence.size():
			if mode == "paste":
				buttons[i].disabled = save_file_existence[i]
			else:
				buttons[i].disabled = not save_file_existence[i]
		
		file_mode = mode.to_lower()
		
		if mode == "delete":
			title.text = "Delete save file:"
			advice.text = "Choose which savefile to delete, press the delete button to return to normal."
			
		elif mode == "copy":
			title.text = "Copy save file:"
			advice.text = "Choose which savefile to copy, press the copy button to return to normal"
				
		elif mode == "paste":
			title.text = "Paste save file:"
			advice.text = "Choose the savefile to paste to, press copy button to return to normal."

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
			if file_mode == "copy" or file_mode == "paste":
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
