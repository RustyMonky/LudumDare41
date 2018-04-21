extends TextureButton

var data

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_Card_pressed():
	global.selected_card = data


func _on_Card_mouse_entered():
	global.hovered_card = data


func _on_Card_mouse_exited():
	global.hovered_card = null
