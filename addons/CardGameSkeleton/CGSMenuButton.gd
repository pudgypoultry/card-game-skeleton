@tool
extends BaseButton
class_name CGSMenuButton

@export var message : String = ""
@export var menu_to_show : Control
var addon_manager : CGSDock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(open_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func test() -> void:
	print(message)


func open_menu() -> void:
	addon_manager.show_menu(menu_to_show)
