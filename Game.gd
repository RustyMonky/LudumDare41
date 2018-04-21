extends Node2D

enum GAME_STATE {
	DRAW,
	SELECT,
	PLAY,
	END
}

var card_data = {}
var card_file
var card_file_text

func _ready():
	# Temporary load of card JSON data
	card_file = File.new()
	card_file.open("res://data/cards.json", File.READ)
	card_file_text = card_file.get_as_text()
	card_data = JSON.parse(card_file_text).get_result()

	for card in card_data.cards:
		print(card.name)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
