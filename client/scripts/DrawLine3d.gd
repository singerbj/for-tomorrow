extends Node2D

class Line:
	var Start
	var End
	var LineColor
	var Time
	
	func _init(Start, End, LineColor, Time):
		self.Start = Start
		self.End = End
		self.LineColor = LineColor
		self.Time = Time

var Lines = []
var RemovedLine = false

func _process(delta):
	for i in range(len(Lines)):
		Lines[i].Time -= delta
	
	if(len(Lines) > 0 || RemovedLine):
		update() #Calls _draw
		RemovedLine = false

func _draw():
	var Cam = get_viewport().get_camera()
	for i in range(len(Lines)):
		var ScreenPointStart = Cam.unproject_position(Lines[i].Start)
		var ScreenPointEnd = Cam.unproject_position(Lines[i].End)
		
		#Dont draw line if either start or end is considered behind the camera
		#this causes the line to not be drawn sometimes but avoids a bug where the
		#line is drawn incorrectly
		if(Cam.is_position_behind(Lines[i].Start) ||
			Cam.is_position_behind(Lines[i].End)):
			continue
		
		draw_line(ScreenPointStart, ScreenPointEnd, Lines[i].LineColor)
	
	#Remove lines that have timed out
	var i = Lines.size() - 1
	while (i >= 0):
		if(Lines[i].Time < 0.0):
			Lines.remove(i)
			RemovedLine = true
		i -= 1

func DrawLine(Start, End, LineColor, Time = 0.0):
	Lines.append(Line.new(Start, End, LineColor, Time))

func DrawRay(Start, Ray, LineColor, Time = 0.0):
	Lines.append(Line.new(Start, Start + Ray, LineColor, Time))

