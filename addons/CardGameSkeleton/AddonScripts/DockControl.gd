@tool
extends Control
class_name CGSDock

@export var main_menu : MarginContainer
@export var card_menu : MarginContainer
@export var deck_menu : MarginContainer
@export var configuration_menu : MarginContainer

@export_tool_button("Reset AddOn", "Callable") var reset_button = reset_tool

var current_menu : MarginContainer
var last_menu : MarginContainer
var menus : Array[Control]

func reset_tool():
	EditorInterface.set_plugin_enabled("CardGameSkeleton", false)
	EditorInterface.set_plugin_enabled("CardGameSkeleton", true)

func _ready():
	current_menu = main_menu
	for child in get_children():
		if child is Control:
			menus.append(child)
	# print(menus)
	var children = get_all_children(self)
	for child in children:
		if child is CGSMenuButton:
			child.addon_manager = self


func get_all_children(node):
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes


func show_main_menu():
	current_menu.visible = false
	main_menu.visible = true
	last_menu = current_menu
	current_menu = main_menu


func show_menu(menu):
	hide_menus()
	menu.visible = true
	last_menu = current_menu
	current_menu = menu


func hide_menus():
	for menu in menus:
		# print(menu)
		menu.visible = false


func show_last_menu():
	show_menu(last_menu)
