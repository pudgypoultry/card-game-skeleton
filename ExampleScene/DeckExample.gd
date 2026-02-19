extends Node2D

@export var deck_name : String = "BasicDeck"
@onready var deck_loader : DeckLoader = $DeckLoader
@onready var card_loader : CardLoader = $CardLoader
## The image representing the player's deck
@onready var deck_visual : Sprite2D = $DeckVisual
@onready var draw_position : Node2D = $DrawPosition
## the array representing the deck itself
var deck : Array[Card]
## the array representing the player's hand
var hand : Array[Card]
var originalSize : int
var deckSize : int
var lastSize : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_loader.load_decks()
	card_loader.load_cards()
	var cards_in_deck : Array = deck_loader.deck_dict[deck_name]["cards"]
	for card in cards_in_deck:
		deck.append(
				card_loader.get_card(
				card_loader.card_dict[card]["Scene Location"] + 
				card_loader.card_dict[card]["Card Name"] +
				".tscn")
			)
	
	shuffle_deck()



@warning_ignore("unused_parameter")
func _process(delta):
	if deckSize != lastSize:
		lastSize = deckSize


## Gets the position of the node that a draw card will be instantiated to
func get_spawn_position():
	return deck_visual.spawnPoint


## Gets the global position of the node that a draw card will be instantiated to
func get_spawn_position_global():
	return deck_visual.spawnPoint + self.global_position


## Clears out the deck, resetting the deck to an empty list of cards
func clear_deck():
	for i in range(len(deck)):
		var currentCard = deck[0]
		currentCard.get_parent().remove_child(deck[0])
		currentCard.queue_free()


## Grabs the top card of the deck, removes it from the deck, and returns it
func draw_from_top() -> Card:
	if len(deck) <= 0:
		return null
	var new_card = deck.pop_front()
	get_tree().root.add_child(new_card)
	new_card.global_position = draw_position.global_position
	new_card.scale = scale
	card_loader.prepare_card(new_card)
	return new_card


## Same as draw from top but from the bottom
func draw_from_bottom():
	if len(deck) <= 0:
		return null
	var new_card = deck.pop_back().instantiate()
	get_tree().root.add_child(new_card)
	new_card.global_position = draw_position.global_position
	new_card.scale = scale
	card_loader.prepare_card(new_card)
	return new_card


## Draws from a given position in the deck, removing the card from the deck and returning it
func draw_from_position(pos : int):
	return deck.pop_at(pos)


## Shuffles the deck, randomizing the order of the cards
func shuffle_deck():
	deck.shuffle()



func put_card_on_top(card : Card):
	deck.insert(0, card)


func put_card_on_bottom(card : Card):
	deck.append(card)



func insert_card_at_position(pos : int, card : Card):
	if len(deck) < pos:
		put_card_on_bottom(card)
	else:
		deck.insert(pos, card)


func remove_card_at_position(pos : int):
	deck.remove_at(pos)


## Counts and returns the number of copies of the given card name exist in the deck
func count_copies(cardName : String):
	var count = 0
	for card in deck:
		if card.attributes["Card Name"] == cardName:
			count += 1
	return count


## Returns the position of the first instance of the given card
func first_instance(whatCard : Card):
	return deck.find(whatCard)


## Returns the position of the last instance of the given card
func last_instance(whatCard : Card):
	deck.reverse()
	var where = deck.find(whatCard)
	deck.reverse()
	return where
