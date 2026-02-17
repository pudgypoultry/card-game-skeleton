extends Node
class_name Deck

## This script manages a deck object. 
## The deck should have a reference to the relevant player's hand or whatever array of cards that cards drawn from the deck will end up in.


## The image representing the player's deck
@export var deckVisual : TextureRect
## the array representing the deck itself
@export var deck : Array[Card]
## the array representing the player's hand
@export var hand : Array[Card]
var currentlyShowingCard : bool = false
var originalSize : int
var deckSize : int
var lastSize : int


func _ready():
	# BoardManager.playerDeck = self
	deckSize = len(deck)
	lastSize = deckSize
	originalSize = deckSize


func _process(delta):
	if deckSize != lastSize:
		lastSize = deckSize

func GetSpawnPosition():
	return deckVisual.spawnPoint


func GetSpawnGlobalPosition():
	return deckVisual.spawnPoint + self.global_position


## Clears out the deck, resetting the deck to an empty list of cards
func ClearDeck():
	for i in range(len(deck)):
		var currentCard = deck[0]
		currentCard.get_parent().remove_child(deck[0])
		currentCard.queue_free()


## Grabs the top card of the deck, removes it from the deck, and returns it
func DrawFromTop():
	if len(deck) <= 0:
		return null
	return deck.pop_front()


## Same as draw from top but from the bottom
func DrawFromBottom():
	if len(deck) <= 0:
		return null
	if !currentlyShowingCard:
		return deck.pop_back()


## Draws from a given position in the deck, removing the card from the deck and returning it
func DrawFromPosition(pos : int):
	if !currentlyShowingCard:
		return deck.pop_at(pos)


## Performs DrawFromTop(), placing the resulting card into the given destination
func DrawFromTopToDestination(destination : Array):
	destination.append(DrawFromTop())


## Performs DrawFromBottom(), placing the resulting card into the given destination
func DrawFromBottomToDestination(destination : Array):
	destination.append(DrawFromBottom())


## Performs DrawFromPosition(), placing the resulting card into the given destination from the given position in the deck
func DrawFromPositionToDestination(position : int, destination : Array):
	destination.append(DrawFromPosition(position))


## Shuffles the deck, randomizing the order of the cards
func ShuffleDeck():
	deck.shuffle()


## Returns an array of the top X cards of the deck
func LookAtTopX(x : int):
	var returnArray = []
	for i in range(x):
		returnArray.append(DrawFromTop())
	return returnArray

## Returns an array of the bottom X cards of the deck
func LookAtBottomX(x : int):
	var returnArray = []
	for i in range(x):
		returnArray.append(DrawFromBottom())
	return returnArray


func PutCardOnTop(card : Card):
	deck.insert(0, card)


func PutCardsOnTop(cards : Array[Card]):
	for i in range(len(cards)):
		deck.insert(0, cards[i])


func PutCardOnBottom(card : Card):
	deck.append(card)


func PutCardsOnBottom(cards : Array[Card]):
	for i in range(len(cards)):
		deck.append(cards[i])


func InsertCardAtPosition(position : int, card : Card):
	if len(deck) < position:
		PutCardOnBottom(card)
	else:
		deck.insert(position, card)


func RemoveCardAtPosition(position : int):
	deck.remove_at(position)


"""=====================================================
Counting and Finding
====================================================="""

## Counts and returns the number of cards with the given type exist in the deck
func CountInstances(category, whatToCount):
	var count = 0
	#for card in deck:
		#if JSONAndLoadHandler.cardTagsDict[card].has(whatType):
			#count += 1
	return count


## Counts and returns the number of copies of the given card name exist in the deck
func CountCopies(cardName : String):
	var count = 0
	#for card in deck:
		#if card == cardName:
			#count += 1
	return count


## Returns the position of the first instance of the given card
func FirstInstance(whatCard : Card):
	return deck.find(whatCard)


## Returns the position of the last instance of the given card
func LastInstance(whatCard : Card):
	deck.reverse()
	var where = deck.find(whatCard)
	deck.reverse()
	return where
