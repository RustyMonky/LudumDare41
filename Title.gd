extends Node

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _on_play_pressed():
	global._goto_scene("res://fighters/Fighters.tscn")

func _on_credits_pressed():
	pass # replace with function body

func _on_quit_pressed():
	get_tree().quit()
