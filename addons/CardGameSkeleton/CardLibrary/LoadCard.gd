extends Node
class_name CardLoader

## This node holds a reference to the current state of the card dict for gameplay purposes

var json_filepath = "res://addons/CardGameSkeleton/CardLibrary/Cards.json"
var card_dict : Dictionary


func _ready():
	load_cards()


## Accesses the JSON file and fills the card_dict dictionary appropriately
func load_cards():
	var json_file : FileAccess = FileAccess.open(json_filepath, FileAccess.READ)
	var json_text = json_file.get_as_text().strip_edges(true, true)
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result == OK:
		card_dict = json.data


## Takes in a file path, instantiates the card scene,
## and prepares it with whatever is needed before returning it
func get_card(file_path) -> Card:
	var card_scene = load_card_scene_from_path(file_path)
	var card_object = card_scene.instantiate()
	return card_object


## This function takes in a file path and returns the PackedScene associated with it
func load_card_scene_from_path(file_path: String) -> PackedScene:
	if file_path == "" or not ResourceLoader.exists(file_path):
		push_error("Error: Scene file not found at: " + file_path)
		return null
	
	var scene = load(file_path) as PackedScene

	if not scene:
		push_error("Error: File at " + file_path + " is not a valid PackedScene.")
		return null
	
	return scene


## This function prepares the instantiated card scene with whatever is needed
## Edit this with whatever you need to prepare a card
func prepare_card(new_card : Card):
	new_card.card_front.texture = load(card_dict[new_card.card_name]["Front Face Location"])
