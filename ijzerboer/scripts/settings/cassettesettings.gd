extends Node
@onready var contents: VBoxContainer = $contents
@onready var unspported: Label = $Unspported
@onready var ingame: Label = $Ingame

var ogLen:int
var customSongs = []

func _ready() -> void:
	if OS.has_feature("web"):
		contents.visible = false
		ingame.visible = false
		unspported.visible = true
	else:
		contents.visible = Savesystem.ingame
		ingame.visible = not Savesystem.ingame
		unspported.visible = false
	
	ogLen = 0
	for tape in Gamestate.tapes:
		if "default" in tape:
			ogLen += 1

func show_info(msg: String, title: String = "Info"):
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = msg
	dialog.force_native = true
	add_child(dialog)
	dialog.popup_centered()
	
func _on_load_pressed() -> void:
	$FileDialog.popup_centered()

func _on_clear_pressed() -> void:
	if not ogLen == len(Gamestate.tapes):
		Gamestate.tapes = Gamestate.tapes.slice(0, ogLen)
		customSongs.clear()
			
		show_info("Successfully cleared all custom songs.", "Cleared")
	else:
		show_info("You didn't add any custom songs, so uhh.", "No songs")

func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	var addQueue = []
	for path in paths:
		var title: String = path.get_file().get_basename()
		if title.contains(" - "):
			title = title.replace(" - ", "\nBy: ")
		addQueue.append({"title": title, "file": path})
	Gamestate.tapes += addQueue
	customSongs += addQueue
	
	var msg = "Succesfully added "+str(len(addQueue))+" songs to playlist!\nAdded:"
	
	for song in addQueue: 
		msg += "\n- - -\n" + song["title"]
	show_info(msg, "Success")
