extends Spatial

var head_angle : float setget set_head_angle

func set_head_angle(angle):
	head_angle = angle
	$Head.rotation_degrees.x = angle
