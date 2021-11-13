extends Node

var network = NetworkedMultiplayerENet.new()
var port = 6969
var menu_instance = null

const Player = preload("res://scenes/Player.tscn")
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
	
func _physics_process(delta):
	ClientData.client_clock += int(delta * 1000) + ClientData.delta_latency
	ClientData.delta_latency = 0
	ClientData.decimal_collector += (delta * 1000) - int(delta * 1000)
	if ClientData.decimal_collector >= 1.00:
		ClientData.client_clock += 1
		ClientData.decimal_collector -= 1.00

func _on_join_signal(ip_address, player_name):
	print("Joining game at " +  ip_address + " with player name: " + player_name)
	ConnectToServer(ip_address, player_name)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu_instance.queue_free()

func ConnectToServer(ip_address, player_name):
	print("Connecting to server... (with ip: " + ip_address + ")")
	
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("connected_to_server", self, "_on_connection_succeeded")

	
	var err = network.create_client(ip_address, port, 0, 0)
	print(err)
	get_tree().set_network_peer(network)
	
	
func _on_connection_failed():
	ClientData.connected = false
	print("Failed to connect")
	
	
func _on_connection_succeeded():	
	ClientData.connected = true
	print("Connected Successfully")
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.25 #TODO: do this less often, 0.5 was the tutorial value
	timer.autostart = true
	timer.connect("timeout", self, "_determine_latency")
	self.add_child(timer)

remote func return_server_time(server_time, client_time):
	var latency = (OS.get_system_time_msecs() - client_time) / 2
	ClientData.client_clock = server_time + latency

func _determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())
	
remote func return_latency(client_time):
	ClientData.latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if ClientData.latency_array.size() == 9:
		var total_latency = 0
		ClientData.latency_array.sort()
		var mid_point = ClientData.latency_array[4]
		for i in range(ClientData.latency_array.size() - 1, -1, -1):
			if ClientData.latency_array[i] > (2 * mid_point) && ClientData.latency_array[i] > 0:
				ClientData.latency_array.remove(i)
			else:
				total_latency += ClientData.latency_array[i]
		ClientData.delta_latency = (total_latency/ ClientData.latency_array.size()) - ClientData.latency
		ClientData.latency = total_latency / ClientData.latency_array.size()
		print("New Latency ", ClientData.latency)
		print("Delta Latency ", ClientData.delta_latency)
		ClientData.latency_array.clear()
			

remote func confirm_connection(connect_info):
	get_node("../Client/Player").set_up(connect_info["player"])
	
	
remote func players_update(timestamp, other_players):
#	print("====> ", timestamp, " ~ ", ClientData.client_clock, " (" + str((ClientData.client_clock - timestamp)) + ")")	
	get_node("../Client/PlayersHandler").push_players_update(timestamp, other_players)


#remote func world_update(world):
#	get_node("../Client/Level").update_world(world)
	
	
func report_input(input_id : int, input : Dictionary) -> void:
	if ClientData.connected:
		rpc_id(1, "report_client_input", input_id, input)

# Obsolete
remote func report_tick_update(update : Dictionary):
	get_node("../Client").handle_tick_update(update)
	
remote func report_diagnostics(diagnostics : Dictionary):
	pass # todo
	

remote func recieve_input(input : Dictionary, input_data : Dictionary):
	get_node("../Client/InputHandler").recieve_input(input, input_data)

remote func recieve_shots(shots : Array, hit : bool, player_locations : Array):
	get_node("../Client/InputHandler").recieve_shots(shots, hit, player_locations)

func _send_message(msg: String, mode: String) -> void:
	rpc_id(1, "_receive_message", msg, mode)

remote func _receive_server_message(msg : String, usr : String, chat_mode : String = "normal", color_msg = '#ffffff', color_usr = '#ffffff') -> void:
	print("got msg from server ", msg)
	get_node("../Client/Chat").receive_from_server(msg, usr, chat_mode, color_msg, color_usr)
