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
	
var player_last_shots = {}
func fire_shot(pid, player):
	var now = OS.get_system_time_msecs()
	if !(pid in player_last_shots) || (now - 300) > player_last_shots[pid]:
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
		
	
	
				
