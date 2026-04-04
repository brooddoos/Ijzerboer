extends Control #btw ts not meant to be customizable, so only use show_dialog()

@onready var image: TextureRect = $layer/Panel/Content/Photo/Person
@onready var name_label: RichTextLabel = $layer/Panel/Content/Text/Name
@onready var dialog_label: RichTextLabel = $layer/Panel/Content/Text/Dialog
@onready var next_label: RichTextLabel = $layer/Panel/Content/Text/next
@onready var dialog_noise: AudioStreamPlayer = $dialog_noise
@onready var benny_placeholder: Node3D = $layer/Panel/Content/Photo/SubViewportContainer/SubViewport/benny_placeholder
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var photo: AspectRatioContainer = $layer/Panel/Content/Photo

signal finished_dialog

var dialog_image = 1 # path to image or image object, anything else and itll use the random stick figure
var dialog_name = "rico"
var dialog_text = "placeholder placeholder"

var speed = 1.0
var ratio = 0.0
var time = 0.0

var base_speed = 0.0
var last_visible_chars = 0

var pages = []
var current_page = 0

var already_in_dialog = false

func _ready() -> void:
	$layer.hide()

func _process(delta):
	#handle speedup
	if Input.is_key_pressed(KEY_SPACE):
		speed = base_speed * 5.0
	else:
		speed = base_speed
	
	if not anim.is_playing() and already_in_dialog:
		var total_chars = dialog_label.get_total_character_count()
		var current_chars = int(dialog_label.visible_ratio * total_chars)
		
		var extra_pause = 0.0
		if current_chars > 0:
			var last_char = dialog_label.text[current_chars - 1]
			if last_char in [".", "!", "?"]:
				extra_pause = 0.95
		
		ratio += delta * speed * (1.0 - extra_pause)
	
	#handle uhhhh press space text
	dialog_label.visible_ratio = min(ratio, 1.0) 
	if dialog_label.visible_ratio >= 1.0: #cuz godot likes to do weird things with floats
		next_label.visible = true
		time += delta
		next_label.modulate.a = 0.5 + 0.5 * sin(time)
	else:
		next_label.visible = false
		time = 0.0
	
	#handle speaking noise
	if already_in_dialog:
		var total_chars = dialog_label.get_total_character_count()
		var current_chars = int(dialog_label.visible_ratio * total_chars)
		if current_chars > last_visible_chars:
			dialog_noise.pitch_scale = randf_range(0.9,1.1)
			dialog_noise.play()
			last_visible_chars = current_chars
	
	if Input.is_key_pressed(KEY_PAGEDOWN):
		benny_placeholder.rotate_x(deg_to_rad(60)*delta)
		benny_placeholder.rotate_y(deg_to_rad(60)*delta)
		benny_placeholder.rotate_z(deg_to_rad(60)*delta)
	if Input.is_key_pressed(KEY_PAGEUP):
		benny_placeholder.rotate_x(deg_to_rad(-60)*delta)
		benny_placeholder.rotate_y(deg_to_rad(-60)*delta)
		benny_placeholder.rotate_z(deg_to_rad(-60)*delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drift"):
		if not dialog_label.visible_ratio < 1.0: #make sure dialog completed
			if current_page < pages.size()-1:
				current_page += 1
				dialog_label.text = pages[current_page]

				var char_count = dialog_label.get_total_character_count()
				base_speed = 30.0 / max(char_count, 1)

				ratio = 0.0
				dialog_label.visible_ratio = 0.0
				last_visible_chars = 0
			else:
				anim.play("up")
				already_in_dialog = false
				await anim.animation_finished
				$layer.hide()
				finished_dialog.emit()
	
	if event.is_action_pressed("skip_dialog"):
		if not anim.is_playing():
			ratio = 1.0
	if event.is_action_pressed("cashdebug") and get_tree().current_scene.name == "Dialog":
		var the_name = await text_input("Name?")
		var dialog
		if the_name.is_empty():
			dialog_name = "bert"
			dialog = "According to all known laws of aviation, there is no way that a bee should be able to fly. Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyways. Because bees don't care what humans think is impossible."
			show_dialog(dialog)
		else:
			dialog_name = the_name
			dialog = await text_input("Dialog please")
			show_dialog(dialog)

func text_to_color(text: String) -> Color: #always same color if identitical string
	var rng = RandomNumberGenerator.new()
	rng.seed = (text + str(5467457465645)).hash() # idk offset the colors ig
	
	var h = rng.randf()
	var s = rng.randf_range(0.5, 0.8)
	var v = rng.randf_range(0.8, 1.0)
	
	return Color.from_hsv(h, s, v)

func text_input(prompt = ""): #NOTE: FOR DEBUG ONLY, REMOVE PLS ON RELEASE
	var line = LineEdit.new()
	line.placeholder_text = prompt
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.position = Vector2(380, 300)
	line.custom_minimum_size = Vector2(400, 0)
	line.max_length = 0
	
	get_tree().root.add_child(line)
	line.grab_focus()
	
	var text = await line.text_submitted
	line.queue_free()
	return text

func split_dialog(text: String):
	var sentence_endings = [".", "!", "?"]
	var sentences = []
	var current = ""
	for character in text:
		current += character
		if character in sentence_endings:
			sentences.append(current.strip_edges())
			current = ""
	
	if current != "":
		sentences.append(current.strip_edges())
	
	var pages = []
	var page = ""

	#TODO: fix ths shitty loop
	for sentence in sentences: #im gonna die bro what is this
		var test = page + ("" if page == "" else " ") + sentence
		dialog_label.text = test
		
		if dialog_label.get_content_height() > dialog_label.size.y:
			if page != "":
				pages.append(page)
				page = sentence
			else:
				var words = sentence.split(" ")
				page = ""
				for word in words:
					var test_word = page + ("" if page == "" else " ") + word
					dialog_label.text = test_word
					if dialog_label.get_content_height() > dialog_label.size.y:
						pages.append(page)
						page = word
					else:
						page = test_word
		else:
			page = test

	if page != "":
		pages.append(page)
	return pages

func show_dialog(dialog:String):
	if not dialog_image:
		image.hide()
	already_in_dialog = true
	
	pages = split_dialog(dialog)
	current_page = 0
	dialog_label.text = pages[0]
	
	var char_count = dialog_label.get_total_character_count()
	var chars_per_second = 30.0
	base_speed = chars_per_second / max(char_count, 1)
	
	var used_name = dialog_name
	if not used_name.contains("[b]"):
		used_name = "[b]" + used_name
	
	name_label.text = used_name
	
	photo.show()
	if dialog_image is String:
		if dialog_image == "no photo":
			photo.hide()
		else:
			image.texture = load(dialog_image)
	elif (dialog_image is Texture2D) or (dialog_image is Resource):
		image.texture = dialog_image
	else:
		image.hide()
	
	$layer.show()
	anim.play("down")
	
	var h = $layer/Panel/Content/Photo/SubViewportContainer/SubViewport/benny_placeholder/root/Mesh.get_surface_override_material(0)
	h.albedo_color = text_to_color(dialog_name)
	
	ratio = 0.0
	dialog_label.visible_ratio = 0.0
	last_visible_chars = 0
