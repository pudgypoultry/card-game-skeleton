@tool
extends MarginContainer

@export var card_library: CardLibrary

# UI References
@export var name_input: LineEdit
@export var type_input: OptionButton
@export var options_box : HBoxContainer
@export var options_input: LineEdit
@export var save_button: Button
@export var attribute_list_container: VBoxContainer

func _ready() -> void:
	# 1. Setup the Type Dropdown
	type_input.clear()
	type_input.add_item("Text", CardAttribute.AttributeType.TEXT)
	type_input.add_item("Number", CardAttribute.AttributeType.NUMBER)
	type_input.add_item("Selection", CardAttribute.AttributeType.SELECTION)
	
	# 2. Connect signals
	type_input.item_selected.connect(_on_type_changed)
	save_button.pressed.connect(_on_save_pressed)
	
	# 3. Initial Setup
	_on_type_changed(0)
	_refresh_list()


func _on_type_changed(index: int) -> void:
	var selected_id = type_input.get_item_id(index)
	options_box.visible = (selected_id == CardAttribute.AttributeType.SELECTION)


func _on_save_pressed() -> void:
	# Validation
	if name_input.text.strip_edges() == "":
		print("Error: Attribute name cannot be empty.")
		return
		
	if not card_library or not card_library.settings_resource:
		print("Error: CardLibrary or Settings Resource is missing.")
		return
	
	# Create new Attribute
	var new_attr = CardAttribute.new()
	new_attr.attribute_name = name_input.text
	new_attr.type = type_input.get_selected_id()
	
	if new_attr.type == CardAttribute.AttributeType.SELECTION:
		var raw_text = options_input.text
		var split_options = raw_text.split(",")
		var clean_options: Array[String] = []
		for opt in split_options:
			clean_options.append(opt.strip_edges())
		new_attr.selection_options = clean_options
	
	# Add to Resource
	card_library.settings_resource.custom_attributes.append(new_attr)
	_save_resource()
	
	# Clear form and refresh list
	_clear_form()
	_refresh_list()
	
	# emit changed signal
	card_library.attributes_changed.emit()


func _refresh_list() -> void:
	if not card_library or not card_library.settings_resource:
		return

	# Clear current list
	for child in attribute_list_container.get_children():
		child.queue_free()
		
	# Rebuild list
	var attributes = card_library.settings_resource.custom_attributes
	for i in range(attributes.size()):
		var attr = attributes[i]
		if attr is CardAttribute:
			_create_list_row(attr, i)


func _create_list_row(attr: CardAttribute, index: int) -> void:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(300, 0)
	
	# Name Label
	var name_label = Label.new()
	name_label.text = attr.attribute_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	
	# Type Label
	var type_label = Label.new()
	match attr.type:
		CardAttribute.AttributeType.TEXT: type_label.text = "[Text]"
		CardAttribute.AttributeType.NUMBER: type_label.text = "[Number]"
		CardAttribute.AttributeType.SELECTION: type_label.text = "[Select]"
	# Make it slightly dimmer to distinguish from name
	type_label.modulate = Color(0.7, 0.7, 0.7)
	row.add_child(type_label)
	
	# Delete Button
	var del_btn = Button.new()
	del_btn.text = "X"
	# We bind the index so the button knows which item to delete
	del_btn.pressed.connect(_on_delete_pressed.bind(index))
	row.add_child(del_btn)
	
	attribute_list_container.add_child(row)
	# print("Added " + str(row) + " to Existing Attributes")


func _on_delete_pressed(index: int) -> void:
	card_library.settings_resource.custom_attributes.remove_at(index)
	_save_resource()
	_refresh_list()
	card_library.attributes_changed.emit()


func _save_resource() -> void:
	var save_path = card_library.settings_resource.resource_path
	if save_path == "":
		save_path = "res://addons/CardGameSkeleton/CardLibrary/ProjectAttributes.tres"
	ResourceSaver.save(card_library.settings_resource, save_path)


func _clear_form() -> void:
	name_input.text = ""
	options_input.text = ""
	type_input.selected = 0
	_on_type_changed(0)
