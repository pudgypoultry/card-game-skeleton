@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var dock_control: Node 

@onready var deck_name_input: LineEdit = $VBoxContainer/HBoxContainer/DeckNameInput
@onready var library_grid: GridContainer = $VBoxContainer/DeckContent/DeckLibrary/ScrollContainer/DeckGrid
@onready var deck_list: VBoxContainer = $VBoxContainer/DeckContent/CurrentDeck/ScrollContainer/DeckList
@onready var count_label: Label = $VBoxContainer/DeckContent/CurrentDeck/CountLabel
@onready var save_button: Button = $VBoxContainer/HBoxContainer/SaveButton
@onready var back_button: Button = $VBoxContainer/HBoxContainer/BackButton
@onready var delete_button: Button = $VBoxContainer/HBoxContainer/DeleteButton
@onready var search_input: LineEdit = $VBoxContainer/DeckContent/DeckLibrary/HBoxContainer/SearchInput
@onready var filter_dropdown: OptionButton = $VBoxContainer/DeckContent/DeckLibrary/HBoxContainer/FilterDropdown
@onready var image_path_input: LineEdit = $VBoxContainer/HBoxContainer2/ImagePathInput
@onready var deck_preview_image: TextureRect = $VBoxContainer/DeckPreviewImage
@onready var sort_dropdown: OptionButton = $VBoxContainer/DeckContent/DeckLibrary/HBoxContainer3/OrderBy
@onready var sort_direction_btn: Button = $VBoxContainer/DeckContent/DeckLibrary/HBoxContainer3/SortDirection

var active_sort_key: String = "Name"
var is_descending: bool = false
var _sort_cache_data: Dictionary = {}

var current_deck_cards: Array = []
var current_deck_name: String = ""

var active_filter_key: String = ""
var active_filter_value: String = ""


func _ready() -> void:
	save_button.pressed.connect(_on_save_pressed)
	if delete_button: 
		delete_button.pressed.connect(_on_delete_pressed)
	
	if sort_dropdown:
		sort_dropdown.item_selected.connect(_on_sort_changed)
		_populate_sort_dropdown()    
	if sort_direction_btn:
		sort_direction_btn.toggled.connect(_on_sort_direction_toggled)
	
	search_input.text_changed.connect(_on_search_changed)
	filter_dropdown.item_selected.connect(_on_filter_selected)
	
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		_populate_filter_dropdown()
		refresh_library()


func _populate_filter_dropdown() -> void:
	filter_dropdown.clear()
	filter_dropdown.add_item("All Cards", 0)
	
	if card_library:
		var attributes = card_library.get_custom_attributes()
		
		for attr in attributes:
			if attr is CardAttribute and attr.type == CardAttribute.AttributeType.SELECTION:
				for option in attr.selection_options:
					filter_dropdown.add_item(attr.attribute_name + ": " + option)
					var meta = {"key": attr.attribute_name, "value": option}
					filter_dropdown.set_item_metadata(filter_dropdown.item_count - 1, meta)


func _on_search_changed(new_text: String) -> void:
	refresh_library()

func _on_filter_selected(index: int) -> void:
	if index == 0:
		active_filter_key = ""
		active_filter_value = ""
	else:
		var meta = filter_dropdown.get_item_metadata(index)
		if meta:
			active_filter_key = meta["key"]
			active_filter_value = meta["value"]
	
	refresh_library()


func _on_sort_changed(index: int) -> void:
	active_sort_key = sort_dropdown.get_item_text(index)
	refresh_library()

func _on_sort_direction_toggled(toggled_on: bool) -> void:
	is_descending = toggled_on
	sort_direction_btn.text = "Descending" if is_descending else "Ascending"
	refresh_library()

func _populate_sort_dropdown() -> void:
	if not sort_dropdown: return
	sort_dropdown.clear()
	sort_dropdown.add_item("Name")
	
	if card_library and card_library.settings_resource:
		for attr in card_library.settings_resource.custom_attributes:
			if attr.type != CardAttribute.AttributeType.SELECTION:
				sort_dropdown.add_item(attr.attribute_name)

func _sort_cards_custom(a_name: String, b_name: String) -> bool:
	var val_a
	var val_b
	
	if active_sort_key == "Name":
		val_a = a_name
		val_b = b_name
	else:
		var data_a = _sort_cache_data.get(a_name, {})
		var data_b = _sort_cache_data.get(b_name, {})
		val_a = data_a.get(active_sort_key, 0)
		val_b = data_b.get(active_sort_key, 0)
	
	if typeof(val_a) != typeof(val_b):
		val_a = str(val_a)
		val_b = str(val_b)     
	if is_descending:
		return val_a > val_b
	else:
		return val_a < val_b


