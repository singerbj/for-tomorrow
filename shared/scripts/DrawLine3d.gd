extends Node2D

#class Line:
#	var start
#	var end
#	var line_color
#	var time
#
#	func _init(start, end, line_color, time):
#		self.start = start
#		self.end = end
#		self.line_color = line_color
#		self.time = time
#
#var lines = []
#
#func _process(delta):
#	var to_delete = []
#	for i in lines.size():
#		if (lines[i].time + 300) < OS.get_system_time_msecs():
#			to_delete.append(i)
#
#	for i in to_delete.size():
#		lines.remove(i)
#
#
#	if(len(lines) > 0):
#		update() #Calls _draw
#
#func _draw():
#	var Cam = get_viewport().get_camera()
#	for line in lines:
#		var ScreenPointstart = Cam.unproject_position(line.start)
#		var ScreenPointend = Cam.unproject_position(line.end)
#
#		draw_line(ScreenPointstart, ScreenPointend, line.line_color)
#
#func draw_line(start, end, line_color, time = OS.get_system_time_msecs()):
#	lines.append(Line.new(start, end, line_color, time))
#
#func draw_ray(start, Ray, line_color, time = OS.get_system_time_msecs()):
#	lines.append(Line.new(start, start + Ray, line_color, time))
var DEFAULT_THICKNESS = 4.0

class Line:
	var color
	var thickness = 4.0
	var start
	var end
	var time
	
var lines = []
var camera

func _ready():
	set_process(true)

func _draw():
	for line in lines:
		if !camera:
			camera = get_viewport().get_camera()
			
		var adjusted_start = camera.unproject_position(line.start)
		var adjusted_end = camera.unproject_position(line.end)
		
		draw_line(adjusted_start, adjusted_end, line.color, line.thickness)

func _process(delta):
	var to_delete = []
	for i in lines.size():
		var line = lines[i]
		line.thickness -= 0.1
		if line.thickness < 0:
			to_delete.append(i)

	to_delete.invert()
	for line_id in to_delete:
		lines.remove(line_id)
	
	update()

func draw_line_3d(start, end, color, thickness = DEFAULT_THICKNESS, time = OS.get_system_time_msecs()):
	var new_line = Line.new()
	new_line.color = color
	new_line.start = start
	new_line.end = end
	new_line.thickness = thickness
	new_line.time = time
	lines.append(new_line)
