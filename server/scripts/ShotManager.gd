extends Spatial

var lines
var shots
var ray_length = 10000

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
	
func fire_shots(shots_to_fire):
	clear_shots()
	
	# save the current player location
	for pid in ServerData.players:
		var current_player = ServerData.players[pid]
		current_player.stash_current_transform()
	
	var players_who_hit = []
#	var players_who_got_hit = []
	for shot in shots_to_fire:
		# move players to the correct location to do hit detection at the correct time
		for pid in ServerData.players:
			var current_player = ServerData.players[pid]			
			current_player.move_to_interpolated_location(shot["input"]["timestamp"])
			
		var hit = fire_shot(shot["pid"], ServerData.players[shot["pid"]], shot["input"]["timestamp"])
		if hit && !players_who_hit.has(shot["pid"]):
			players_who_hit.append(shot["pid"])
			
	# go back to the saved player location
	for pid in ServerData.players:
		var current_player = ServerData.players[pid]
		current_player.revert_to_stashed_transform()
			
	return players_who_hit
	
var player_last_shots = {}
func fire_shot(pid, player, timestamp):
	var now = OS.get_system_time_msecs()
	#TODO: this all has to depend on the gun, not a random timeout
	if !(pid in player_last_shots) || (now - 10) > player_last_shots[pid]:
		
#		for other_pid in ServerData.players:
#			if pid != other_pid:			
#				ServerData.players[other_pid].get_interpolated_location(timestamp)				
#		print(str(timestamp) + " ~ " + str(now))
#		if timestamp - now >= 0:
#			print("====> CLIENT IS AHEAD WTF... by " + str(timestamp - now) + " ms")
#		print("%%%%%%%%%%%%%%%%%%%%%%%%")
#		print("")
#		print("")

		
		
		player_last_shots[pid] = now
		var from = player.get_camera().project_ray_origin(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2))
		var to = from + player.get_camera().project_ray_normal(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)) * ray_length
		
		# use global coordinates, not local to node
		var space_state = get_world().direct_space_state
		var all_results = []
		var all_colliders = []
		var hit_player = false
		var continue_casting = true
		while(continue_casting):		
			var result = space_state.intersect_ray(from, to, [self] + all_colliders)
			print(result)
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
		
		shots.append({ 'from': from, 'to': to, 'color': color })
		
		return hit_player
		
	
	
				
