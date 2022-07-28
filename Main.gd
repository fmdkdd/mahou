extends Node

var card_scene = preload("res://Card.tscn")
var player_scene = preload("res://PlayerArea.tscn")

func card_from_data(card_data):
	var c = card_scene.instance()
	c.symbol = card_data.symbol
	c.attack_value = card_data.attack
	c.hp_value = card_data.hp
	return c

func create_deck():
	var deck = []
	var size = 10
	
	for _i in range(size):
		var card_data = base_cards[randi() % base_cards.size()]
		deck.append(card_from_data(card_data))
		
	return deck

var p1
var p2

enum TurnState { P1, P2 }
var turn_state = TurnState.P1

# Player turn logic
# Multiplayer
# Fire/water/elec cards apply effects to animals

func _ready():
	randomize()
	
	p1 = player_scene.instance()
	p1.connect("end_turn", self, "_on_EndTurn")
	p1.position = Vector2(0, 390)
	add_child(p1)
	
	p2 = player_scene.instance()
	p2.connect("end_turn", self, "_on_EndTurn")
	p2.rotation_degrees = -180
	p2.position = Vector2(1280,330)
	add_child(p2)
	
	reset()
	
func reset():
	p1.init(1, create_deck())
	p2.init(2, create_deck())
	turn_state = TurnState.P1
	p1.interaction_enabled = true
	p2.interaction_enabled = false

func _on_EndTurn():
	match turn_state:
		TurnState.P1: 
			p1.interaction_enabled = false
			turn_state = TurnState.P2
			p2.interaction_enabled = true
			process_turn_end(p1, p2)
			print("p2 turn starts")
			
		TurnState.P2: 
			p2.interaction_enabled = false
			turn_state = TurnState.P1
			p1.interaction_enabled = true
			process_turn_end(p2, p1)
			print("p1 turn starts")

func process_turn_end(player, other):
	for card in player.board:
		if card != null:
			other.update_hp(other.hp - card.attack_value)
			if other.hp == 0:
				print("player ", player.id, " wins")
				
			
	
class CardData:
	var symbol
	var attack
	var hp
		
	static func build(a_symbol, a_hp, a_attack):
		var c = CardData.new()
		c.symbol = a_symbol
		c.attack = a_attack
		c.hp = a_hp
		return c
			
var base_cards = [ 
	CardData.build('亀', 3, 2),
	CardData.build('鼠', 1, 1),
	CardData.build('兎', 1, 2),
	CardData.build('竜', 3, 5),
	CardData.build('壁', 3, 0),
	CardData.build('魚', 1, 0),
]	
	
	
