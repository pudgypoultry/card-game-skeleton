@tool
extends MarginContainer

@export var field_scene: PackedScene
@export var fields_container: VBoxContainer
@export var card_library: CardLibrary
@export var card_scene: PackedScene

# References to buttons
@onready var update_button = $EditCardMenuVBox/UpdateCard
@onready var delete_button = $EditCardMenuVBox/DeleteCard
@onready var back_button = $EditCardMenuVBox/LastMenu
@onready var card_art_preview: TextureRect = $EditCardMenuVBox/CardArtPreview
@onready var delete_confirm_dialog: ConfirmationDialog = $EditCardMenuVBox/DeleteConfirmDialog
@onready var last_menu_button = $EditCardMenuVBox/LastMenu

var current_card_name: String = ""
var name_input : LineEdit
var path_input : LineEdit
var card_name_to_delete: String = ""

func _ready() -> void:
	update_button.pressed.connect(_on_update_pressed)
	#delete_button.pressed.connect(_on_delete_pressed)
	delete_button.pressed.connect(_on_delete_button_clicked)
	delete_confirm_dialog.confirmed.connect(_on_deletion_confirmed)


func load_card_for_editing(card_name: String) -> void:
	current_card_name = card_name
	
	populate_fields()
	
	var data = card_library.get_json_dict(card_library.json_card_file_path)
	if not data.has(card_name):
		print("Error: Card data not found for " + card_name)
		return
		
	var card_data = data[card_name]
	
	for field in fields_container.get_children():
		if field.has_method("get_attribute_name") and field.has_method("set_value"):
			var attr_name = field.get_attribute_name()
			if attr_name == "Card Name":
				field.set_value(card_name)
			elif card_data.has(attr_name):
				field.set_value(card_data[attr_name])
	
	var final_texture = preload("res://icon.svg")
	var found_image = false
	
	var root_path = "res://Cards/"
	if card_library.settings_resource and card_library.settings_resource.card_root_directory != "":
		root_path = card_library.settings_resource.card_root_directory
		
	var extensions = ["png", "jpg", "jpeg", "svg", "webp"]
	for ext in extensions:
		var test_path = root_path + card_name + "/" + card_name + "." + ext
		if ResourceLoader.exists(test_path):
			final_texture = load(test_path)
			found_image = true
			break
	
	if not found_image:
		var art_path = ""
		if card_data.has("Front Face Location"):
			art_path = card_data["Front Face Location"]
			
		if art_path != "" and ResourceLoader.exists(art_path):
			final_texture = load(art_path)
	
	if card_art_preview:
		card_art_preview.texture = final_texture
	

# Generates the input forms based on the ProjectAttributes resource
func populate_fields() -> void:
	if not field_scene or not fields_container or not card_library:
		return

	# Clear existing fields
	for child in fields_container.get_children():
		child.queue_free()

	# Get attributes
	var attributes = card_library.get_custom_attributes()
	var root_path = "res://Cards/"
	var style = CardProjectSettings.StorageStyle.SUBFOLDER
	
	if card_library.settings_resource:
		if card_library.settings_resource.card_root_directory != "":
			root_path = card_library.settings_resource.card_root_directory
		style = card_library.settings_resource.storage_style
	
	for attribute_data in attributes:
		if attribute_data is CardAttribute:
			var new_field = field_scene.instantiate()
			fields_container.add_child(new_field)
			new_field.setup(attribute_data)
			if attribute_data.attribute_name == "Card Name":
				var default_path = root_path
				if new_field.input_control is LineEdit:
					name_input = new_field.input_control
					name_input.text_changed.connect(_update_path_preview)
					_update_path_preview("")
			
			if attribute_data.attribute_name == "Scene Location":
				var default_path = root_path
				if new_field.input_control is LineEdit:
					new_field.set_value(default_path)
					path_input = new_field.input_control
	


func _on_update_pressed() -> void:
	var new_card: Card = card_scene.instantiate()
	var attribute_dict: Dictionary = {}
	
	for field in fields_container.get_children():
		if field.has_method("get_attribute_name") and field.has_method("get_value"):
			attribute_dict[field.get_attribute_name()] = field.get_value()
	
	var new_name = current_card_name
	if attribute_dict.has("Card Name"):
		new_name = attribute_dict["Card Name"]
	
	new_card.card_name = new_name
	new_card.attributes = attribute_dict
	
	if new_name != current_card_name:
		card_library.delete_card(current_card_name)
	
	card_library.save_new_card_to_json(new_card, attribute_dict)
	card_library.save_card_scene_to_file(new_card)
	
	print("Updated card: " + new_name)
	new_card.queue_free()


func _on_delete_pressed() -> void:
	card_library.delete_card(current_card_name)
	print("Deleted card: " + current_card_name)
	back_button.pressed.emit()


func _update_path_preview(new_name: String) -> void:
	if not card_library or not path_input:
		return
	
	var settings = card_library.settings_resource
	
	var root_dir = "res://Cards/"
	var use_subfolders = true
	
	if settings:
		if settings.card_root_directory != "":
			root_dir = settings.card_root_directory
		
		use_subfolders = (settings.storage_style == CardProjectSettings.StorageStyle.SUBFOLDER)
	
	var final_path = root_dir
	var clean_name = new_name.strip_edges()
	if use_subfolders:
		if clean_name != "":
			final_path = root_dir + clean_name + "/"
	else:
		if clean_name != "":
			final_path = root_dir
	
	path_input.text = final_path


func _on_delete_button_clicked() -> void:
	delete_confirm_dialog.popup_centered()


func _on_deletion_confirmed() -> void:
	card_name_to_delete = name_input.text
	if not card_library or card_name_to_delete == "":
		return
	card_library.delete_card(card_name_to_delete)
	_on_delete_pressed()
