extends TextureButton

var data

func _ready():
	pass

func _on_Card_pressed():
	global.selected_card = data
	self.queue_free()

func _on_Card_mouse_entered():
	global.hovered_card = data

func _on_Card_mouse_exited():
	global.hovered_card = null
