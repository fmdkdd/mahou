extends Node

var card_scene = preload("res://Card.tscn")
var player_scene = preload("res://PlayerArea.tscn")

onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_ip_address

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	print(Network.ip_address)

func _player_connected(id) -> void:
	print("Player " +str(id)+" has connected")
	
	var p2 = player_scene.instance()
	p2.name = str(id)
	p2.set_network_master(id)
	p2.connect("end_turn", self, "_on_EndTurn")
	p2.rotation_degrees = -180
	p2.position = Vector2(1280,330)
	$Players.add_child(p2)
	
	if $Players.get_child_count() == 2:
		start()

func _player_disconnected(id) -> void:
	print("Player " +str(id)+" has disconnected")	
		
func _on_Create_server_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()
	
	var id = get_tree().get_network_unique_id()
	var player = player_scene.instance()
	player.name = str(id)
	player.set_network_master(id)
	player.connect("end_turn", self, "_on_EndTurn")
	player.position = Vector2(0, 390)
	$Players.add_child(player)
	
func _on_Join_server_pressed():
	print("_on_Join_server_pressed")
	var ip_address
	if server_ip_address.text != "":
		ip_address = server_ip_address.text
	else:
		ip_address = "127.0.0.1"
	print(ip_address)
	multiplayer_config_ui.hide()
	Network.ip_address = ip_address
	Network.join_server()
	
func _connected_to_server() -> void:
	print("player connected")
	
	var id = get_tree().get_network_unique_id()
	var player = player_scene.instance()
	player.name = str(id)
	player.set_network_master(id)
	player.connect("end_turn", self, "_on_EndTurn")
	player.position = Vector2(0, 390)
	$Players.add_child(player)
	
	if $Players.get_child_count() == 2:
		start()

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

enum TurnState { P1, P2 }
var turn_state = TurnState.P1

# Fire/water/elec cards apply effects to animals

func start():
	seed($Players.get_child(1).name.hash())
	reset()
	
func reset():
	for p in $Players.get_children():
		p.init(p.name, create_deck())
		if p.id == str(1):
			p.interaction_enabled = true
		else:
			p.interaction_enabled = false
			
	turn_state = TurnState.P1

func _on_EndTurn():
	rpc("do_end_turn")
	
remotesync func do_end_turn():
	var p1 = $Players.get_child(0)
	var p2 = $Players.get_child(1)
	
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
			var card_index = player.board.find(card)
			var other_card = other.board[3 - card_index]
			var attack = card.attack_value
			if other_card != null:
				var hp = other_card.hp_value
				other_card.hp_value = max(0, other_card.hp_value - attack)
				other_card.update()
				attack -= hp
				if other_card.hp_value == 0:
					other.board[3 - card_index] = null
					other_card.queue_free()
			if attack > 0:
				other.update_hp(other.hp - attack)
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
	
	
