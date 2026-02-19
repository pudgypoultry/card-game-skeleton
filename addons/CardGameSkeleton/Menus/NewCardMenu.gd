@tool
extends MarginContainer

@export var field_scene: PackedScene
@export var fields_container: VBoxContainer
@export var card_library: CardLibrary

var name_input: LineEdit
var path_input: LineEdit


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
