extends Node

var network = NetworkedMultiplayerENet.new()
var Player = preload("res://scenes/Player.tscn")
var Level = preload("res://shared/scenes/Level2.tscn")

func _ready():
	
	var level = Level.instance()
	level.name = "Level"
	add_child(level)
	
	StartServer()
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
func _physics_process(delta):
	# deep copy to capture buffer at this moment in time
	var buffer = ServerData.input_buffer.duplicate(true)
	for pid in ServerData.input_buffer.keys():
		ServerData.input_buffer[pid] = []
	
	$DiagnosticsHandler.handle_diagnostics(buffer)
	$InputHandler.process_client_input(buffer)
	
#	for pid in ServerData.players.keys():
#		print(ServerData.players[pid].transform)


func _process(delta):
	# The various process functions return information that will be passed
	# back to the client
	
	var tick_info = {}
	for pid in ServerData.players.keys():
		tick_info[pid] = {}
		
	for pid in ServerData.players.keys():
		# At some point we might want to filter which players we transmit further,
		# to avoid wall and aimhacks
		var pinfo_transmit : Dictionary = {}
		for pid2 in ServerData.players.keys():
			if pid != pid2:
				pinfo_transmit[pid2] = {
					"transform" : Utility.array_from_transform(ServerData.players[pid2].transform),
					"head_angle" : ServerData.players[pid2].head_angle
				}
				
		var timestamp : int = OS.get_system_time_msecs()
				
		rpc_unreliable_id(pid, "players_update", timestamp, pinfo_transmit)
		#rpc_unreliable_id(pid, "world_update", ServerData.world)		


func StartServer():
	network.create_server(ServerData.port, ServerData.max_players)
	var args = Array(OS.get_cmdline_args())
	for arg in args:
		var formatted_arg_array = arg.split("=")
		print(formatted_arg_array)
		if formatted_arg_array.size() == 2 && formatted_arg_array[0] == "-bind-ip":
			var bind_ip = formatted_arg_array[1]
			network.set_bind_ip(bind_ip)
			print("Using command line specified bind ip: " + bind_ip)
		
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
	
func _peer_connected(player_id):
	var new_connect_info = {}
	new_connect_info["player"] = $PlayerManager.set_up_new_player(player_id)
	rpc_id(player_id, "confirm_connection", new_connect_info)
	
	
func _peer_disconnected(player_id):
	$PlayerManager.remove_player(player_id)


remote func report_construct(position, block_id):
	var player_id = get_tree().get_rpc_sender_id()
	ServerData.world[position] = block_id
	
	
remote func report_client_input(input_id : int, input : Dictionary):
	var player_id = get_tree().get_rpc_sender_id()
	input["input_id"] = input_id
	input["rec_time"] = OS.get_system_time_msecs()
	ServerData.input_buffer[player_id].append(input)


remote func _receive_message(msg, mode) -> void:
	var playername = "test" # get this from actual player
	if mode == "team":
		_send_message(msg, playername, mode)
		# only send message to team members
	else:
		_send_message(msg, playername, mode)
		

func send_diagnostics(pid, diagnostics):
	rpc_unreliable_id(pid, "report_diagnostics", diagnostics)


func _send_message(msg : String, usr : String, chat_mode : String = "normal", color_msg = '#ffffff', color_usr = '#ffffff') -> void:
	rpc_id(0, "_receive_server_message", msg, usr, chat_mode, color_msg, color_usr)
	

func send_input(pid, input : Dictionary, input_data : Dictionary):
	rpc_unreliable_id(pid, "recieve_input", input, input_data)
	
func send_shots(pid, shots : Array):
	rpc_unreliable_id(pid, "recieve_shots", shots)









