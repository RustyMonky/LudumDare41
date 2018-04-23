extends TextureButton

var data = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _on_fighterSelectButton_pressed():
	$clickStream.play()
	global.player_selected_fighter = data

