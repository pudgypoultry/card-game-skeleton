@tool
extends MarginContainer

@export var field_scene: PackedScene
@export var fields_container: VBoxContainer
@export var card_library: CardLibrary

func _ready() -> void:
	if card_library:
		if not card_library.attributes_changed.is_connected(populate_fields):
			card_library.attributes_changed.connect(populate_fields)
	populate_fields()

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
	
	# Fetch settings
	if card_library.settings_resource:
		if card_library.settings_resource.card_root_directory != "":
			root_path = card_library.settings_resource.card_root_directory
		style = card_library.settings_resource.storage_style
	
	# Create fields
	for attribute_data in attributes:
		if attribute_data is CardAttribute:
			var new_field = field_scene.instantiate()
			fields_container.add_child(new_field)
			new_field.setup(attribute_data)
			
			if attribute_data.attribute_name == "Scene Location":
				var default_path = root_path
				new_field.set_value(default_path)