func refresh_library() -> void:
	if not card_library:
		return
	
	for child in library_grid.get_children():
		child.queue_free()
		
	var data = card_library.get_json_dict(card_library.json_card_file_path)
	var card_names = data.keys()
	
	_sort_cache_data = data 
	card_names.sort_custom(_sort_cards_custom)
	
	var search_term = ""
	if search_input:
		search_term = search_input.text.to_lower().strip_edges()
	
	var root_path = "res://Cards/"
	if card_library.settings_resource and card_library.settings_resource.card_root_directory != "":
		root_path = card_library.settings_resource.card_root_directory
	
	for card_name in card_names:
		var info = data[card_name]
		
		if search_term != "" and not card_name.to_lower().contains(search_term):
			continue 
			
		if active_filter_key != "":
			if not info.has(active_filter_key) or str(info[active_filter_key]) != active_filter_value:
				continue
		
		var btn = Button.new()
		btn.text = card_name
		btn.custom_minimum_size = Vector2(100, 120)
		btn.clip_text = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.expand_icon = true
		
		var final_icon = preload("res://icon.svg")
		var found_image = false
		
		var art_path = ""
		if info.has("Front Face Location"):
			art_path = info["Front Face Location"]
		
		if art_path != "" and ResourceLoader.exists(art_path):
			final_icon = load(art_path)
			found_image = true
		
		if not found_image:
			var extensions = ["png", "jpg", "jpeg", "svg", "webp"]
			for ext in extensions:
				var test_path = root_path + card_name + "/" + card_name + "." + ext
				if ResourceLoader.exists(test_path):
					final_icon = load(test_path)
					found_image = true
					break
		
		btn.icon = final_icon
		
		btn.pressed.connect(_add_card_to_deck.bind(card_name))
		library_grid.add_child(btn)


func _add_card_to_deck(card_name: String) -> void:
	current_deck_cards.append(card_name)
	_refresh_deck_list()


func _refresh_deck_list() -> void:
	for child in deck_list.get_children():
		child.queue_free()
	
	var display_list = current_deck_cards.duplicate()
	display_list.sort()
	
	for i in range(display_list.size()):
		var card_name = display_list[i]
		var row = HBoxContainer.new()
		
		var lbl = Label.new()
		lbl.text = card_name
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		row.add_child(lbl)
		
		var del_btn = Button.new()
		del_btn.text = "X"
		del_btn.modulate = Color(1,0,0)
		
		del_btn.pressed.connect(_remove_card_from_deck.bind(card_name))
		row.add_child(del_btn)
		
		deck_list.add_child(row)
		
	count_label.text = "Deck (" + str(current_deck_cards.size()) + ")"


func _remove_card_from_deck(card_name: String) -> void:
	current_deck_cards.erase(card_name)
	_refresh_deck_list()


func _on_save_pressed() -> void:
	var d_name = deck_name_input.text.strip_edges()
	if d_name == "":
		print("Error: Name empty")
		return
	
	card_library.save_deck(d_name, current_deck_cards, image_path_input.text)


func _on_delete_pressed() -> void:
	if current_deck_name != "":
		card_library.delete_deck(current_deck_name)
		print("Deleted Deck: " + current_deck_name)
		if dock_control and back_button:
			back_button.pressed.emit()


func start_new_deck() -> void:
	current_deck_name = ""
	current_deck_cards.clear()
	deck_name_input.text = ""
	deck_name_input.editable = true
	
	if delete_button: delete_button.visible = false
	dock_control.show_menu(self)
	_refresh_deck_list()


func load_deck(deck_name: String) -> void:
	current_deck_name = deck_name
	deck_name_input.text = deck_name
	
	if delete_button: 
		delete_button.visible = true
	
	var all_decks = card_library.get_deck_dict()
	
	if all_decks.has(deck_name):
		var deck_data = all_decks[deck_name]
		
		if deck_data is Dictionary:
			current_deck_cards = deck_data.get("cards", [])
			var img = deck_data.get("image", "")
			image_path_input.text = img
			_update_deck_preview(img)
		else:
			current_deck_cards = deck_data
			image_path_input.text = ""
			_update_deck_preview("")
			
	else:
		print("ERROR: Deck not found in dictionary!")
		current_deck_cards = []
		
	_refresh_deck_list()


func _update_deck_preview(path: String) -> void:
	if path != "" and ResourceLoader.exists(path):
		deck_preview_image.texture = load(path)
	else:
		deck_preview_image.texture = preload("res://icon.svg")
