@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var dock_control: Node

@onready var path_input : LineEdit = $VBoxContainer/HBoxContainer2/PathInput
@onready var save_button : Button = $VBoxContainer/HBoxContainer2/SaveButton
@onready var back_button : Button = $VBoxContainer/HBoxContainer/BackButton
@onready var subfolder_checkbox : Button = $VBoxContainer/SubfolderCheckbox 
@onready var template_path_input : LineEdit = $VBoxContainer/HBoxContainer3/CustomCardPathInput
@onready var card_button_save_path : Button = $VBoxContainer/HBoxContainer3/SaveButton

func _ready() -> void:
	save_button.pressed.connect(_on_template_path_save_pressed)
	card_button_save_path.pressed.connect(_on_card_path_save_pressed)
	back_button.pressed.connect(func(): if dock_control: dock_control.show_last_menu())
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible and card_library and card_library.settings_resource:
		path_input.text = card_library.settings_resource.card_root_directory
		template_path_input.text = card_library.settings_resource.custom_card_scene_path
		
		var is_subfolder = (card_library.settings_resource.storage_style == CardProjectSettings.StorageStyle.SUBFOLDER)
		subfolder_checkbox.button_pressed = is_subfolder


func _on_template_path_save_pressed() -> void:
	if not card_library or not card_library.settings_resource:
		print("Error: Library or Settings Resource missing.")
		return
		
	var new_path = path_input.text.strip_edges()
	if not new_path.ends_with("/"):
		new_path += "/"
		path_input.text = new_path
	card_library.settings_resource.card_root_directory = new_path
	
	if subfolder_checkbox.button_pressed:
		card_library.settings_resource.storage_style = CardProjectSettings.StorageStyle.SUBFOLDER
	else:
		card_library.settings_resource.storage_style = CardProjectSettings.StorageStyle.FLAT
	
	var err = ResourceSaver.save(card_library.settings_resource, card_library.settings_resource.resource_path)
	if err == OK:
		print("Settings Saved: Path='" + new_path + "', Subfolders=" + str(subfolder_checkbox.button_pressed))
	else:
		print("Error saving settings: ", err)


func _on_card_path_save_pressed() -> void:
	var new_path = path_input.text.strip_edges()
	if not new_path.ends_with("/"):
		new_path += "/"
		path_input.text = new_path
	card_library.settings_resource.card_root_directory = new_path
	
	if subfolder_checkbox and subfolder_checkbox.button_pressed:
		card_library.settings_resource.storage_style = CardProjectSettings.StorageStyle.SUBFOLDER
	else:
		card_library.settings_resource.storage_style = CardProjectSettings.StorageStyle.FLAT
		
	var t_path = template_path_input.text.strip_edges()
	card_library.settings_resource.custom_card_scene_path = t_path
	
	var err = ResourceSaver.save(card_library.settings_resource, card_library.settings_resource.resource_path)
	if err == OK:
		print("Settings Saved!")
	else:
		print("Error saving settings: ", err)
