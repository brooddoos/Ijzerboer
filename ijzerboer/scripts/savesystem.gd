extends Node

const SAVE_LOCATION = "user://savefile.json"
var version = ProjectSettings.get_setting("application/config/version")
var contents_to_save = {}
var success = false

func set_list(): #modify to add or remove entries for saving
	contents_to_save = {
		"version" : version,
		"map" : Gamestate.map,
		"cargo" : Gamestate.cargo,
		"BEF" : Gamestate.BEF,
		"time" : Gamestate.time,
		"car_stats" : Gamestate.car_stats,
		"permanently_disabled_buttons" : Gamestate.permanently_disabled_buttons,
		"current_tape" : Gamestate.current_tape,
		"tapes" : Gamestate.tapes,
		"campaign" : Gamestate.campaign,
		"rally" : Gamestate.rally,
	}

func set_gamestate(): #if not added, it wont actually load it
	Gamestate.map = contents_to_save["map"]
	Gamestate.cargo = contents_to_save["cargo"]
	Gamestate.BEF = contents_to_save["BEF"]
	Gamestate.time = contents_to_save["time"]
	Gamestate.car_stats = contents_to_save["car_stats"]
	Gamestate.permanently_disabled_buttons = contents_to_save["permanently_disabled_buttons"]
	Gamestate.current_tape = contents_to_save["current_tape"]
	Gamestate.tapes = contents_to_save["tapes"]
	Gamestate.campaign = contents_to_save["campaign"]
	Gamestate.rally = contents_to_save["rally"]

func save():
	print("Saving...")
	set_list()
		
	var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.WRITE, "ijzerboersavefile")
	file.store_var(contents_to_save.duplicate())
	file.close()
	print("Saved")

func load_save():
	success = false
	if FileAccess.file_exists(SAVE_LOCATION):
		print("Savefile found!")
		var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.READ, "ijzerboersavefile")
		var data = file.get_var()
		file.close()
		
		if typeof(data) != TYPE_DICTIONARY:
			print("Savefile did not contain valid dict.")
			success = false
			return
		
		for key in contents_to_save.keys(): #checking if types are correct
			if data.has(key) and typeof(data[key]) == typeof(contents_to_save[key]):
				contents_to_save[key] = data[key]
		
		success = true
		
		set_gamestate()
		print("Succesfully loaded")
	else:
		print("No savefile found.")
		return

func _ready() -> void:
	set_list()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()
	if event.is_action_pressed("load"):
		load_save()
