extends Node
	
var idle_count = 0
	
func _input(event) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		ClientData.total_mouse_motion += event.relative

func process_input(delta):
	var button_list = []
	if !ClientData.chat.is_open:
		if Input.is_action_pressed("m_forward"):
			button_list.append("m_forward")
		if Input.is_action_pressed("m_backward"):
			button_list.append("m_backward")
		if Input.is_action_pressed("m_left"):
			button_list.append("m_left")
		if Input.is_action_pressed("m_right"):
			button_list.append("m_right")
		if Input.is_action_pressed("jump"):
			button_list.append("jump")
		if Input.is_action_pressed("fire"):
			button_list.append("fire")
		if Input.is_action_pressed("aim"):
			button_list.append("aim")
			
		if Input.is_action_just_released("scroll_down"):
			button_list.append("scroll_down")
		if Input.is_action_just_released("scroll_up"):
			button_list.append("scroll_up")
		if Input.is_action_just_pressed("interact"):
			button_list.append("interact")
	if Input.is_action_just_pressed("exit"):
		button_list.append("exit")
		get_tree().quit()
	
#	if button_list.size() > 1:
#		idle_count = 0
#	else:
#		# bot mode
#		if idle_count > 500:
#			idle_count = 100
#
#		idle_count += 1
#
#		if idle_count > 300:
#			button_list = ["m_left"]
#		elif idle_count > 100:
#			button_list = ["m_right"]
		
	var input = { "Buttons" : button_list, "delta" : delta, "timestamp": ClientData.client_clock, "Motion" : ClientData.total_mouse_motion }
	
	ClientData.total_mouse_motion = Vector2(0, 0)
	
	var input_data = predict_input(input)
	var input_id = push_to_input_queue(input, input_data)
	
#	yield(get_tree().create_timer(0.75), "timeout")
	Server.report_input(input_id, input)


func predict_input(input : Dictionary):
	# Apply the the given input to the player state, in hopes that it matches
	# what the server will do.
	# Keep information about this input so we can verify it later, when the
	# server responds: input number (for matching), input results (for verification)
	var P = get_node("../Player")
	if P == null:
		return
		
	P.rotate_player(input["Motion"])
	
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
		elif button == "fire":
			fire = true	
		elif button == "aim":
			aim = true
			
	if aim:
		P.aim()
	else:
		P.unaim()
		
	if fire:
		P.fire_shot()
			
	move_vector = move_vector.normalized()
	P.set_input_values(move_vector, jump)
#	P.move(move_vector, input["delta"], jump)
		
	var input_data = {
		"transform" : Utility.array_from_transform(P.transform),
		"velocity" : Utility.array_from_vec3(P.velocity),
		"head_angle" : P.head_angle
	}
	return input_data
			

func push_to_input_queue(input : Dictionary, input_data) -> int:
	# Caches input in the input buffer (a queue, first in first out)
	# along with an id, which it assigns. The ID is returned. This ID
	# will later be used to match it with the answer from the server for
	# verification
	ClientData.input_counter += 1
	ClientData.input_queue.push_back({"input_id" : ClientData.input_counter, "input" : input, "input_data" : input_data, "timestamp" : ClientData.client_clock })
	return ClientData.input_counter
	
func recieve_shots(shots : Array, hit : bool, player_locations : Array):
	#TODO move this to shot manager at some point
	for shot in shots:
		DrawLine3d.draw_line_3d(shot.from, shot.to, shot.color)
	
	for location in player_locations:
		DrawLine3d.draw_line_3d(location, Vector3(location.x, location.y + 4, location.z), Color(0, 1, 0))
		
	#TODO show hitmarker if player got a hit
	var P = get_node("../Player")
#	print(P, hit)
	if P == null:
		return
	elif hit:
		P.show_hitmarker()
		
func recieve_input(input : Dictionary, server_input_data : Dictionary):
	# Search for matching input id in the input queue. Discard all older inputs,
	# then verify that the input_data the server sent back and that we predicted
	# matches
	# if not, set server's input_data as current data
	
	var input_id = input["input_id"]
	if ClientData.input_queue.empty():
		return
		
	var input_queue_data
	while true:
		if ClientData.input_queue.empty():
			break
			
		input_queue_data = ClientData.input_queue.pop_front()
		
		if input_queue_data["input_id"] >= input_id:
			break
		
		
	if input_queue_data["input_id"] > input_id:
		push_warning("WARNING: Missing data in input queue")
		# put back
		ClientData.input_queue.push_front(input_queue_data)
		return
			
	var local_input_data = input_queue_data["input_data"]
	
	#print("Input ", input_queue_data["input_id"], " local: ", local_input_data)
	#print("Input ", input_id, " server: ", server_input_data)
	
	var diff = false
	var source = ""

	for key in server_input_data.keys():
