@tool
extends Node
class_name CardLibrary

## This class handles the generation of card information by loading from the CardLibrary JSON file

@export var card_folder_file_path : String = "res://NewCards/"
@export var card_loader : Node
@export var settings_resource : CardProjectSettings
var json_card_file_path = "res://addons/CardGameSkeleton/CardLibrary/Cards.json"
var card_description_dict : Dictionary = {}
var card_name_dict : Dictionary = {}
var card_tags_Dict : Dictionary = {}
var resource_locations_dict : Dictionary = {}
var card_face_locations_dict : Dictionary = {}

signal attributes_changed

## Helper function to retrieve the attributes from the resource
func get_custom_attributes() -> Array:
	if settings_resource:
		return settings_resource.custom_attributes
	else:
		# Try to load default if not assigned in Inspector
		var default_path = "res://addons/CardGameSkeleton/CardLibrary/ProjectAttributes.tres"
		if ResourceLoader.exists(default_path):
			settings_resource = load(default_path)
			return settings_resource.attributes
			
		print("CardLibrary: No settings resource assigned and default not found.")
		return []


## This method grabs the relevant information for a given card object from the card library JSON
## Edit this with your relevant types/tags/categories for your own card's anatomy
func get_card_info(card):
	var cardStats : Dictionary = {}
	cardStats = {
		"NAME" : card.cardName, 
		"CARD_TEXT" : card_description_dict[card.card_name], 
		"TAGS" : card_tags_Dict[card.card_name],
		"RESOURCE_LOCATION" : resource_locations_dict["Card:" + card.card_name],
		"CARD_FACE" : card_face_locations_dict[card.card_name]
	}
	return cardStats


func load_card_json(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json_text = file.get_as_text().strip_edges(true, true)
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			var data = json.data
			if data is Dictionary:
				for key in data.keys():
					if "NAME" in data[key]:
						if "CARD_TEXT" in data[key]:
							card_description_dict[data[key]["NAME"]] = data[key]["DESCRIPTION"]
						if "TAGS" in data[key]:
							card_tags_Dict[data[key]["NAME"]] = data[key]["TAGS"]
						if "RESOURCE_LOCATION" in data[key]:
							resource_locations_dict["Card:" + data[key]["NAME"]] = data[key]["RESOURCE_LOCATION"]
						if "CARD_FACE" in data[key]:
							card_face_locations_dict[data[key]["NAME"]] = data[key]["CARD_FACE"]
			else:
				print("Error: JSON data is not a dictionary")
		else:
			print("Error parsing JSON")
		file.close()
	else:
		print("Error opening file")


func save_card_library_to_json(card_elements : Dictionary):
	var cards = get_all_cards()
	var json_file : FileAccess = FileAccess.open(json_card_file_path, FileAccess.WRITE)
	json_file.store_string(build_card_json(cards, card_elements))


func get_all_cards():
	var cards
	var card_directory = DirAccess.open(card_folder_file_path)
	if card_directory:
		card_directory.list_dir_begin()
		var file_name = card_directory.get_next()
		while file_name != "":
			if card_directory.current_is_dir():
				print("Found Directory: " + file_name)
			else:
				print("Found File: " + file_name)
			file_name = card_directory.get_next()
	else:
		print("An error occurred -- couldn't find a directory when trying to access path")


func build_card_json(cards : Array[Card], card_elements : Dictionary):
	var json_text = "{\n"
	for card in cards:
		var current_card_json = create_card_json_entry(card, card_elements)
		json_text += current_card_json
	json_text += "}"
	return json_text


func create_card_json_entry(card : Card, card_elements : Dictionary):
	var json_text = "\"%s\" : {\n" % [card.card_name]
	for element in card_elements.keys():
		json_text += "\t\"%s\" : %s,\n" % [element, card_elements[element]]
	json_text += "},"
	return json_text


func save_new_card_to_json(card : Card, card_elements : Dictionary):
	var card_dict = get_json_dict()
	print("ORIGINAL STATE:	", str(card_dict))
	card_dict[card.card_name] = card_elements
	print("	Adding " + card.card_name + " to dictionary")
	print("ALTERED STATE:	", str(card_dict))
	save_dict_to_json(card_dict)


func get_json_dict():
	var json_file : FileAccess = FileAccess.open(json_card_file_path, FileAccess.READ)
	# print(json_card_file_path)
	var json_text = json_file.get_as_text().strip_edges(true, true)
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	var data = json.data
	json_file.close()
	if data is Dictionary:
		return data
	else:
		return null



func save_dict_to_json(dict):
	var json_file : FileAccess = FileAccess.open(json_card_file_path, FileAccess.WRITE)
	var json_string = JSON.stringify(dict, "\t")
	#print(json_string)
	json_file.store_line(json_string)
	print("JOBS DONE ZUG ZUG")
	json_file.close()


func save_card_scene_to_file(card : Card):
	var packed_scene = PackedScene.new()
	packed_scene.pack(card)
	ResourceSaver.save(
		packed_scene, 
		card_folder_file_path + card.card_name + ".tscn")
