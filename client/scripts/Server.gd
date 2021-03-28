extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 6969

func _ready():
	print("Client started")
	
	var args = Array(OS.get_cmdline_args())
	for arg in args:
		var formatted_arg_array = arg.split("=")
		print(formatted_arg_array)
		if formatted_arg_array.size() == 2 && formatted_arg_array[0] == "-ip":
			ip = formatted_arg_array[1]
			print("Using command line specified ip: " + ip)
		else:
			print("Using default ip: " + ip)
			
	ConnectToServer()
	

func ConnectToServer():
	print("Connecting to server... (with ip: " + ip + ")")
	
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("connected_to_server", self, "_on_connection_succeeded")

	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	
func _on_connection_failed():
	ClientData.connected = false
	print("Failed to connect")
	
	
func _on_connection_succeeded():
	ClientData.connected = true
	print("Connected Successfully")
	

remote func confirm_connection(connect_info):
	get_node("../Client/Player").set_up(connect_info["player"])
	
	
remote func players_update(timestamp, other_players):
	get_node("../Client/PlayersHandler").push_players_update(timestamp, other_players)


remote func world_update(world):
	get_node("../Client/Level").update_world(world)
	
	
func report_input(input_id : int, input : Dictionary) -> void:
	if ClientData.connected:
		rpc_id(1, "report_client_input", input_id, input)

# Obsolete
remote func report_tick_update(update : Dictionary):
	get_node("../Client").handle_tick_update(update)
	
remote func report_diagnostics(diagnostics : Dictionary):
	pass # todo
	

remote func verify_input(input : Dictionary, input_data : Dictionary):
	get_node("../Client/InputHandler").verify_input(input, input_data)


func _send_message(msg: String, mode: String) -> void:
	rpc_id(1, "_receive_message", msg, mode)


remote func _receive_server_message(msg : String, usr : String, chat_mode : String = "normal", color_msg = '#ffffff', color_usr = '#ffffff') -> void:
	print("got msg from server ", msg)
	get_node("../Client/Chat").receive_from_server(msg, usr, chat_mode, color_msg, color_usr)
