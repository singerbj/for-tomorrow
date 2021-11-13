extends Node

func draw_line(from, to, color = Color(1, 1, 1), wait_time = 0.25):
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
	
	if wait_time > 0:
		var timer = Timer.new()
		timer.wait_time = wait_time
		timer.autostart = true
		timer.connect("timeout", self, "remove_line", [line, timer])
		self.add_child(timer)
	
	
func remove_line(line, timer):
	line.queue_free()
	timer.queue_free()
