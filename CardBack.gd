extends Panel

signal deck_clicked

func _ready():
	pass
	
func _on_CardBack_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		emit_signal("deck_clicked")
