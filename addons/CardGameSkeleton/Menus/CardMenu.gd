@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var grid_container: GridContainer
@export var edit_menu: Control 
@export var dock_control: Node


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		populate_grid()


func _on_visibility_changed() -> void:
	if visible:
		populate_grid()


func populate_grid() -> void:
	if not card_library or not grid_container:
		return
	
	for child in grid_container.get_children():
		if child.name == "BackToMainMenu": 
			continue
		child.queue_free()
	
	# Fetch data
	var data = card_library.get_json_dict()
	if not data or data.is_empty(): 
		return
		
	var card_names = data.keys()
	card_names.sort()
	
	# Try to get user's root path
	var root_path = "res://Cards/"
	if card_library.settings_resource and card_library.settings_resource.card_root_directory != "":
		root_path = card_library.settings_resource.card_root_directory
	
	# Generate buttons
	for card_name in card_names:
		var card_info = data[card_name]
		var btn = Button.new()
		
		btn.text = card_name
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.custom_minimum_size = Vector2(120, 160)
		btn.expand_icon = true
		btn.clip_text = true
		
		var final_icon = preload("res://icon.svg") # Default Fallback
		var found_image = false
		
		var art_path = ""
		if card_info.has("Front Face Location"):
			art_path = card_info["Front Face Location"]
		
		if art_path != "" and ResourceLoader.exists(art_path):
			final_icon = load(art_path)
			found_image = true
		
		if not found_image:
			var extensions = ["png", "jpg", "jpeg", "svg", "webp"]
			for ext in extensions:
				var test_path = root_path + card_name + "/" + card_name + "." + ext
				if ResourceLoader.exists(test_path):
					final_icon = load(test_path)
					found_image = true
					break
		
		btn.icon = final_icon
		
		btn.pressed.connect(_on_card_clicked.bind(card_name))
		grid_container.add_child(btn)


func _on_card_clicked(card_name: String) -> void:
	if edit_menu and dock_control:
		if edit_menu.has_method("load_card_for_editing"):
			edit_menu.load_card_for_editing(card_name)
		dock_control.show_menu(edit_menu)
