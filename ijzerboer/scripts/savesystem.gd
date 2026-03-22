extends Node
@onready var appear_timer: Timer = $appearTimer
@onready var autosave_timer: Timer = $autosaveTimer
@onready var icon: TextureRect = $CanvasLayer/icon

var version = ProjectSettings.get_setting("application/config/version")
var contents_to_save = {}
var success = false
var DEFAULT_CONTENTS_TO_SAVE = {}

const SAVE_LOCATION = "user://savefiles/"
var force_old = false
var current_used_slot = 1
var autosave_interval = 60 # in seconds

const SETTINGS_LOCATION = "user://settings.json"

var ingame = false

var autosave_enabled_scenes = [
	"res://scenes/game/Campaign.tscn",
	"res://scenes/game/Rally.tscn"]

var settings = {
	"volume_sfx": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX")), #audio settings
	"volume_music": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("BGM")),
	"volume_car": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Car")),
	"volume_map": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Map")),
	
	"vsync": true, # video settings
	"fullscreen": false,
	"max_fps": 0,
}

var DEFAULT_SETTINGS = {}

func _ready() -> void:
	set_list()
	DEFAULT_CONTENTS_TO_SAVE = contents_to_save.duplicate(true) #I HATE YOU GODOT DICTS WHY WOULD NORMAL ASSIGNMENT NOT JUST DUPLICATE
	autosave_timer.wait_time = autosave_interval
	get_tree().scene_changed.connect(_on_scene_changed)
	icon.hide()
	if get_tree().current_scene.scene_file_path in autosave_enabled_scenes:
		autosave_timer.start()
	
	DirAccess.make_dir_recursive_absolute(SAVE_LOCATION)
	appear_timer.timeout.connect(icon.hide)
	autosave_timer.timeout.connect(save)
	
	DEFAULT_SETTINGS = settings.duplicate(true) # before loading
	load_settings()
	apply_settings()

func _process(delta: float) -> void:
	if icon.visible:
		icon.rotation += delta*5

func _on_scene_changed():
	if get_tree().current_scene.scene_file_path in autosave_enabled_scenes:
		autosave_timer.start()
	else:
		autosave_timer.stop()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()

# settings n stuff
func apply_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(settings.volume_sfx))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(settings.volume_music))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Car"), linear_to_db(settings.volume_car))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Map"), linear_to_db(settings.volume_map))

	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED)

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED) # this is extremely unreadable, but fuck it we ball

	Engine.max_fps = settings.max_fps

func save_settings():
	var file = FileAccess.open_encrypted_with_pass(SETTINGS_LOCATION, FileAccess.WRITE, "ijzerboersettings")
	file.store_var(settings)
	file.close()
	print("Settings saved")

func load_settings():
	if FileAccess.file_exists(SETTINGS_LOCATION):
		var file = FileAccess.open_encrypted_with_pass(SETTINGS_LOCATION, FileAccess.READ, "ijzerboersettings")
		var data = file.get_var()
		file.close()

		if typeof(data) == TYPE_DICTIONARY:
			for key in settings.keys():
				if data.has(key) and typeof(data[key]) == typeof(settings[key]):
					settings[key] = data[key]
		print("Settings loaded")
	else:
		settings = DEFAULT_SETTINGS.duplicate(true)
		save_settings()

# gameplay saving
func set_list(): #updates contents_to_save
	var current_date = Time.get_date_string_from_system() # Output: "2024-05-20"
	var current_time = Time.get_time_string_from_system() # Output: "14:30:05"
	
	contents_to_save = {
		"version" : version,
		"last_saved" : current_date + " at " + current_time,
		"map" : Gamestate.map,
		"cargo" : Gamestate.cargo,
		"BEF" : Gamestate.BEF,
		"time" : Gamestate.time,
		"car_upgrades" : Gamestate.car_upgrades,
		"current_tape" : Gamestate.current_tape,
		"timestamp" : Gamestate.timestamp,
		"tapes" : Gamestate.tapes,
		"campaign" : Gamestate.campaign,
		"rally" : Gamestate.rally,
	}

func set_gamestate():
	for content in contents_to_save:
		Gamestate.set(content, contents_to_save[content])

func save(refresh_data:bool = true):
	var used_save_location = get_save_path()
	
	appear_timer.start()
	print("Saving...")
	icon.show()
	
	if refresh_data:
		set_list()
		
	var file = FileAccess.open_encrypted_with_pass(used_save_location, FileAccess.WRITE, "ijzerboersavefile")
	file.store_var(contents_to_save.duplicate())
	file.close()
	await appear_timer.timeout
	print("Saved")

func load_save(setgamestate:bool = true):
	success = false
	var used_save_location = get_save_path()
	if FileAccess.file_exists(used_save_location):
		print("Savefile found!")
		var file = FileAccess.open_encrypted_with_pass(used_save_location, FileAccess.READ, "ijzerboersavefile")
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
		
		if setgamestate:
			set_gamestate()
		print("Succesfully loaded")
	else:
		print("No savefile found.")
		return

func delete_save():
	success = false
	var used_save_location = get_save_path()
	if FileAccess.file_exists(used_save_location):
		DirAccess.remove_absolute(used_save_location)
		print("Deleted")
	else:
		print("No savefile found.")
		return

func get_save_info(slot:int): # because its probably a good idea to not reload entire saves
	var path = SAVE_LOCATION + "slot" + str(slot) + ".json"
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, "ijzerboersavefile")
	var data = file.get_var()
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		return {}

	return {"version": data.get("version", "unknown"),"last_saved": data.get("last_saved", "unknown")}

func get_save_path(slot = current_used_slot) -> String:
	if force_old:
		return "user://savefile.json"
	return SAVE_LOCATION + "slot" + str(slot) + ".json"
