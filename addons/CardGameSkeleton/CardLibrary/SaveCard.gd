@tool
extends Button

@export var card_json_manager: CardLibrary
@export var card_scene: PackedScene
@export var fields_container: VBoxContainer

func on_pressed() -> void:
	if not card_scene or not card_json_manager or not fields_container:
		print("SaveCard Error: Missing required exports.")
		return
	
	# Instantiate the new card
	var new_card: Card = card_scene.instantiate()
	
	# Get data from the AttributeFields
	var attribute_dict: Dictionary = {}
	
	for field in fields_container.get_children():
		# Check if it's our custom AttributeField class or has the methods we need
		if field.has_method("get_attribute_name") and field.has_method("get_value"):
			var key = field.get_attribute_name()
			var value = field.get_value()
			
			# Store into dictionary
			attribute_dict[key] = value
	
	# Handle specific required properties
	if attribute_dict.has("Card Name"):
		new_card.card_name = str(attribute_dict["Card Name"])
	else:
		new_card.card_name = "UnnamedCard"
		
	# Store all custom attributes in the card's dictionary
	new_card.attributes = attribute_dict
	
	# Save to JSON and File
	card_json_manager.save_new_card_to_json(new_card, attribute_dict)
	card_json_manager.save_card_scene_to_file(new_card)
	
	print("Saved card: " + new_card.card_name)
	
	new_card.queue_free()
