extends Spatial

var lines
var shots
var ray_length = 10000

func _ready():
	lines = []
	shots = []
	

#func _process(delta):
#	# remove lines

func clear_shots():
	for line in lines:
		line.queue_free()
	lines = []
	shots = []
	
func get_shots(): #YYYYYYEEEAAAAAAAHHHHHHH
	return shots
	
func fire_shot(player):
	var from = player.get_camera().project_ray_origin(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2))
	var to = from + player.get_camera().project_ray_normal(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)) * ray_length
	
	# use global coordinates, not local to node
	var space_state = get_world().direct_space_state
	var all_results = []
	var all_colliders = []
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
	
	draw_line(from, to, color)

		
func draw_line(from, to, color):
	var line = ImmediateGeometry.new()
	var mat = SpatialMaterial.new()
	mat.flags_unshaded = true
	mat.vertex_color_use_as_albedo = true
	line.material_override = mat
	
	get_node('/root').add_child(line)
	line.clear()
	line.begin(Mesh.PRIMITIVE_LINE_STRIP)
	line.set_color(color)
	line.add_vertex(from)
	line.add_vertex(to)
	line.end()

	lines.append(line)
	shots.append({ 'from': from, 'to': to, 'color': color })
				
