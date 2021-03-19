extends Node

var network = NetworkedMultiplayerENet.new()
# var ip = "25.92.151.203"
# var ip = "192.168.178.35"
var ip = "127.0.0.1"
var port = 29995

func _ready():
	print("Client started")
	ConnectToServer()
	

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	
	
func _on_connection_failed():
	print("Failed to connect")
	
	
func _on_connection_succeeded():
	print("Connected Successfully")
	

remote func confirm_connection(connect_info):
	get_node("../Client/Player").set_up(connect_info["player"])
	
	
remote func players_update(timestamp, other_players):
	get_node("../Client/PlayersHandler").push_players_update(timestamp, other_players)


remote func world_update(world):
	get_node("../Client/Level").update_world(world)
	
	
func report_input(input_id : int, input : Dictionary) -> void:
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
