@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var grid_container: GridContainer
# NEW EXPORT
@export var edit_menu: Control 
@export var dock_control: Node # Reference to the main DockControl to switch tabs

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		populate_grid()

func _on_visibility_changed() -> void:
	if visible:
		populate_grid()

func populate_grid() -> void:
	if not card_library or not grid_container:
		return
	
	for child in grid_container.get_children():
		if child.name == "BackToMainMenu": continue
		child.queue_free()
	
	var data = card_library.get_json_dict()
	if not data or data.is_empty(): return
		
	var card_names = data.keys()
	card_names.sort()
	
	for card_name in card_names:
		var card_info = data[card_name]
		var btn = Button.new()
		
		# Visuals
		btn.text = card_name
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.custom_minimum_size = Vector2(120, 160)
		btn.expand_icon = true
		btn.clip_text = true
		
		var image_path = card_info.get("Card Face", "")
		if image_path != "" and ResourceLoader.exists(image_path):
			btn.icon = load(image_path)
		else:
			btn.icon = preload("res://icon.svg")
		
		# --- CLICK CONNECTION ---
		# We bind the card_name so the function knows WHICH card was clicked
		btn.pressed.connect(_on_card_clicked.bind(card_name))
			
		grid_container.add_child(btn)

func _on_card_clicked(card_name: String) -> void:
	if edit_menu and dock_control:
		# 1. Prepare the edit menu
		if edit_menu.has_method("load_card_for_editing"):
			edit_menu.load_card_for_editing(card_name)
		
		# 2. Tell DockControl to switch to the edit menu
		# Assuming DockControl has a show_menu function
		dock_control.show_menu(edit_menu)
