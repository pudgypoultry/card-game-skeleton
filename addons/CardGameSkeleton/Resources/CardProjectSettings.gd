@tool
extends Resource
class_name CardProjectSettings
enum StorageStyle { FLAT, SUBFOLDER }

@export_dir var card_root_directory: String = "res://Cards/"
@export var custom_attributes: Array[CardAttribute]
@export var storage_style: StorageStyle = StorageStyle.SUBFOLDER
