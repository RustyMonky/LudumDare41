extends Node

var fighter_select_box
var fighter_select_button_scene

var selected_fighter_info = null
var selected_fighter_patch = null
var selected_fighter_sprite = null

func _ready():
	fighter_select_box = $GUI/Container/VBoxContainer/fighterSelectContainer/selectBackground/selectionHBox

	fighter_select_button_scene = preload("res://fighters/fighterSelectButton.tscn")

	selected_fighter_patch = $GUI/Container/VBoxContainer/selectedFighterContainer/HBoxContainer/Container/selectedFighterPatch
	selected_fighter_info = $GUI/Container/VBoxContainer/selectedFighterContainer/HBoxContainer/Container/selectedFighterPatch/selectedFighterInfo
	selected_fighter_sprite = $GUI/Container/VBoxContainer/selectedFighterContainer/HBoxContainer/Container/selectedFighter

	for fighter in global.fighter_data.fighters:
		var fighterChar = fighter_select_button_scene.instance()
		var normal_texture = load(fighter.normalTexture)
		var hover_texture = load(fighter.hoverTexture)

		fighterChar.set_normal_texture(normal_texture)
		fighterChar.set_hover_texture(hover_texture)
		fighterChar.data = fighter
		fighter_select_box.add_child(fighterChar)

	set_process(true)

func _process(delta):
	if global.player_selected_fighter != null:
		var selected_texture = load(global.player_selected_fighter.selectedTexture)
		selected_fighter_sprite.set_texture(selected_texture)
		selected_fighter_sprite.set_scale(Vector2(3, 3))

		selected_fighter_patch.show()
		selected_fighter_info.set_text(global.player_selected_fighter.name)
		
