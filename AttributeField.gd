@tool
extends HBoxContainer

class_name AttributeField

@onready var label_node: Label = $LabelName
@onready var input_container: Control = $InputContainer

# The specific input control (LineEdit, SpinBox, or OptionButton)
var input_control: Control


## This function builds the UI based on the resource data
func setup(attribute_data: CardAttribute) -> void:
	# Set the label text
	label_node.text = attribute_data.attribute_name
	
	# Clear any old inputs (useful if the scene is recycled)
	for child in input_container.get_children():
		child.queue_free()
	
	# Create the correct input widget based on the enum type
	match attribute_data.type:
		CardAttribute.AttributeType.TEXT:
			var line_edit = LineEdit.new()
			line_edit.custom_minimum_size = Vector2(300,0)
			line_edit.placeholder_text = "Enter " + attribute_data.attribute_name
			input_control = line_edit
			
		CardAttribute.AttributeType.NUMBER:
			var spin_box = SpinBox.new()
			spin_box.allow_greater = true
			spin_box.allow_lesser = true
			spin_box.custom_minimum_size = Vector2(300,0)
			# Optional: Set a default step or range
			spin_box.step = 1.0 
			input_control = spin_box
			
		CardAttribute.AttributeType.SELECTION:
			var option_button = OptionButton.new()
			option_button.custom_minimum_size = Vector2(300,0)
			# Add all the options defined in the Resource
			for option in attribute_data.selection_options:
				option_button.add_item(option)
			input_control = option_button
	
	# Add the widget to the scene and make it fill the container
	input_container.add_child(input_control)
	input_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL


## Helper function to get the name of the attribute (key)
func get_attribute_name() -> String:
	return label_node.text


## Helper function to get the actual data (value)
func get_value():
	if not input_control:
		return null
		
	if input_control is LineEdit:
		return input_control.text
	elif input_control is SpinBox:
		return input_control.value
	elif input_control is OptionButton:
		# Returns the text of the selected item (e.g., "Creature")
		if input_control.selected == -1:
			return ""
		return input_control.get_item_text(input_control.selected)
	return null


func set_value(value) -> void:
	if not input_control:
		return
		
	if input_control is LineEdit:
		input_control.text = str(value)
	elif input_control is SpinBox:
		input_control.value = float(value)
	elif input_control is OptionButton:
		# Find the index of the string value
		for i in range(input_control.item_count):
			if input_control.get_item_text(i) == str(value):
				input_control.selected = i
				return
		# If not found, select nothing or default
		if input_control.item_count > 0:
			input_control.selected = 0
