@tool
extends Node

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
