@tool
extends Resource
class_name CardAttribute

# Define the types of inputs we support
enum AttributeType { TEXT, NUMBER, SELECTION }

@export var attribute_name : String = "New Attribute"
@export var type : AttributeType = AttributeType.TEXT
# We only use this list if "type" is set to SELECTION
@export var selection_options : Array[String] = []
