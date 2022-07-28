extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 2

var server = null
var client = null

var ip_address = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("169.254") and not ip.ends_with(".1"):
			ip_address = ip
	
	print("ip_address = ", ip_address)		
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server() -> void:
	print("create_server")
	server = NetworkedMultiplayerENet.new()
	var error = server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if error != 0:
		print("error = ", error)
	get_tree().set_network_peer(server)

func join_server() -> void:
	print("join_server")
	client = NetworkedMultiplayerENet.new()
	var error = client.create_client(ip_address, DEFAULT_PORT)
	if error != 0:
		print("error = ", error)
	get_tree().set_network_peer(client)
	
func _connected_to_server() -> void:
	print("Successfully connected to the server")
	
func _server_disconnected() -> void:
	print("Disconnected from the server")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
