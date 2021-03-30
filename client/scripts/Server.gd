extends Node

var network = NetworkedMultiplayerENet.new()
var port = 6969
var menu_instance = null

const Menu = preload("res://scenes/Menu.tscn")

func _ready():
	print("Client started")
	var ip_address = null
	var player_name = null
	
	var args = Array(OS.get_cmdline_args())
	for arg in args:
		var formatted_arg_array = arg.split("=")
		print(formatted_arg_array)
		if formatted_arg_array.size() == 2:
			if formatted_arg_array[0] == "-ip":
				ip_address = formatted_arg_array[1]
				print("Using command line specified ip: " + ip_address)
			else:
				print("Command line ip not specified")
			if formatted_arg_array[0] == "-name":
				player_name = formatted_arg_array[1]
				print("Using command line specified name: " + player_name)
			else:
				print("Command line name not specified")	
	
	if ip_address != null && player_name != null:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		ConnectToServer(ip_address, player_name)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if menu_instance != null:
			menu_instance.queue_free()
		menu_instance = Menu.instance()
		menu_instance.connect("join_signal", self, "_on_join_signal")
		add_child(menu_instance)
	
func _on_join_signal(ip_address, player_name):
	print("_on_join_signal")
	ConnectToServer(ip_address, player_name)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu_instance.queue_free()

func ConnectToServer(ip_address, player_name):
	print("Connecting to server... (with ip: " + ip_address + ")")
	
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("connected_to_server", self, "_on_connection_succeeded")

	network.create_client(ip_address, port, 0, 0, port)
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
