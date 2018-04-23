extends Node

var splash
var credits
var click

func _ready():
	splash = $GUI/splash
	credits = $GUI/credits
	click = $Node2D/click

func _on_play_pressed():
	click.play()
	global._goto_scene("res://how-to/HowTo.tscn")

func _on_credits_pressed():
	click.play()
	splash.hide()
	credits.show()

func _on_quit_pressed():
	click.play()
	get_tree().quit()

func _on_back_pressed():
	click.play()
	splash.show()
	credits.hide()
