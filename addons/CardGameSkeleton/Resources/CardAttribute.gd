@tool
extends Resource
class_name CardAttribute

enum AttributeType { TEXT, NUMBER, SELECTION }

@export var attribute_name : String = "New Attribute"
@export var type : AttributeType = AttributeType.TEXT
@export var selection_options : Array[String] = []
