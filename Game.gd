extends Node2D

enum GAME_STATE {
	DRAW,
	SELECT,
	PLAY,
	END
}

# Current game state
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
var card_scene

# Text
var game_text

# Timers
var select_timer
var select_timer_label
var select_timer_started = false

func _ready():
	# Temporary load of card JSON data
	card_file = File.new()
	card_file.open("res://data/cards.json", File.READ)
	card_file_text = card_file.get_as_text()
	card_data = JSON.parse(card_file_text).get_result()
	# TODO replace computer deck
	card_data_2 = JSON.parse(card_file_text).get_result()

	card_scene = preload("res://card/Card.tscn")

	# Set starting HP values
	$GUI/topUI/topBox/playerHp.set_text(String(player_hp))
	$GUI/topUI/topBox/compHp.set_text(String(computer_hp))

	# Load decks
	# For dev purposes, just use the existing cards array
	computer_deck = card_data_2.cards
	player_deck = card_data.cards

	# Load hands
	while player_hand.size() < 3:
		player_draw()

	while computer_hand.size() < 3:
		computer_hand.push_front(computer_deck.pop_front())

	game_text = $GUI/fighterContainer/gameText

	select_timer = $SelectTimer
	select_timer_label = $GUI/topUI/topBox/selectTimer

	set_process(true)

func _process(delta):
	if current_game_state == DRAW:
		# If draw step, both players draw a card

		player_draw()

		var computer_card_drawn = computer_deck.pop_front()
		computer_hand.push_front(computer_card_drawn)

		current_game_state = SELECT
	elif current_game_state == SELECT:

		# Timer logic
		if not select_timer_started:
			select_timer.start()
			select_timer_started = true
			select_timer_label.set_text(String(int(round(select_timer.get_time_left()))))

		elif select_timer_started and not select_timer.is_stopped():
			select_timer_label.set_text(String(int(round(select_timer.get_time_left()))))

		elif select_timer_started and select_timer.is_stopped():
			current_game_state = PLAY
			select_timer_started = false

		# Card logic
		if global.hovered_card != null:
			game_text.set_text(global.hovered_card.description)
		elif global.hovered_card == null:
			game_text.set_text("")

		if global.selected_card != null:
			select_timer.stop()
			select_timer_started = false
			current_game_state = PLAY

	elif current_game_state == PLAY:
		pass

# Draws a card for the player
func player_draw():
	var card_drawn = player_deck.pop_front()
	player_hand.push_back(card_drawn)

	# Add new card instance
	var card = card_scene.instance()
	card.data = card_drawn
	$GUI/cardsPanel/cardMargins/playerCardBox.add_child(card)

	# Get index in hand for position setting
	var card_index = player_hand.find(card_drawn)