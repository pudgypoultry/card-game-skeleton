@tool
extends MarginContainer

## The scene used for each attribute row (AttributeField.tscn)
@export var field_scene: PackedScene

## The VBoxContainer where the fields will be added
@export var fields_container: VBoxContainer

## Reference to the CardLibrary manager to fetch attributes
@export var card_library: CardLibrary

func _ready() -> void:
	# Connect the signal so this menu updates automatically
	if card_library:
		if not card_library.attributes_changed.is_connected(populate_fields):
			card_library.attributes_changed.connect(populate_fields)
	# Automatically populate fields when the menu loads
	populate_fields()

## Generates the input forms based on the ProjectAttributes resource
func populate_fields() -> void:
	# Safety checks to prevent crashes if nodes aren't assigned
	if not field_scene:
		print("NewCardMenu Error: Field Scene is not assigned.")
		return
	if not fields_container:
		print("NewCardMenu Error: Fields Container is not assigned.")
		return
	if not card_library:
		print("NewCardMenu Error: Card Library is not assigned.")
		return

	# 1. Clear existing fields to prevent duplicates
	for child in fields_container.get_children():
		child.queue_free()

	# 2. Get the list of CardAttribute resources from the library
	# Ensure CardLibrary.gd has the get_custom_attributes() function from Step 2!
	var attributes = card_library.get_custom_attributes()

	# 3. Create a field for each attribute
	for attribute_data in attributes:
		if attribute_data is CardAttribute:
			var new_field = field_scene.instantiate()
			fields_container.add_child(new_field)
			
			# Configure the field
			if new_field.has_method("setup"):
				new_field.setup(attribute_data)
			else:
				print("Error: The field scene does not have a 'setup' method.")
