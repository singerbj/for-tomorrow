extends "res://shared/scripts/BasePlayer.gd"

var player_buffer = []

#func _physics_process(delta):

func save_location():
	if player_buffer.size() > 50:
		player_buffer.pop_back()
	
	player_buffer.push_front({ "timestamp": OS.get_system_time_msecs(), "transform": self.transform })
#
#	for i in range(player_buffer.size()):
#		print(str(player_buffer[i]["timestamp"]) + " => " + str(player_buffer[i]["transform"]))
#
#	print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")

func get_interpolated_location(timestamp : int):
	var before
	var after
	var before_i = -1
	var after_i = -1
	
	var s = "["
	for i in range(player_buffer.size()):
		s += str(player_buffer[i]["timestamp"]) + ", "	
	s += "]"
	print(s)
	
	for i in range(player_buffer.size()):
		if !before && timestamp >= player_buffer[i]["timestamp"]:
			before_i = i
			before = player_buffer[i]
		if !!after && timestamp < player_buffer[i]["timestamp"]:
			after_i = i
			after = player_buffer[i]
			
			
	var before_time = null
	if (!!before && "timestamp" in before):
		before_time = before["timestamp"]
	
	var after_time = null
	if (!!after && "timestamp" in after):
		after_time = after["timestamp"]
		
	print(str(before_time) + "(" + str(before_i) + ") => " + str(timestamp) + " => " + str(after_time) + "(" + str(after_i) + ")")
	
#	if before == null || after == null:
#		return null
#	else:
#		return after["transform"]
			
			
	
