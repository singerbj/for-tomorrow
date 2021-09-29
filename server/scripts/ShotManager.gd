extends Node

var lines
func _ready():
	lines = []

#func _process(delta):
#	# remove lines

func fire_shot(player):
	draw_line(player.transform.basis, player.transform.basis, line.color, line.thickness)

		
func draw_line(id, vector_a, vector_b, color, thickness):

	var new_line = Line.new()
	new_line.id = id
	new_line.color = color
	new_line.a = player.unproject_position(vector_a)
	new_line.b = Camera_Node.unproject_position(vector_b)
	new_line.thickness = thickness

	lines.append(new_line)
				
