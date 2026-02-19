extends Node
class_name CardLoader

## This node holds a reference to the current state of the card dict for gameplay purposes

var json_filepath = "res://addons/CardGameSkeleton/CardLibrary/Cards.json"
var card_dict : Dictionary


func _ready():
	load_cards()


func load_cards():
	var json_file : FileAccess = FileAccess.open(json_filepath, FileAccess.READ)
	var json_text = json_file.get_as_text().strip_edges(true, true)
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result == OK:
		card_dict = json.data


# TODO: Need to make scene location in dict be res://Cards/Card Name
#	rather than res://Cards
func load_card_scene_from_path(file_path: String) -> PackedScene:
	if file_path == "" or not ResourceLoader.exists(file_path):
		push_error("Error: Scene file not found at: " + file_path)
		return null
	
	var scene = load(file_path) as PackedScene
	
	if not scene:
		push_error("Error: File at " + file_path + " is not a valid PackedScene.")
		return null
	
	return scene


func prepare_card(new_card : Card):
	new_card.card_front.texture = load(card_dict[new_card.card_name]["Front Face Location"])
