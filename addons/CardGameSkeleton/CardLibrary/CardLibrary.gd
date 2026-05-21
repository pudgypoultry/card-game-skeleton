@tool
class_name CardLibrary
extends Node

## This class handles the generation of card information by loading from the CardLibrary JSON file
##
## This handles the saving and loading of information entered into the addon's UI
## If anything's going wrong in terms of JSON formatting, the issue is likely here lol

signal attributes_changed

@export var card_folder_file_path : String = "res://NewCards/"
@export var settings_resource : CardProjectSettings

# 这两个成员变量由 _update_json_paths() 负责更新
var json_card_file_path: String = ""
var json_deck_file_path: String = ""

var card_description_dict : Dictionary = {}
var card_name_dict : Dictionary = {}
var card_tags_Dict : Dictionary = {}
var resource_locations_dict : Dictionary = {}
var card_face_locations_dict : Dictionary = {}

## 更新 JSON 文件路径（基于 settings_resource 的 json_root_directory）
## 外部修改 json_root_directory 后应主动调用此方法
func _update_json_paths() -> void:
	if settings_resource:
		var root = settings_resource.json_root_directory
		if root.is_empty():
			root = "res://Cards/"
		if not root.ends_with("/"):
			root += "/"
		json_card_file_path = root + "Cards.json"
		json_deck_file_path = root + "Decks.json"
	else:
		# 降级默认路径
		json_card_file_path = "res://addons/CardGameSkeleton/CardLibrary/Cards.json"
		json_deck_file_path = "res://addons/CardGameSkeleton/CardLibrary/Decks.json"

## 确保目录存在，若不存在则递归创建
func _ensure_dir_exists(path: String) -> bool:
	var dir_path = path.get_base_dir()
	if DirAccess.dir_exists_absolute(dir_path):
		return true
	var err = DirAccess.make_dir_recursive_absolute(dir_path)
	if err != OK:
		push_error("无法创建目录: ", dir_path)
		return false
	return true

