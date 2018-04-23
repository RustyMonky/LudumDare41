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
			$node2d/victoryStream.play()

		elif global.fight_result == "defeat":
			required_texture = load("res://assets/sprites/results/defeat.png")
			result_text.set_text("Defeat")
			$node2d/defeatStream.play()

		elif global.fight_result == "draw":
			required_texture = load("res://assets/sprites/results/draw.png")
			result_text.set_text("Draw!")
			$node2d/defeatStream.play()

		result_texture.set_texture(required_texture)

func _on_playAgain_pressed():
	global.player_selected_fighter = null
	global.fight_result = null
	global._goto_scene("res://fighters/Fighters.tscn")

func _on_quit_pressed():
	get_tree().quit()
