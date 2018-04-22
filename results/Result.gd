extends Node

var result_texture
var result_text

func _ready():
	result_texture = $GUI/resultTexture
	result_text = $GUI/resultTexture/resultText

	if global.fight_result != null:
		var required_texture
		if global.fight_result == "victory":
			required_texture = load("res://assets/sprites/results/victory.png")
			result_text.set_text("Victory!")
		elif global.fight_result == "defeat":
			required_texture = load("res://assets/sprites/results/defeat.png")
			result_text.set_text("Defeat")
		elif global.fight_result == "draw":
			required_texture = load("res://assets/sprites/results/draw.png")
			result_text.set_text("Draw!")

		result_texture.set_texture(required_texture)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
