extends Node

# TODO put back in extrapolation
# TODO More sophisticated way of adding/removing players

const Bot = preload("res://scenes/Bot.tscn")

var client_time_offset = null

func push_players_update(timestamp : int, other_player_info : Dictionary):
	var compiled_player_info = {}
	for pid in other_player_info.keys():
		compiled_player_info[pid] = {}
		var transform = Utility.transform_from_array(other_player_info[pid]["transform"])
		compiled_player_info[pid]["transform"] = transform
		compiled_player_info[pid]["head_angle"] = other_player_info[pid]["head_angle"]
		
	# no player info if no other players are on the server
	if not compiled_player_info.empty():
		ClientData.player_buffer.append({"timestamp" : timestamp, "player_info" : compiled_player_info})
	

func process_other_players(delta):
	if ClientData.player_buffer.size() <= 0: # empty does not work?
		return
		
	# The two states between which we will interpolate
	# If no end_state exists, extrapolate up to a point
	# If no begin state exists, skip to end_state
	# var prev_state = null 	# Only relevant in extrapolation case
	var begin_state = null
	var end_state = null
	
	var render_time = ClientData.client_clock - ClientData.interpolation_offset

	# Find state immediately before client time
	var obsolete_states = -1
	for i in range(ClientData.player_buffer.size()):
		if ClientData.player_buffer[i]["timestamp"] < render_time:
			obsolete_states += 1
			begin_state = ClientData.player_buffer[i]
		else:
			break
			
	# Find state immediately ahead of client time
	for i in range(ClientData.player_buffer.size()-1, -1, -1): # Iterate to -1 to include index 0...
		if ClientData.player_buffer[i]["timestamp"] > render_time:
			end_state = ClientData.player_buffer[i]
		else:
			break
			
	
	#print("First in buffer: ", ClientData.player_buffer[0]["timestamp"],
	#	" Last in buffer: ", ClientData.player_buffer[-1]["timestamp"],
	#	" Client Time: ", client_time,
	#	" Count in buffer: ", len(ClientData.player_buffer))
	var new_state
	if begin_state == null and end_state == null:
		return
	elif begin_state != null and end_state == null:
		#if prev_state != null:
		#	new_state = extrapolate_players_state(begin_state, prev_state, client_time)
		#else:
		new_state = begin_state["player_info"]
	elif begin_state == null and end_state != null:
		new_state = end_state["player_info"]
	elif begin_state != null and end_state != null:
		new_state = interpolate_players_state(begin_state, end_state, render_time)
		
	update_players(new_state)
	
	# Get rid of old, unneeded states
	for i in range(obsolete_states):
		ClientData.player_buffer.pop_front()
	
	
func interpolate_players_state(begin, end, time) -> Dictionary:
	var new_state : Dictionary = {}
	var t = (time - begin["timestamp"]) / (end["timestamp"] - begin["timestamp"])
	for pid in begin["player_info"].keys():
		# Linear interpolation between 3-Vectors
		# TODO Linear interpolation not sensible for direction?
		#new_state[pid] = {
		#	"position" : linear_interpolation(time, begin["timestamp"], begin["player_info"].position, end["timestamp"], end["player_info"].position),
		#	"direction" : linear_interpolation(time, begin["timestamp"], begin["player_info"].direction, end["timestamp"], end["player_info"].direction)
		#}
		new_state[pid] = {}
		new_state[pid]["transform"] = begin["player_info"][pid]["transform"].interpolate_with(end["player_info"][pid]["transform"], t)
		
	return new_state


#func extrapolate_players_state(begin, prev_state, time) -> Dictionary:
#	return begin
#	# TODO Extrapolation on transforms
#	if time > begin["timestamp"] + ClientData.max_extrapolation_time_ms:
#		time = ClientData.max_extrapolation_time
#
#	# Yes its stupid shut up # TODO...?
#	return interpolate_players_state(prev_state, begin, time)


func update_players(new_state):
	for pid in new_state.keys():
		if get_node_or_null(str(pid)):
			if new_state[pid].has("transform"):
#				get_node(str(pid)).transform = new_state[pid]["transform"]
#				get_node(str(pid)).move_and_slide(new_state[pid]["transform"].origin)
#				get_node(str(pid)).transform = get_node(str(pid)).transform.interpolate_with(new_state[pid]["transform"], 1)
				get_node(str(pid)).server_reconcile(new_state[pid]["transform"])
			if new_state[pid].has("head_angle"):
				get_node(str(pid)).head_angle = new_state[pid]["head_angle"]
		else:
			var bot = Bot.instance()
			bot.set_name(str(pid))
			bot.transform = new_state[pid]["transform"]
			add_child(bot, true)
