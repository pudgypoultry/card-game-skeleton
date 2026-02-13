@tool
extends Node

var json_filepath = "res://addons/CardGameSkeleton/CardLibrary/Decks.json"
var deck_dict : Dictionary

func _ready():
	var json_file : FileAccess = FileAccess.open(json_filepath, FileAccess.READ)
	var json_text = json_file.get_as_text().strip_edges(true, true)
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result == OK:
		deck_dict = json.data
