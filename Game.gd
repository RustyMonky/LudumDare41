extends Node

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
var computer_deck = []
var player_deck = []

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
var game_patch_ui
var text_array = []
var text_index = null

# Timers
var select_timer
var select_timer_label
var select_timer_started = false

# Card selection
var computer_card_selected = false
var computer_card = null

# Resolutions
var cards_resolved = false
var draw_resolved = false

# UI
var player_hand_ui
var player_hp_ui
var computer_hp_ui

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
	player_hp_ui = $GUI/topUI/topBox/playerHp
	computer_hp_ui = $GUI/topUI/topBox/compHp

	player_hp_ui.set_value(player_hp)
	computer_hp_ui.set_value(computer_hp)

	player_hand_ui = $GUI/cardsPanel/playerCardBox

	# Fix margins...

	# Load decks
	# Randomized for now
	while player_deck.size() < 15:
		randomize()
		var index = randi() % card_data.cards.size()
		player_deck.append(card_data.cards[index])

	while computer_deck.size() < 15:
		randomize()
		var index = randi() % card_data_2.cards.size()
		computer_deck.append(card_data_2.cards[index])

	# Load hands
	while player_hand.size() < 3:
		player_draw()

	while computer_hand.size() < 3:
		computer_hand.push_front(computer_deck.pop_front())

	game_patch_ui = $GUI/fighterContainer/gamePatch
	game_text = $GUI/fighterContainer/gamePatch/gameText

	select_timer = $SelectTimer
	select_timer_label = $GUI/topUI/topBox/timer/selectTimer

	set_process(true)

	set_process_input(true)

func _process(delta):
	if current_game_state == DRAW and not draw_resolved:
		# If draw step, both players draw a card
		var new_card = player_draw()
		computer_draw()
		prep_text(["You drew " + new_card.name + "!"])
		draw_resolved = true

	elif current_game_state == SELECT:
		for card in player_hand_ui.get_children():
			card.disabled = false

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
			game_patch_ui.show()
			game_text.set_text(global.hovered_card.description)
		elif global.hovered_card == null:
			game_patch_ui.hide()
			game_text.set_text("")

		if global.selected_card != null:
			# Stop timer and clear text
			select_timer.stop()
			select_timer_started = false
			game_text.set_text("")

			# Remove selected card from your hand
			var selected_card_index = player_hand.find(global.selected_card)
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
			game_patch_ui.hide()

			if current_game_state == DRAW and draw_resolved:
				current_game_state = SELECT
				draw_resolved = false
		elif text_index == null:
			if global.fight_result != null:
				global._goto_scene("res://results/Result.tscn")
			elif current_game_state == PLAY and cards_resolved:
				current_game_state = DRAW
				cards_resolved = false

# Draws a card for the player
func player_draw():
	# If deck is empty, we lose feelsbadman
	if player_deck.size() == 0:
		global.fight_result = "defeat"
		global.selected_card = null
		computer_card = null
		computer_card_selected = false
		prep_text(["Your deck has no more cards!"])

	var card_drawn = player_deck.pop_front()
	player_hand.push_back(card_drawn)

	# Add new card instance
	var card = card_scene.instance()
	card.data = card_drawn
	player_hand_ui.add_child(card)
	var normal_texture = load(card_drawn.normalTexture)
	var hover_texture = load(card_drawn.hoverTexture)
	card.set_normal_texture(normal_texture)
	card.set_hover_texture(hover_texture)

	return card_drawn

# Draws a card for the computer
func computer_draw():
	# If deck is empty, computer loses feelsgudman
	if computer_deck.size() == 0:
		global.fight_result = "victory"
		global.selected_card = null
		computer_card = null
		computer_card_selected = false
		prep_text(["Computer deck has no more cards!"])

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
	if not game_patch_ui.visible:
		game_patch_ui.show()
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
		battle_texts.append("You countered for " + String(player_effects.physical_damage) + "!")
	elif computer_effects.counter and player_effects.physical_damage > 0:
		computer_effects.physical_damage = player_effects.physical_damage * 2
		battle_texts.append("Computer countered for " + String(computer_effects.physical_damage) + "!")

	# Check for redirects
	if player_effects.redirect and computer_effects.power_damage > 0:
		player_effects.power_damage = computer_effects.power_damage
		computer_effects.power_damage = 0
		battle_texts.append("You redirected " + String(player_effects.power_damage) + "!")
	elif computer_effects.redirect and player_effects.power_damage > 0:
		computer_effects.power_damage = player_effects.power_damage
		player_effects.power_damage = 0
		battle_texts.append("Computer redirected " + String(player_effects.power_damage) + " at you!")

	# Now, we can calculate damage
	# Player damage dealt
	var player_physical_dmg = 0
	if player_effects.physical_damage - computer_effects.physical_block < 0:
		player_physical_dmg = 0
	else:
		player_physical_dmg = player_effects.physical_damage - computer_effects.physical_block

	var player_power_dmg = 0
	if player_effects.power_damage - computer_effects.power_block < 0:
		player_power_dmg = 0
	else:
		player_power_dmg = player_effects.power_damage - computer_effects.power_block

	var player_damage_dealt = player_physical_dmg + player_power_dmg

	# Computer damage dealt
	var computer_physical_dmg = 0
	if computer_effects.physical_damage - computer_effects.physical_block < 0:
		computer_physical_dmg = 0
	else:
		computer_physical_dmg = computer_effects.physical_damage - computer_effects.physical_block

	var computer_power_dmg = 0
	if computer_effects.power_damage - computer_effects.power_block < 0:
		computer_power_dmg = 0
	else:
		computer_power_dmg = computer_effects.power_damage - computer_effects.power_block
	var computer_damage_dealt = computer_physical_dmg + computer_power_dmg

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
		battle_texts.append("You gained " + String(new_player_hp - player_hp) + " HP!")
	else:
		battle_texts.append("You took no damage.")
	player_hp = new_player_hp
	player_hp_ui.set_value(player_hp)

	var new_computer_hp = computer_hp - player_damage_dealt + computer_effects.heal - computer_effects.recoil
	if new_computer_hp < computer_hp:
		battle_texts.append("Computer took " + String(computer_hp - new_computer_hp) + " damage!")
	elif new_computer_hp > computer_hp:
		battle_texts.append("Computer gained " + String(new_computer_hp - computer_hp) + " HP!")
	else:
		battle_texts.append("Computer took no damage.")
	computer_hp = new_computer_hp
	computer_hp_ui.set_value(computer_hp)

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
	global.selected_card = null
	computer_card = null
	computer_card_selected = false
	cards_resolved = true

	if player_hp <= 0 or computer_hp <= 0:
		if player_hp <=0 and computer_hp > 0:
			global.fight_result = "defeat"
		elif player_hp >0 and computer_hp <= 0:
			global.fight_result = "victory"
		elif player_hp <=0 and computer_hp <= 0:
			global.fight_result = "draw"