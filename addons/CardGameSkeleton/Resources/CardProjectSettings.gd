@tool
extends Resource
class_name CardProjectSettings

@export_dir var card_root_directory: String = "res://Cards/"
@export var custom_attributes: Array[CardAttribute]