#		if key == "head_angle": # TODO: remove this?
#			if abs(local_input_data[key] - server_input_data[key]) > ClientData.EPSILON:
#				diff = true
#				break
#			else:
#				continue
		
		if key != "head_angle": # TODO: remove this?
			for i in range(len(local_input_data[key])):
				if abs(local_input_data[key][i] - server_input_data[key][i]) > ClientData.EPSILON:
					diff = true
					source = key
					break

	if not diff:
		return
	else:
		ClientData.prediction_errors += 1
		# TODO: turn this back on or track it better?
		print("Prediction error in input ", input_id, " (match ", input_queue_data["input_id"], ") for '" + source + "', Error rate ",
			100 * ClientData.prediction_errors / float(ClientData.input_counter), "%, Total: ", ClientData.prediction_errors,
			", Inputs in queue: ", len(ClientData.input_queue))
		get_node("../Player").transform = Utility.transform_from_array(server_input_data["transform"])
		get_node("../Player").velocity = Utility.vec3_from_array(server_input_data["velocity"])
		get_node("../Player").head_angle = server_input_data["head_angle"]

		# "Replay" input data up to present to regain consistency
		for i in range(len(ClientData.input_queue)):
			var corrected_input_data = predict_input(ClientData.input_queue[i]["input"])
			ClientData.input_queue[i]["input_data"] = corrected_input_data

#
## TODO: use the shot manager for this or something
#func fire_shot(from, to, color):
#	DrawLine3d.draw_line_3d(from, to, color)

#func legacy_predict_client_input(input) -> Array:
#	# TODO: Abstract this
#	# Also, this isn't yet being synced with the server. So this isnt prediction,
#	# this is "actual" input!
#	for button in input["Buttons"]:
#		if button == "scroll_down":
#			var i = weapon_list.find(weapon)
#			i -= 1
#			i = i % len(weapon_list)
#			weapon = weapon_list[i]
#			$CanvasLayer/Control/Label.text = weapon
#
#		elif button == "scroll_up":
#			var i = weapon_list.find(weapon)
#			i += 1
#			i = i % len(weapon_list)
#			weapon = weapon_list[i]
#			$CanvasLayer/Control/Label.text = weapon
#
#		elif button == "interact":
#			# TODO It might make sense to not predict blocks
#			match weapon:
#				"placer":
#					construct(0)
#				"shovel":
#					construct(-1)
#		elif button == "exit":
#			# TODO Cleanup before leaving
#			get_tree().quit()
#
#	#transform = transform.orthonormalized()
#	#var input_data = {}
#	#input_data["transform"] = Utility.array_from_transform(transform)
#	#input_data["velocity"] = Utility.array_from_vec3(velocity)
#	return input_data







	
#	var errors = []
#	# 1. Head angle
#	if abs(local_input_data["head_angle"] - server_input_data["head_angle"]) > ClientData.EPSILON:
#		# Apply correction throughout the stack
#		var diff = server_input_data["head_angle"] - local_input_data["head_angle"]
#		for i in range(len(ClientData.input_queue)):
#			ClientData.input_queue[i]["input_data"]["head_angle"] += diff
#
#		errors.append("head angle")
#
#	# 2. velocity
#	var vel_diff = Utility.vec3_from_array(server_input_data["velocity"]) - local_input_data["velocity"]
#	if vel_diff.length() > ClientData.EPSILON:
#		# Apply correction throughout the stack
##		for i in range(len(ClientData.input_queue)):
##			ClientData.input_queue[i]["input_data"]["velocity"] += vel_diff
#
#		errors.append("velocity")
#
#	# 3. Position and rotation
#	var diff = false
#	var transf = Utility.array_from_transform(local_input_data["transform"])
#	for i in range(12):
#		if abs(transf[i] - server_input_data["transform"][i]) > ClientData.EPSILON:
#			diff = true
#			break
#
#	if diff == true:
#		var correct = Utility.transform_from_array(server_input_data["transform"])
#		var orig_diff = correct.origin - local_input_data["transform"].origin
#		var bx_diff = correct.basis.x - local_input_data["transform"].basis.x
#		var by_diff = correct.basis.y - local_input_data["transform"].basis.y
#		var bz_diff = correct.basis.z - local_input_data["transform"].basis.z
#
##		for i in range(len(ClientData.input_queue)):
##			ClientData.input_queue[i]["input_data"]["transform"].origin += orig_diff
##			ClientData.input_queue[i]["input_data"]["transform"].basis.x += bx_diff
##			ClientData.input_queue[i]["input_data"]["transform"].basis.y += by_diff
##			ClientData.input_queue[i]["input_data"]["transform"].basis.z += bz_diff
#
#		errors.append("transform")
#
#	if not errors.empty():
#		if "head angle" in errors:
#			#get_node("../Player").head_angle = ClientData.input_queue[-1]["input_data"]["head_angle"]
#			get_node("../Player").head_angle = server_input_data["head_angle"]
#		if "velocity" in errors:
##			get_node("../Player").velocity = ClientData.input_queue[-1]["input_data"]["velocity"]
#			get_node("../Player").velocity = Utility.vec3_from_array(server_input_data["velocity"])
#		if "transform" in errors:
##			get_node("../Player").transform = ClientData.input_queue[-1]["input_data"]["transform"]
#			get_node("../Player").transform = Utility.transform_from_array(server_input_data["transform"])
#
#		ClientData.input_queue = []
#		ClientData.prediction_errors += 1
#		print("Prediction error in ", input_id, ": ", errors)








