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
var text_array = []
var text_index = null

# Timers
var select_timer
var select_timer_label
var select_timer_started = false

# Card selection
var computer_card_selected = false
var computer_card = null

# Card resolution
var cards_resolved = false

# UI
var player_hand_ui

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

	player_hand_ui = $GUI/cardsPanel/cardMargins/playerCardBox

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

	set_process_input(true)

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
			# Stop timer and clear text
			select_timer.stop()
			select_timer_started = false
			game_text.set_text("")

			# Remove selected card from your hand
			var selected_card_index = player_hand.find(global.selected_card)
			player_hand_ui.get_child(selected_card_index).queue_free()
			player_hand.erase(global.selected_card)

			current_game_state = PLAY

	elif current_game_state == PLAY:
		# Disabled hand until next SELECT phase
		for card in player_hand_ui.get_children():
			card.disabled = true

		# Process card selection and resolution
		if not computer_card_selected:
			var card_to_play_index = randi() % computer_hand.size()
			computer_card = computer_hand[card_to_play_index]
			computer_hand.erase(computer_card)
			computer_card_selected = true

		elif computer_card_selected:
			if not cards_resolved:
				resolve_cards()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if text_index != null and text_index + 1 < text_array.size():
			text_index += 1
			set_text()
		elif text_index != null and text_index + 1 >= text_array.size():
			text_index = null
			game_text.set_text("")
			if current_game_state == PLAY:
				current_game_state == END
			elif current_game_state == END:
				current_game_state == DRAW

# Draws a card for the player
func player_draw():
	var card_drawn = player_deck.pop_front()
	player_hand.push_back(card_drawn)

	# Add new card instance
	var card = card_scene.instance()
	card.data = card_drawn
	player_hand_ui.add_child(card)

# Draws a card for the computer
func computer_draw():
	var card_drawn = computer_deck.pop_front()
	computer_hand.push_back(card_drawn)

# Prepares sequential text strings
func prep_text(texts):
	# First, clear out the array
	text_array = []
	text_index = 0

	for strings in texts:
		text_array.append(strings)
	set_text()

# Sets text based on text index
func set_text():
	game_text.set_text(text_array[text_index])

