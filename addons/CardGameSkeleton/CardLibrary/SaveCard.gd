@tool
extends Button

@export var card_json_manager: CardLibrary
@export var card_scene: PackedScene
@export var fields_container: VBoxContainer

func on_pressed() -> void:
	if not card_scene or not card_json_manager:
		print("Error: Missing Card Scene or Library")
		return

	# Collect values from fields
	var attribute_dict: Dictionary = {}
	for field in fields_container.get_children():
		if field.has_method("get_attribute_name") and field.has_method("get_value"):
			attribute_dict[field.get_attribute_name()] = field.get_value()
	
	var card_name = attribute_dict.get("Card Name", "")
	var scene_loc = attribute_dict.get("Scene Location", "")
	
	# Check for empty name
	if str(card_name).strip_edges() == "":
		print("ERROR: Card Name is required!")
		OS.alert("Please enter a Card Name.", "Missing Information") 
		return
	
	# Check for empty location
	if str(scene_loc).strip_edges() == "":
		print("ERROR: Scene Location is required!")
		OS.alert("Please enter a Scene Location.", "Missing Information")
		return
	
	# Instantiate and Setup Card
	var new_card: Card = card_scene.instantiate()
	
	new_card.card_name = card_name
	new_card.attributes = attribute_dict
	
	card_json_manager.save_new_card_to_json(new_card, attribute_dict)
	card_json_manager.save_card_scene_to_file(new_card)
	
	print("Created card: " + new_card.card_name)
	new_card.queue_free()
	
	var parent_menu = get_parent().get_parent()
	if parent_menu.has_method("populate_fields"):
		parent_menu.populate_fields()
