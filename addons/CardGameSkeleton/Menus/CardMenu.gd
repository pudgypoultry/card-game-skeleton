@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var grid_container: GridContainer

func _ready() -> void:
	# Refresh the grid whenever this menu is shown
	visibility_changed.connect(_on_visibility_changed)
	
	# Initial population if already visible
	if visible:
		populate_grid()

func _on_visibility_changed() -> void:
	if visible:
		populate_grid()

func populate_grid() -> void:
	if not card_library or not grid_container:
		print("CardMenu: Missing exports!")
		return
	
	# 1. Clear existing items (But keep the 'Back' button!)
	for child in grid_container.get_children():
		# Adjust this name if your back button is named differently
		if child.name == "BackToMainMenu":
			continue
		child.queue_free()
	
	# 2. Fetch data from JSON
	var data = card_library.get_json_dict()
	if not data or data.is_empty():
		return
		
	# 3. Sort cards alphabetically
	var card_names = data.keys()
	card_names.sort()
	
	# 4. Generate Buttons
	for card_name in card_names:
		var card_info = data[card_name]
		var btn = Button.new()
		
		# --- Visual Setup ---
		btn.text = card_name
		# Stack icon on top of text
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		# Make it look like a card
		btn.custom_minimum_size = Vector2(120, 160)
		btn.expand_icon = true
		btn.clip_text = true
		
		# --- Icon Logic ---
		# Check for "Card Face" or "Card Face Path" or similar keys
		# You can adjust this string if you renamed the attribute!
		var image_path = card_info.get("Card Face", "")
		
		if image_path != "" and ResourceLoader.exists(image_path):
			btn.icon = load(image_path)
		else:
			# Fallback icon if no image found
			btn.icon = preload("res://icon.svg")
			
		grid_container.add_child(btn)
