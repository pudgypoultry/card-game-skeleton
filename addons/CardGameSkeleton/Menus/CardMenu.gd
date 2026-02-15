@tool
extends MarginContainer

@export var card_library: CardLibrary
@export var grid_container: GridContainer
@export var edit_menu: Control 
@export var dock_control: Node
@onready var search_input: LineEdit = $VBoxContainer/HBoxContainer/SearchInput
@onready var filter_dropdown: OptionButton = $VBoxContainer/HBoxContainer/FilterOptions
@onready var sort_dropdown: OptionButton = $VBoxContainer/HBoxContainer3/OrderBy
@onready var sort_direction_btn: Button = $VBoxContainer/HBoxContainer3/SortDirection

var active_filter_key: String = ""
var active_filter_value: String = ""

var active_sort_key: String = "Name" 
var is_descending: bool = false
var _sort_cache_data: Dictionary = {}


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if search_input:
		search_input.text_changed.connect(_on_search_text_changed)
	if filter_dropdown:
		filter_dropdown.item_selected.connect(_on_filter_selected)
		_populate_filter_dropdown()
	if visible:
		populate_grid()
	if sort_dropdown:
		sort_dropdown.item_selected.connect(_on_sort_changed)
		_populate_sort_dropdown()
		
	if sort_direction_btn:
		sort_direction_btn.toggled.connect(_on_sort_direction_toggled)


func _on_search_text_changed(new_text: String) -> void:
	populate_grid()


func _on_sort_changed(index: int) -> void:
	active_sort_key = sort_dropdown.get_item_text(index)
	populate_grid()


func _on_sort_direction_toggled(toggled_on: bool) -> void:
	is_descending = toggled_on
	sort_direction_btn.text = "Descending" if is_descending else "Ascending"
	populate_grid()


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
		val_a = data_a.get(active_sort_key, 0) # Default to 0 if missing
		val_b = data_b.get(active_sort_key, 0)
	
	if typeof(val_a) != typeof(val_b): # Force string if types mismatch
		val_a = str(val_a)
		val_b = str(val_b) 
	if is_descending:
		return val_a > val_b
	else:
		return val_a < val_b


func _on_filter_selected(index: int) -> void:
	if index <= 0:
		active_filter_key = ""
		active_filter_value = ""
	else:
		var meta = filter_dropdown.get_item_metadata(index)
		if meta:
			active_filter_key = meta["key"]
			active_filter_value = meta["value"]
	
	populate_grid()


func _on_visibility_changed() -> void:
	if visible:
		populate_grid()


func _populate_filter_dropdown() -> void:
	filter_dropdown.clear()
	filter_dropdown.add_item("All Cards", 0)
	
	# Get attributes from settings
	if card_library:
		var attributes = card_library.get_custom_attributes()
		
		# Loop through attributes and look for "Selection" types (Enum 2)
		for attr in attributes:
			if attr is CardAttribute and attr.type == CardAttribute.AttributeType.SELECTION:
				for option in attr.selection_options:
					filter_dropdown.add_item(attr.attribute_name + ": " + option)
					var meta = {"key": attr.attribute_name, "value": option}
					filter_dropdown.set_item_metadata(filter_dropdown.item_count - 1, meta)


func populate_grid() -> void:
	if not card_library:
		return
	
	for child in grid_container.get_children():
		child.queue_free()
		
	var data = card_library.get_json_dict()
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
		btn.custom_minimum_size = Vector2(120, 160)
		btn.clip_text = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.expand_icon = true
		
		# Use godot icon as default
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
		btn.pressed.connect(_on_card_clicked.bind(card_name))
		
		grid_container.add_child(btn)


func _on_card_clicked(card_name: String) -> void:
	if edit_menu and dock_control:
		if edit_menu.has_method("load_card_for_editing"):
			edit_menu.load_card_for_editing(card_name)
		dock_control.show_menu(edit_menu)
