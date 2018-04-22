extends Node

# Scene management
var current_scene = null

# Card data
var card_file = null
var card_file_text = null
var card_data = null
var card_data_2 = null

# Card selection
var hovered_card = null
var selected_card = null

# Fighter data
var fighter_file
var fighter_file_text
var fighter_data

# Fighter selection
var player_selected_fighter = null
var computer_selected_fighter = null

# Fight statuses
var fight_result = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

	# Temporary load of card JSON data
	card_file = File.new()
	card_file.open("res://data/cards.json", File.READ)
	card_file_text = card_file.get_as_text()
	card_data = JSON.parse(card_file_text).get_result()
	# TODO replace computer deck
	card_data_2 = JSON.parse(card_file_text).get_result()

	# Load fighters
	fighter_file = File.new()
	fighter_file.open("res://data/fighters.json", File.READ)
	fighter_file_text = fighter_file.get_as_text()
	fighter_data = JSON.parse(fighter_file_text).get_result()

func _goto_scene(path):
    current_scene.queue_free()

    # Load new scene
    var s = ResourceLoader.load(path)

    # Instance the new scene
    current_scene = s.instance()

    # Add it to the active scene, as child of root
    get_tree().get_root().add_child(current_scene)

    # optional, to make it compatible with the SceneTree.change_scene() API
    get_tree().set_current_scene(current_scene)