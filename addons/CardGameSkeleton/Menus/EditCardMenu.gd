@tool
extends MarginContainer

@export var field_scene: PackedScene
@export var fields_container: VBoxContainer
@export var card_library: CardLibrary
@export var card_scene: PackedScene # Needed to re-save the scene file

# References to buttons
@onready var update_button = $EditCardMenuVBox/UpdateCard # Ensure naming matches your scene
@onready var delete_button = $EditCardMenuVBox/DeleteCard # Ensure naming matches your scene
@onready var back_button = $EditCardMenuVBox/LastMenu
@onready var card_art_preview: TextureRect = $EditCardMenuVBox/CardArtPreview

var current_card_name: String = ""


func _ready() -> void:
	update_button.pressed.connect(_on_update_pressed)
	delete_button.pressed.connect(_on_delete_pressed)


func load_card_for_editing(card_name: String) -> void:
	current_card_name = card_name
	
	# Build the form
	_populate_empty_fields()
	
	# Fetch existing data
	var data = card_library.get_json_dict()
	if not data.has(card_name):
		print("Error: Card data not found for " + card_name)
		return
		
	var card_data = data[card_name]
	
	# Fill the form
	for field in fields_container.get_children():
		if field.has_method("get_attribute_name") and field.has_method("set_value"):
			var attr_name = field.get_attribute_name()
			# Special case for Name if it's stored differently
			if attr_name == "Card Name":
				field.set_value(card_name)
			elif card_data.has(attr_name):
				field.set_value(card_data[attr_name])
	
	var final_texture = preload("res://icon.svg") # Default Fallback
	var found_image = false
	
	# Check the directory for an image with the card's name
	# Need the root path from settings, default to "res://Cards/"
	var root_path = "res://Cards/"
	if card_library.settings_resource and card_library.settings_resource.card_root_directory != "":
		root_path = card_library.settings_resource.card_root_directory
		
	# Check common image extensions
	var extensions = ["png", "jpg", "jpeg", "svg", "webp"]
	for ext in extensions:
		# e.g. "res://Cards/Goblin/Goblin.png"
		var test_path = root_path + card_name + "/" + card_name + "." + ext
		if ResourceLoader.exists(test_path):
			final_texture = load(test_path)
			found_image = true
			break
	
	# If no local file found, check the "Card Face" attribute
	if not found_image:
		var art_path = ""
		if card_data.has("Card Face"):
			art_path = card_data["Card Face"]
		elif card_data.has("Card Face Path"):
			art_path = card_data["Card Face Path"]
			
		if art_path != "" and ResourceLoader.exists(art_path):
			final_texture = load(art_path)

	# Apply the texture
	if card_art_preview:
		card_art_preview.texture = final_texture


func _populate_empty_fields() -> void:
	# Clear existing
	for child in fields_container.get_children():
		child.queue_free()

	# Create fresh fields
	var attributes = card_library.get_custom_attributes()
	for attribute_data in attributes:
		if attribute_data is CardAttribute:
			var new_field = field_scene.instantiate()
			fields_container.add_child(new_field)
			new_field.setup(attribute_data)


func _on_update_pressed() -> void:
	# This logic is almost identical to SaveCard.gd
	var new_card: Card = card_scene.instantiate()
	var attribute_dict: Dictionary = {}
	
	for field in fields_container.get_children():
		if field.has_method("get_attribute_name") and field.has_method("get_value"):
			attribute_dict[field.get_attribute_name()] = field.get_value()
	
	# TODO: Handle name changes correctly rather than simply assuming a different name is a new card
	var new_name = current_card_name
	if attribute_dict.has("Card Name"):
		new_name = attribute_dict["Card Name"]
	
	new_card.card_name = new_name
	new_card.attributes = attribute_dict
	
	if new_name != current_card_name:
		card_library.delete_card(current_card_name) # Delete old file if renamed
		
	card_library.save_new_card_to_json(new_card, attribute_dict)
	card_library.save_card_scene_to_file(new_card)
	
	print("Updated card: " + new_name)
	new_card.queue_free()


func _on_delete_pressed() -> void:
	card_library.delete_card(current_card_name)
	print("Deleted card: " + current_card_name)
	back_button.pressed.emit()