## 安全地读取 JSON 文件，如果文件不存在则返回空字典
func get_json_dict(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	
	var json_file = FileAccess.open(file_path, FileAccess.READ)
	if json_file == null:
		push_error("无法打开 JSON 文件: ", file_path)
		return {}
	
	var json_text = json_file.get_as_text().strip_edges(true, true)
	json_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("JSON 解析失败: ", json.get_error_message(), " 文件: ", file_path)
		return {}
	
	var data = json.data
	if data is Dictionary:
		return data
	else:
		push_error("JSON 根数据不是 Dictionary: ", file_path)
		return {}

## 安全地保存 Dictionary 到 JSON 文件，自动创建父目录
func save_dict_to_json(dict: Dictionary, file_path: String) -> bool:
	if not _ensure_dir_exists(file_path):
		return false
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("无法打开文件写入: ", file_path)
		return false
	
	var json_string = JSON.stringify(dict, "\t")
	file.store_string(json_string)
	file.close()
	return true

## Helper function to retrieve the attributes from the ProjectAttributes resource
func get_custom_attributes() -> Array:
	if settings_resource:
		_update_json_paths()   # 初始化时更新一次路径
		return settings_resource.custom_attributes
	else:
		var default_path = "res://addons/CardGameSkeleton/CardLibrary/ProjectAttributes.tres"
		if ResourceLoader.exists(default_path):
			settings_resource = load(default_path)
			_update_json_paths()
			return settings_resource.custom_attributes
		print("CardLibrary: No settings resource assigned and default not found.")
		return []

## Helper function to create the string of a card for the JSON file
func create_card_json_entry(card : Card, card_elements : Dictionary):
	var json_text = "\"%s\" : {\n" % [card.card_name]
	for element in card_elements.keys():
		json_text += "\t\"%s\" : %s,\n" % [element, card_elements[element]]
	json_text += "},"
	return json_text

## Takes a card scene and its elements and creates an entry for it in the JSON file
func save_new_card_to_json(card: Card, attributes: Dictionary) -> void:
	# 注意：此处不再调用 _update_json_paths()，依赖外部在设置改变时已更新成员变量
	var data = get_json_dict(json_card_file_path)
	data[card.card_name] = attributes
	save_dict_to_json(data, json_card_file_path)
	print("Saved to JSON: " + card.card_name)

## Returns the entire dictionary of decks
func get_deck_dict() -> Dictionary:
	return get_json_dict(json_deck_file_path)

## Saves a deck list to the JSON file
func save_deck(deck_name: String, card_list: Array, image_path: String = "") -> void:
	var decks = get_deck_dict()
	decks[deck_name] = {
		"cards": card_list,
		"image": image_path
	}
	save_dict_to_json(decks, json_deck_file_path)
	print("Saved Deck: " + deck_name)

## Deletes a deck from the JSON file
func delete_deck(deck_name: String) -> void:
	var decks = get_deck_dict()
	if decks.has(deck_name):
		decks.erase(deck_name)
		save_dict_to_json(decks, json_deck_file_path)

## Takes in a card scene and saves it to the project's card directory
func save_card_scene_to_file(card: Card) -> void:
	var root_path = "res://Cards/"
	var use_subfolders = true
	
	if settings_resource:
		if settings_resource.card_root_directory != "":
			root_path = settings_resource.card_root_directory
		use_subfolders = (settings_resource.storage_style == CardProjectSettings.StorageStyle.SUBFOLDER)
	
	var target_dir = root_path
	
	if card.attributes.has("Scene Location"):
		var user_input_path = str(card.attributes["Scene Location"]).strip_edges()
		if user_input_path != "":
			target_dir = user_input_path
			if not target_dir.ends_with("/"):
				target_dir += "/"
	
	if use_subfolders and target_dir == root_path:
		target_dir = target_dir + card.card_name + "/"
	
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(target_dir):
		var err = dir.make_dir_recursive_absolute(target_dir)
		if err != OK:
			print("Error creating directory '" + target_dir + "': " + str(err))
			return
	
	var script_save_path = target_dir + card.card_name + ".gd"
	
	_create_inherited_script(card, script_save_path)
	
	var new_script = load(script_save_path)
	
	if new_script:
		var cached_name = card.card_name
		var cached_attrs = card.attributes.duplicate()
		
		card.set_script(new_script)
		
		card.card_name = cached_name
		card.attributes = cached_attrs
	
	var save_path = target_dir + card.card_name + ".tscn"
	
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(card)
	
	if result == OK:
		var save_err = ResourceSaver.save(packed_scene, save_path)
		if save_err == OK:
			print("Saved card scene to: " + save_path)
		else:
			print("Error saving resource: ", save_err)
	else:
		print("Error packing scene: ", result)

## Deletes a card from the card JSON
func delete_card(card_name: String) -> void:
	var data = get_json_dict(json_card_file_path)
	if data.has(card_name):
		data.erase(card_name)
		save_dict_to_json(data, json_card_file_path)
	
	var file_path = card_folder_file_path + card_name + ".tscn"
	var dir = DirAccess.open(card_folder_file_path)
	if dir:
		if dir.file_exists(card_name + ".tscn"):
			dir.remove(card_name + ".tscn")
			print("Deleted file: " + file_path)
		else:
			print("File not found for deletion: " + file_path)

## Generates a new script that inherits from the card's current script
## If the user has not created their own Card class, use the default
func _create_inherited_script(card_node: Node, save_path: String) -> void:
	var base_script_path = ""
	var current_script = card_node.get_script()
	
	if current_script and current_script.resource_path != "":
		base_script_path = current_script.resource_path
		
		if not base_script_path.begins_with("res://"):
			print("Warning: Template uses a built-in script. Falling back to default AbstractCard2D.")
			base_script_path = "res://addons/CardGameSkeleton/Resources/AbstractCard2D.gd"
	else:
		base_script_path = "res://addons/CardGameSkeleton/Resources/AbstractCard2D.gd"
		
	var content = "extends \"%s\"\n\n" % base_script_path
	content += "# Autogenerated script for %s\n" % card_node.name
	content += "# Use this for unique logic (e.g. OnPlay effects)\n"
	content += "func _ready() -> void:\n"
	content += "\tsuper._ready()\n"
	content += "\tpass\n"
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		if not FileAccess.file_exists(save_path):
			print("Warning: Script file written but not immediately found: " + save_path)
	else:
		print("Error creating script at: " + save_path)
