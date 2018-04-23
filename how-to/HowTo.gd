extends Node

func _ready():
	pass

func _on_gotIt_pressed():
	$Control/NinePatchRect/gotIt/click.play()
	global._goto_scene("res://fighters/Fighters.tscn")
