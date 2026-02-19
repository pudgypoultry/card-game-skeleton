extends Node2D

class_name Card

@onready var card_front : Sprite2D = $CardFront
@onready var clickable_area : Area2D = $Area2D

@export var card_name: String
@export var attributes : Dictionary = {}

var dragging : bool = false
var drag_offset : Vector2 = Vector2.ZERO
var original_z_index : int = 0
var original_scale : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(card_name + " has been drawn")
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true
	clickable_area.input_event.connect(_on_area_2d_input_event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	# Use _input() for the drag and release because the mouse might move 
	# 	faster than the Area2D can track, or leave the Area2D while dragging.
	
	if not dragging:
		return
		
	# Update Position
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset

	# Stop Dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false
		
		# Reset Visuals
		z_index = original_z_index
		scale = original_scale
		
		# Check if we dropped on something valid here
		_check_drop_zone()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			get_viewport().set_input_as_handled()
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
			
			original_scale = scale
			original_z_index = z_index
			z_index = 100
			scale = original_scale * 1.1


func _check_drop_zone() -> void:
	print("Dropped at: ", global_position)
	# Add logic here: "If distance to board < 50, snap to board slot"
