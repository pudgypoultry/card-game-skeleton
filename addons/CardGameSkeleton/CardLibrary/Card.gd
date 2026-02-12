extends Node

class_name Card

@export var card_name: String
@export var attributes : Dictionary = {}
@export var cardFront : Sprite2D
@export var cardBack : Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func FlipCard():
	cardFront.visible = !cardFront.visibile
	cardBack.visible = !cardBack.visibile
