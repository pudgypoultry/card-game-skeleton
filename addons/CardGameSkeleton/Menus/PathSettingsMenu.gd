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
@onready var base_script_input: LineEdit = $VBoxContainer/HBoxContainer4/BaseScriptInput
@onready var retarget_button: Button = $VBoxContainer/HBoxContainer4/RetargetButton

func _ready() -> void:
	save_button.pressed.connect(_on_template_path_save_pressed)
	card_button_save_path.pressed.connect(_on_card_path_save_pressed)
	back_button.pressed.connect(func(): if dock_control: dock_control.show_last_menu())
	visibility_changed.connect(_on_visibility_changed)
	retarget_button.pressed.connect(_on_retarget_pressed)


func _on_visibility_changed() -> void:
	if visible and card_library and card_library.settings_resource:
		path_input.text = card_library.settings_resource.card_root_directory
		template_path_input.text = card_library.settings_resource.custom_card_scene_path
		
		var is_subfolder = (card_library.settings_resource.storage_style == CardProjectSettings.StorageStyle.SUBFOLDER)
		subfolder_checkbox.button_pressed = is_subfolder
		base_script_input.text = card_library.settings_resource.base_card_script_path


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


func _on_retarget_pressed() -> void:
	card_library.settings_resource.base_card_script_path = base_script_input.text
	var new_base = base_script_input.text.strip_edges()
	if new_base == "" or not ResourceLoader.exists(new_base):
		print("Error: Invalid Base Script Path.")
		return
		
	print("Starting Script Retargeting to: " + new_base)
	_retarget_all_scripts(new_base)


func _retarget_all_scripts(new_base_path: String) -> void:
	var root_path = "res://Cards/"
	if card_library.settings_resource.card_root_directory != "":
		root_path = card_library.settings_resource.card_root_directory
		
	var dir = DirAccess.open(root_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				# Found a card folder (e.g., "Dragon/")
				# Look for the script inside: "Dragon/Dragon.gd"
				var script_path = root_path + file_name + "/" + file_name + ".gd"
				_update_script_inheritance(script_path, new_base_path)
				
			elif file_name.ends_with(".gd"):
				# Found a flat script (e.g., "Dragon.gd")
				var script_path = root_path + file_name
				_update_script_inheritance(script_path, new_base_path)
				
			file_name = dir.get_next()
		
		print("Retargeting Complete.")
		# Trigger a filesystem scan so Godot sees the changes
		EditorInterface.get_resource_filesystem().scan()


func _update_script_inheritance(file_path: String, new_base: String) -> void:
	if not FileAccess.file_exists(file_path):
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	var new_lines = []
	var modified = false
	
	for line in lines:
		if line.strip_edges().begins_with("extends "):
			var new_line = "extends \"%s\"" % new_base
			if line.strip_edges() != new_line:
				new_lines.append(new_line)
				modified = true
			else:
				new_lines.append(line)
		else:
			new_lines.append(line)
			
	if modified:
		var new_content = "\n".join(new_lines)
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		write_file.store_string(new_content)
		write_file.close()
		print("Updated: " + file_path)
