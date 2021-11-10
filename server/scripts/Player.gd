extends "res://shared/scripts/BasePlayer.gd"

var player_buffer = []

#func _physics_process(delta):
#	save_location()

func save_location():
	if player_buffer.size() > 14: #TODO: adjust this depending on how far back a player can be killed (14 is just under 250ms worth @ 60hz)
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
			break
			
	for i in range(player_buffer.size()):
		if !after && timestamp < player_buffer[i]["timestamp"]:
			after_i = i
			after = player_buffer[i]
			break
			
			
	var before_time
	if (!!before && "timestamp" in before):
		before_time = before["timestamp"] * 1.0
	
	var after_time
	if (!!after && "timestamp" in after):
		after_time = after["timestamp"] * 1.0
		
	if before_time == null && after_time == null:
		return null
	if before_time == null:
		return after
	if after_time == null:
		return self.transform
	else:
		var interpolated_timestamp : float = (timestamp - float(before_time)) / (float(after_time) - float(before_time))
		var interpolated_transform = before["transform"].interpolate_with(after["transform"], interpolated_timestamp)
				
		if before:
			print("Before:       ", before_time, " -> ", before["transform"])	
			
		print("Interpolated: ", timestamp, " -> ", interpolated_transform)
		
		if after:
			print("After:        ", after_time, " -> ", after["transform"])
			
		return interpolated_transform
		
	#	if before == null || after == null:
	#		return null
	#	else:
	#		return after["transform"]
		
	
