extends Node2D

signal end_turn

var card_back_scene = preload("res://CardBack.tscn")
var card_scene = preload("res://Card.tscn")

var id
var deck
var card_back
var hand
var board
var selected_card
var hp
var interaction_enabled

class Hand:
	var cards = []
	var max_size = 5
	
	func get_card_count():
		return cards.size()
		
	func add_card(c):
		cards.append(c)
		
	func remove_card(c):
		cards.remove(cards.find(c))	
		
	func has_card(c):
		return cards.find(c) > -1
	
func _process(_delta):
	pass
	
func init(a_id, a_deck):
	self.id = a_id
	self.deck = a_deck
	hand = Hand.new()
	
	selected_card = null
	board = [null, null, null, null]
	hp = 20
	
	update_hp(hp)
		
	card_back = card_back_scene.instance()
	card_back.rect_position = $DeckPlace.rect_position
	card_back.connect("deck_clicked", self, "_on_Deck_clicked")
	add_child(card_back)
	
	interaction_enabled = false
	
func update_hp(a_hp):
	hp = max(0, a_hp)
	$HPLabel.text = str(hp)
		
func _on_Deck_clicked():
	if not interaction_enabled:
		return
	
	if deck.size() == 0:
		print("deck is empty")
		card_back.hide()
	else:
		draw_card()
	
func draw_card():
	if hand.get_card_count() >= hand.max_size:
		print("Hand is full")
		return

	var c = deck.pop_front()
	var card_index = hand.get_card_count()

	var hand_card_spacing = 10.0
	var posX = (c.get_width() + hand_card_spacing) * hand.get_card_count()
	var pos = $HandPlace.position + Vector2(posX, 0)
	c.rect_position = pos
	c.connect("card_clicked", self, "_on_Card_clicked", [c])
	add_child(c)
	
	hand.add_card(c)
	
func toggle_select_card(card):
	if selected_card == card:
		selected_card.selected = false
		selected_card.update()
		selected_card = null
		return
	
	if selected_card != null:
		selected_card.selected = false
		selected_card.update()
		
	selected_card = card
	selected_card.selected = true
	selected_card.update()
		
func play_card(card, card_place):
	hand.remove_card(card)
	card.selected = false
	board.append(card)
	card.rect_position = card_place.rect_position
	card.update()
	
func get_card_place_from_index(card_place_index):
	match card_place_index:
		0: return $CardPlace0
		1: return $CardPlace1
		2: return $CardPlace2
		3: return $CardPlace3
	
func _on_Card_clicked(card):	
	if not interaction_enabled:
		return
	
	if hand.has_card(card):
		toggle_select_card(card)

func _on_CardPlace_gui_input(event, card_place_index):
	if not interaction_enabled:
		return
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if selected_card != null:
			var card_place = get_card_place_from_index(card_place_index)
			play_card(selected_card, card_place)
			selected_card = null

func _on_EndTurnButton_pressed():
	if not interaction_enabled:
		return
	
	emit_signal("end_turn")
