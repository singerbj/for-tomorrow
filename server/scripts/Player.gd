extends "res://shared/scripts/BasePlayer.gd"

var player_buffer = []
var stashed_transform = null
var stashed_camera_transform = null
var stashed_collision_transform = null

var is_dummy = false
# # Forces
# const ACC_GRAV = Vector3(0, -100, 0)
# const ACC_MAG_INPUT = 100
# const UP_DIR = Vector3(0, 1, 0)
# const SNAP = Vector3(0, -2, 0)
# const MAX_XZ_SPEED = 2
# const FRICTION_XZ = 10
# const FRICTION_Y = 1

#func _physics_process(delta):
#	save_location()

func save_location():
	if player_buffer.size() > 100: #TODO: adjust this depending on how far back a player can be killed (14 is just under 250ms worth @ 60hz)
		player_buffer.pop_back()
	
	var new_buffer_record = { "timestamp": OS.get_system_time_msecs(), "transform": self.transform, "camera_transform": $Camera.transform }
	if player_buffer.size() == 0 || player_buffer[0]["transform"] != new_buffer_record["transform"]:
		player_buffer.push_front(new_buffer_record)
#
#	for i in range(player_buffer.size()):
#		print(str(player_buffer[i]["timestamp"]) + " => " + str(player_buffer[i]["transform"]))
#
#	print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")

func stash_current_transform():
	self.stashed_transform = self.transform
	self.stashed_camera_transform = $Camera.transform

func revert_to_stashed_transform():
	self.transform = self.stashed_transform
	$Camera.transform = self.stashed_camera_transform
	self.stashed_transform = null
	self.stashed_camera_transform = null

func move_to_interpolated_location(timestamp : int, debug : bool):
	var result = get_interpolated_location(timestamp, debug)
	if debug:
		print("Before transform ", self.transform)
	self.transform = result[0]
	$Camera.transform = result[1]
	if debug:
		print("After transform ", self.transform)

	DrawLine3d.draw_line_3d(self.transform.origin, Vector3(self.transform.origin.x, self.transform.origin.y + 10, self.transform.origin.z), Color(0, 1, 0), 5)

func get_collision():
	return $Collision

#func create_dummy_at_interpolated_location(Player, timestamp : int, debug : bool):
#	var dummy = Player.instance()
#	get_tree().get_root().add_child(dummy)
#	var result = get_interpolated_location(timestamp, debug)
#	dummy.transform = result[0]
#	dummy.get_camera().transform = result[1]
#	dummy.is_dummy = true
#	dummy.get_collision().disabled = true
#	return dummy
	

func get_interpolated_location(timestamp : int, debug : bool):
	var before
	var after
	var before_i = -1
	var after_i = -1
	var before_time
	var after_time
	
#	var s = "["
#	for i in range(player_buffer.size()):
#		s += str(player_buffer[i]["timestamp"]) + ", "	
#	s += "]"
#	print(s)

#	if debug:
#		for i in range(player_buffer.size()):
#			print(player_buffer[i]["timestamp"], " ___ ", player_buffer[i]["transform"])
	
	for i in range(player_buffer.size()):
		if timestamp >= player_buffer[i]["timestamp"]:
			before_i = i
			before = player_buffer[i]
			break

	for i in range(player_buffer.size() - 1, -1, -1):
		if timestamp <= player_buffer[i]["timestamp"]:
			after_i = i
			after = player_buffer[i]
			break
			
	if (!!before && "timestamp" in before):
		before_time = before["timestamp"] * 1.0
	
	if (!!after && "timestamp" in after):
		after_time = after["timestamp"] * 1.0
		
	if before_time == null && after_time == null:
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PROBLEM 1")
		return [self.transform, $Camera.transform]
	elif before_time == null:
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PROBLEM 2")
		return [self.transform, $Camera.transform]
	elif after_time == null:
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PROBLEM 3")
		return [self.transform, $Camera.transform]
	else:
		var interpolated_weight : float
		var interpolated_timestamp : int
		if after_time != before_time:
			interpolated_weight = (timestamp - float(before_time)) / (float(after_time) - float(before_time))
		else:
			interpolated_weight = 1
			
		var interpolated_transform = before["transform"].interpolate_with(after["transform"], interpolated_weight)
		var interpolated_camera_transform = before["camera_transform"].interpolate_with(after["camera_transform"], interpolated_weight)
		
		if debug:	
			if before:
				print("Before:       ", before_i, " ~ ", before_time, " -> ", before["transform"])	
			print("Interpolated: ", "-", " ~ ", timestamp, " -> ", interpolated_transform)
			if after:
				print("After:        ", after_i, " ~ ", after_time, " -> ", after["transform"])

		
		return [interpolated_transform, interpolated_camera_transform]
		
	
