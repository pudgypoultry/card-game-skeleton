@tool
extends EditorPlugin

var toolbar
var dock_instance

func _enable_plugin() -> void:
	# Add autoloads here.
	toolbar = preload("res://addons/CardGameSkeleton/CardGameSkeleton.tscn").instantiate()
	#add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar)
	#add_control_to_bottom_panel(toolbar, "Card Game Skeleton")
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, toolbar)


func _disable_plugin() -> void:
	# Remove autoloads here.
	#remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar)
	#remove_control_from_bottom_panel(toolbar)
	remove_control_from_docks(toolbar)
	toolbar.free()


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if dock_instance:
			remove_control_from_docks(toolbar)
			toolbar.free()