# Resolve card logic
func resolve_cards():
	var battle_texts = []
	if text_index == null and global.selected_card != null:
		battle_texts.append("You played " + global.selected_card.name + "!")
		battle_texts.append("Computer played " + computer_card.name + "!")
	elif text_index == null and global.selected_card == null:
		battle_texts.append("You didn't play a card in time ...")
		battle_texts.append("Computer played " + computer_card.name + "!")

	var player_effects = {
		physical_damage = 0,
		physical_block = 0,
		power_damage = 0,
		power_block = 0,
		draw = 0,
		recoil = 0,
		heal = 0,
		redirect = false,
		counter = false,
		evade = false
	}

	var computer_effects = {
		physical_damage = 0,
		physical_block = 0,
		power_damage = 0,
		power_block = 0,
		draw = 0,
		recoil = 0,
		heal = 0,
		redirect = false,
		counter = false,
		evade = false
	}

	if global.selected_card != null:

		for effect in global.selected_card.effects:

			if effect.effectType == "Damage":
				if global.selected_card.type == "Brawn":
					player_effects.physical_damage += effect.effectValue
				elif global.selected_card.type == "Power":
					player_effects.power_damage += effect.effectValue

			elif effect.effectType == "Block":
				if global.selected_card.type == "Brawn":
					player_effects.physical_block += effect.effectValue
				elif global.selected_card.type == "Power":
					player_effects.power_block += effect.effectValue

			elif effect.effectType == "Draw":
				player_effects.draw += effect.effectValue

			elif effect.effectType == "Counter":
				player_effects.counter = true

			elif effect.effectType == "Redirect":
				player_effects.redirect = true

			elif effect.effectType == "Evade":
				randomize()
				var evade_int = randi() % 100
				if evade_int > 50:
					player_effects.evade = true

			elif effect.effectType == "Recoil":
				player_effects.recoil += effect.effectValue

			elif effect.effectType == "Heal":
				player_effects.heal += effect.effectValue

	for effect in computer_card.effects:

		if effect.effectType == "Damage":
			if computer_card.type == "Brawn":
				computer_effects.physical_damage += effect.effectValue
			elif computer_card.type == "Power":
				computer_effects.power_damage += effect.effectValue

		elif effect.effectType == "Block":
			if computer_card.type == "Brawn":
				computer_effects.physical_block += effect.effectValue
			elif computer_card.type == "Power":
				computer_effects.power_block += effect.effectValue

		elif effect.effectType == "Draw":
			computer_effects.draw += effect.effectValue

		elif effect.effectType == "Counter":
			computer_effects.counter = true

		elif effect.effectType == "Redirect":
			computer_effects.redirect = true

		elif effect.effectType == "Evade":
			randomize()
			var evade_int = randi() % 100
			if evade_int > 50:
				computer_effects.evade = true

		elif effect.effectType == "Recoil":
			computer_effects.recoil += effect.effectValue

		elif effect.effectType == "Heal":
			computer_effects.heal += effect.effectValue

	# Now let's resolve this disgusting logic...
	# Check for counters
	if player_effects.counter and computer_effects.physical_damage > 0:
		player_effects.physical_damage = computer_effects.physical_damage * 2
		battle_texts.append("You countered for " + player_effects.physical_damage + "!")
	elif computer_effects.counter and player_effects.physical_damage > 0:
		computer_effects.physical_damage = player_effects.physical_damage * 2
		battle_texts.append("Computer countered for " + computer_effects.physical_damage + "!")

	# Check for redirects
	if player_effects.redirect and computer_effects.power_damage > 0:
		player_effects.power_damage = computer_effects.power_damage
		computer_effects.power_damage = 0
		battle_texts.append("You redirected " + player_effects.power_damage + "!")
	elif computer_effects.redirect and player_effects.power_damage > 0:
		computer_effects.power_damage = player_effects.power_damage
		player_effects.power_damage = 0
		battle_texts.append("Computer redirected " + player_effects.power_damage + " at you!")

	# Now, we can calculate damage
	# Player damage dealt
	var player_damage_dealt = (abs(player_effects.physical_damage - computer_effects.physical_block)) + (abs(player_effects.power_damage - computer_effects.power_block))

	# Computer damage dealt
	var computer_damage_dealt = (abs(computer_effects.physical_damage - player_effects.physical_block)) + (abs(computer_effects.power_damage - player_effects.power_block))

	# Check for evasion
	if player_effects.evade:
		computer_damage_dealt = 0
		battle_texts.append("You evaded all attacks!")

	if computer_effects.evade:
		player_damage_dealt = 0
		battle_texts.append("Computer evaded all attacks!")

	# HP adjusting
	var new_player_hp = player_hp - computer_damage_dealt + player_effects.heal - player_effects.recoil
	if new_player_hp < player_hp:
		battle_texts.append("You took " + String(player_hp - new_player_hp) + " damage!")
	elif new_player_hp > player_hp:
		battle_texts.append("You healed for " + String(new_player_hp - player_hp) + " HP!")
	player_hp = new_player_hp

	var new_computer_hp = computer_hp - player_damage_dealt + computer_effects.heal - computer_effects.recoil
	if new_computer_hp < computer_hp:
		battle_texts.append("Computer took " + String(computer_hp - new_computer_hp) + " damage!")
	elif new_computer_hp > computer_hp:
		battle_texts.append("Computer healed for " + String(new_computer_hp - computer_hp) + " HP!")
	computer_hp = new_computer_hp

	# Check for card draw
	if player_effects.draw > 0:
		battle_texts.append("You drew " + String(player_effects.draw) + " cards!")
		var i = 0
		while i < player_effects.draw:
			player_draw()
			i += 1

	if computer_effects.draw > 0:
		battle_texts.append("Computer drew " + String(computer_effects.draw) + " cards!")
		var i = 0
		while i < computer_effects.draw:
			computer_draw()
			i += 1

	# We're finally done, prep the texts
	prep_text(battle_texts)
	cards_resolved = true