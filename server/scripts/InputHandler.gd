extends Node
var FRICTION_MULT = 0.1				# Multiplied with velocity for friction

func process_client_input(delta, buffer):
	# process movement input
	for pid in buffer.keys():
		# deep copy to not modify original buffer object
		var queue = buffer[pid].duplicate(true)
		
		var input
		while !queue.empty():			
			input = queue.pop_front()
			execute_client_input(delta, pid, ServerData.players[pid], input)
		
		if input:
			var input_data = {}
			input_data["transform"] = Utility.array_from_transform(ServerData.players[pid].transform)
			input_data["velocity"] = Utility.array_from_vec3(ServerData.players[pid].velocity)
			input_data["head_angle"] = ServerData.players[pid].head_angle
			# input in this case refers to the last input out of the while loop
			get_node("..").send_input(pid, input, input_data)
	
	# process shooting input	
	var shots_to_process = []
	for pid in buffer.keys():	
		var queue = buffer[pid].duplicate(true)
		var input
		while !queue.empty():			
			input = queue.pop_front()
			if input["Buttons"].has("fire"):
				shots_to_process.push_back({ "pid": pid, "input": input })
				
	process_client_shots(shots_to_process)

func execute_client_input(delta, pid, player, input):
	player.rotate_player(input["Motion"])
	
	var move_vector = Vector3(0, 0, 0)
	var jump = false
	var fire = false
	var aim = false
	for button in input["Buttons"]:
		if button in ["m_forward", "m_backward", "m_left", "m_right"]:
			if button == "m_forward":
				move_vector.z -= 1
			if button == "m_backward":
				move_vector.z += 1
			if button == "m_left":
				move_vector.x -= 1
			if button == "m_right":
				move_vector.x += 1
		elif button == "jump":
			jump = true
		elif button == "aim":
			player.aiming = true
			
	move_vector = move_vector.normalized()
	
	player.move(move_vector, input["delta"], jump)	
		
func process_client_shots(shots_to_fire):
	var players_who_hit = ShotManager.fire_shots(shots_to_fire)
		
#	print(players_who_hit)
	for pid in ServerData.players:
		get_node("..").send_shots(pid, ShotManager.get_shots(), players_who_hit.has(pid))
