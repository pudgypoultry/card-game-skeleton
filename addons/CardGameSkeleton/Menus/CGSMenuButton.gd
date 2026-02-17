@tool
extends BaseButton
class_name CGSMenuButton

## This script gives a means of traversing the menu easily
##
## I uh... was learning while making this, apologies for inconsistencies in design

@export var message : String = ""
@export var menu_to_show : Control
var addon_manager : CGSDock


func _ready() -> void:
	pressed.connect(open_menu)


func test() -> void:
	print(message)


func open_menu() -> void:
	addon_manager.show_menu(menu_to_show)
