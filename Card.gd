extends Control

signal card_clicked

export var symbol = '亀'
export var symbol_shadow_color = Color('#a24268')
export var attack_value = 1
export var hp_value = 1

var selected = false

func update():
	$RootForOffset/Kanji.text = symbol
	$RootForOffset/Kanji.add_color_override("font_color_shadow", symbol_shadow_color)
	$RootForOffset/Circle.add_color_override("font_color_shadow", symbol_shadow_color)
	$RootForOffset/AttackValue.text = str(attack_value)
	$RootForOffset/HPValue.text = str(hp_value)
	
	$RootForOffset.position.y = -20 if selected else 0
	
func get_width():
	return $RootForOffset/Kanji.rect_size.x

func _ready():
	update()

func _process(_delta):
	#update()
	pass

func _on_Card_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		emit_signal("card_clicked")
