extends Node2D

enum GAME_STATE {
	DRAW,
	SELECT,
	PLAY,
	END
}

var current_game_state = DRAW

# Actors HP
var computer_hp = 10
var player_hp = 10

# Actors Decks
var computer_deck
var player_deck

# Actor Hands
var computer_hand = []
var player_hand = []

# Card JSON load
var card_data = {}
var card_data_2 = {} # TODO - REPLACE
var card_file
var card_file_text

func _ready():
	# Temporary load of card JSON data
	card_file = File.new()
	card_file.open("res://data/cards.json", File.READ)
	card_file_text = card_file.get_as_text()
	card_data = JSON.parse(card_file_text).get_result()
	# TODO replace computer deck
	card_data_2 = JSON.parse(card_file_text).get_result()

	# Set starting HP values
	$GUI/playerHp.set_text(String(player_hp))
	$GUI/compHp.set_text(String(computer_hp))

	# Load decks
	# For dev purposes, just use the existing cards array
	computer_deck = card_data_2.cards
	player_deck = card_data.cards

	# Load hands
	while player_hand.size() < 3:
		player_hand.push_front(player_deck.pop_front())

	while computer_hand.size() < 3:
		computer_hand.push_front(computer_deck.pop_front())

	set_process(true)

func _process(delta):
	if current_game_state == DRAW:
		# If draw step, both players draw a card

		var player_card_drawn = player_deck.pop_front()
		player_hand.push_front(player_card_drawn)

		var computer_card_drawn = computer_deck.pop_front()
		computer_hand.push_front(computer_card_drawn)

		current_game_state = SELECT
	elif current_game_state == SELECT:
		pass
