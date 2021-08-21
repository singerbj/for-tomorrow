extends Node
var FRICTION_MULT = 0.1				# Multiplied with velocity for friction


func process_client_input(buffer):
	for pid in buffer.keys():
		# deep copy to not modify original buffer object
		var queue = buffer[pid].duplicate(true)
		
		var input
		while not queue.empty():
			input = queue.pop_front()
			execute_client_input(ServerData.players[pid], input)
		
		if input:
			var input_data = {}
			input_data["transform"] = Utility.array_from_transform(ServerData.players[pid].transform)
			input_data["velocity"] = Utility.array_from_vec3(ServerData.players[pid].velocity)
			input_data["head_angle"] = ServerData.players[pid].head_angle
			# input in this case refers to the last input out of the while loop
			get_node("..").send_back_input_data(pid, input, input_data)
	

func execute_client_input(P, input):
	P.rotate_player(input["Motion"])
	
	var move_vector = Vector3(0, 0, 0)
	var jump = false
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
				
	move_vector = move_vector.normalized()
	
	P.move(move_vector, input["delta"], jump)	

























