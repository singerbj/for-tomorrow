extends Spatial

var Player = preload("res://scenes/Player.tscn")

var lines
var shots
var ray_length = 100

func _ready():
	lines = []
	shots = []
	

var time = 0
func _process(delta):
	time += delta;
	if (time / 2) > 1:
		lines = []
	

func clear_shots():
	for line in lines:
		line.queue_free()
	lines = []
	shots = []
	
func get_shots(): #YYYYYYEEEAAAAAAAHHHHHHH
	return shots
	
#func fire_shots(shots_to_fire):
#	clear_shots()
#
#	# save the current player location
#	for pid in ServerData.players:
#		var player = ServerData.players[pid]
#		player.stash_current_transform()
#
#	var players_who_hit = []
##	var players_who_got_hit = []
#	for shot in shots_to_fire:
#		if can_fire(shot["pid"]):
#			# move players to the correct location to do hit detection at the correct time
#			for pid in ServerData.players:
#				var player = ServerData.players[pid]
#
#				if pid != shot["pid"]:
#					print("==============================")				
#					player.move_to_interpolated_location(shot["input"]["timestamp"] - (SharedData.INTERPOLATION_OFFSET * 5), true)
#					print("==============================")				
#
#				else:				
#					player.move_to_interpolated_location(shot["input"]["timestamp"] - (SharedData.INTERPOLATION_OFFSET * 5), false)
#
#			print("------------->", ServerData.players[shot['pid']])
#			var hit = fire_shot(shot["pid"], ServerData.players[shot["pid"]])
#			if hit && !players_who_hit.has(shot["pid"]):
#				players_who_hit.append(shot["pid"])
#
#	# go back to the saved player location
#	var player_locations = []
#	for pid in ServerData.players:
#		var player = ServerData.players[pid]
#		player_locations.append(player.transform.origin)
#		player.revert_to_stashed_transform()
#
#	return [players_who_hit, player_locations]

func fire_shots(shots_to_fire):
	clear_shots()
	
	var players_who_hit = []
#	var players_who_got_hit = []
	for shot in shots_to_fire:
		if can_fire(shot["pid"]):
			var dummys = []
			var dummy_shooter
			# move players to the correct location to do hit detection at the correct time
			for pid in ServerData.players:
				var player = ServerData.players[pid]
				
				if pid != shot["pid"]:
					var dummy = player.create_dummy_at_interpolated_location(Player, shot["input"]["timestamp"] - (SharedData.INTERPOLATION_OFFSET * 4), false)
					dummys.append(dummy)
				else:				
					dummy_shooter = player.create_dummy_at_interpolated_location(Player, shot["input"]["timestamp"] - (SharedData.INTERPOLATION_OFFSET * 4), false)
					
			var hit = fire_shot(shot["pid"], ServerData.players[shot["pid"]], dummy_shooter, dummys)
			if hit && !players_who_hit.has(shot["pid"]):
				players_who_hit.append(shot["pid"])
			
			dummy_shooter.queue_free()
			for dummy in dummys:
				if !hit:
					dummy.queue_free()
				LineDrawer.draw_line(dummy.transform.origin, Vector3(dummy.transform.origin.x, dummy.transform.origin.y + 4, dummy.transform.origin.z), Color(0.8, 0.5, 0), -1)
			
	return [players_who_hit, []]
	
var player_last_shots = {}
func can_fire(pid : int):
	return !(pid in player_last_shots) || (OS.get_system_time_msecs() - 0) > player_last_shots[pid]
		
func fire_shot(pid, player, dummy_shooter, dummys):
	print('starting raycast')
	#TODO: this all has to depend on the gun, not a random timeout
		
#		for other_pid in ServerData.players:
#			if pid != other_pid:			
#				ServerData.players[other_pid].get_interpolated_location(timestamp)				
#		print(str(timestamp) + " ~ " + str(now))
#		if timestamp - now >= 0:
#			print("====> CLIENT IS AHEAD WTF... by " + str(timestamp - now) + " ms")
#		print("%%%%%%%%%%%%%%%%%%%%%%%%")
#		print("")
#		print("")
	
	player_last_shots[pid] = OS.get_system_time_msecs()
	var from = dummy_shooter.get_camera().project_ray_origin(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2))
	var to = from + dummy_shooter.get_camera().project_ray_normal(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)) * ray_length
	
	# use global coordinates, not local to node
	var space_state = get_world().direct_space_state
	var all_results = []
	var all_colliders = []
	var hit_player = false
	var continue_casting = true
	
	var players_array = []
	for player in ServerData.players:
		players_array.append(player)
	
	while(continue_casting):		
		var result = space_state.intersect_ray(from, to, [dummy_shooter, player] + players_array + all_colliders)
		if 'collider_id' in result:
			all_results.append(result)
			all_colliders.append(result.collider)
		else:
			continue_casting = false
		
	var color = Color(0, 0, 0.5)
	if all_results.size() > 0:
		color = Color(0.5, 0, 0)
		to = all_results[0].position
		
		if "is_player" in all_colliders[0]:
			hit_player = true
			Color(0, 0.5, 0.5)
	
	shots.append({ 'from': from, 'to': to, 'color': color })
	if hit_player:
		LineDrawer.draw_line(from, to, color, -1)
	else:
		LineDrawer.draw_line(from, to, color)
	print('ending raycast')
	return hit_player
	

				
