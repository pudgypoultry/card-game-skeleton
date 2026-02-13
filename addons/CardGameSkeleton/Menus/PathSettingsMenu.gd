@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var dock_control: Node

@onready var path_input: LineEdit = $VBoxContainer/HBoxContainer2/PathInput
@onready var save_button: Button = $VBoxContainer/HBoxContainer2/SaveButton
@onready var back_button: Button = $VBoxContainer/HBoxContainer/BackButton

func _ready() -> void:
	save_button.pressed.connect(_on_save_pressed)
	back_button.pressed.connect(func(): if dock_control: dock_control.show_last_menu())
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible and card_library and card_library.settings_resource:
		path_input.text = card_library.settings_resource.card_root_directory

func _on_save_pressed() -> void:
	if not card_library or not card_library.settings_resource:
		print("Error: Library or Settings Resource missing.")
		return
		
	var new_path = path_input.text
	if not new_path.ends_with("/"):
		new_path += "/"
		path_input.text = new_path
		
	card_library.settings_resource.card_root_directory = new_path
	
	# Save the resource to disk
	ResourceSaver.save(card_library.settings_resource, card_library.settings_resource.resource_path)
	print("Saved Root Path: " + new_path)
