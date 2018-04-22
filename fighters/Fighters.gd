extends Node

var fighter_select_box
var fighter_select_button_scene

func _ready():
	fighter_select_box = $GUI/Container/VBoxContainer/fighterSelectContainer/selectBackground/HBoxContainer

	fighter_select_button_scene = preload("res://fighters/fighterSelectButton.tscn")

	for fighter in global.fighter_data.fighters:
		var fighterChar = fighter_select_button_scene.instance()
		var normal_texture = load(fighter.normalTexture)
		var hover_texture = load(fighter.hoverTexture)

		fighterChar.set_normal_texture(normal_texture)
		fighterChar.set_hover_texture(hover_texture)
		fighterChar.data = fighter
		fighter_select_box.add_child(fighterChar)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
