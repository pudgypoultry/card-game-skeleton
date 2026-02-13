@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var grid_container: GridContainer
@export var deck_builder: Control
@export var dock_control: Node


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		populate_grid()


func _on_visibility_changed() -> void:
	if visible:
		populate_grid()


func populate_grid() -> void:
	if not card_library or not grid_container: return
	
	# Clear old buttons
	for child in grid_container.get_children():
		if child.name == "BackToMainMenu" or child.name == "NewDeck":
			continue
		child.queue_free()
		
	var decks = card_library.get_deck_dict()
	var deck_names = decks.keys()
	deck_names.sort()
	
	for deck_name in deck_names:
		var btn = Button.new()
		btn.text = deck_name
		btn.custom_minimum_size = Vector2(140, 180)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.expand_icon = true
		
		var deck_data = decks[deck_name]
		var final_icon = preload("res://addons/CardGameSkeleton/Images/Decks.png")
		
		if deck_data is Dictionary and deck_data.has("image"):
			var img_path = deck_data["image"]
			if img_path != "" and ResourceLoader.exists(img_path):
				final_icon = load(img_path)
		
		btn.icon = final_icon
		btn.pressed.connect(_on_deck_clicked.bind(deck_name))
		grid_container.add_child(btn)


func _on_deck_clicked(deck_name: String) -> void:
	if deck_builder and dock_control:
		# 1. Pre-load the builder with this deck's data
		if deck_builder.has_method("load_deck"):
			deck_builder.load_deck(deck_name)
		
		# 2. Switch view
		dock_control.show_menu(deck_builder)
