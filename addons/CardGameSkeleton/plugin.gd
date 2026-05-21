@tool
extends EditorPlugin

var card_window: Control

func _enter_tree():
	# 当插件被加载时（包括编辑器启动）调用
	if not card_window:
		# 加载插件的UI场景
		var scene = preload("res://addons/CardGameSkeleton/CardGameSkeleton.tscn")
		if scene:
			card_window = scene.instantiate()
			# 添加到编辑器的左上角 Dock
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, card_window)
			# 可选：打印成功信息
			print("CardGameSkeleton plugin loaded, dock added.")
		else:
			print("Error: Could not load CardGameSkeleton.tscn")

func _exit_tree():
	# 清理：移除 Dock 并释放窗口
	if card_window:
		remove_control_from_docks(card_window)
		card_window.queue_free()
		card_window = null

# 以下函数保留为空或根据需要添加，原插件可能没有额外功能
func _enable_plugin():
	# 原来可能有一些初始化，但现在已经在 _enter_tree 中完成
	pass

func _disable_plugin():
	# 清理由 _exit_tree 处理
	pass
