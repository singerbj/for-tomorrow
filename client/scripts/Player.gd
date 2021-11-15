extends "res://shared/scripts/BasePlayer.gd"

const CAM_ACCEL = 40

func _ready() -> void:
	$CanvasLayer/Control/Label.text = weapon
	$CanvasLayer/Control/Hitmarker.set("modulate", Color(1, 1, 1, 0))
	$Camera.fov = ClientData.PLAYER_CAMERA_DEFAULT_FOV
	
	ads_tween = Tween.new()
	add_child(ads_tween)


func _process(delta):
	$CanvasLayer/Control/Label2.set_text(str(Engine.get_frames_per_second()))
	$CanvasLayer/Control/State.text = "State:" + str(self.State.keys()[self.state])
	
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	var desired_cam_location = Vector3(self.global_transform.origin.x, self.global_transform.origin.y + 2.6, self.global_transform.origin.z)
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		$Camera.set_as_toplevel(true)
		$Camera.global_transform.origin = $Camera.global_transform.origin.linear_interpolate(desired_cam_location, CAM_ACCEL * delta)
		$Camera.rotation.y = rotation.y
	else:
		$Camera.set_as_toplevel(false)
	
func _physics_process(delta):
	var alpha = $CanvasLayer/Control/Hitmarker.get("modulate").a
	$CanvasLayer/Control/Hitmarker.set("modulate", Color(1, 1, 1, alpha - 0.1))
	
func set_up(connect_info : Dictionary):
	# Called in server.confirm_connection
	transform = Utility.transform_from_array(connect_info["transform"])
	velocity = Utility.vec3_from_array(connect_info["velocity"])

	
func show_hitmarker():
	$CanvasLayer/Control/Hitmarker.set("modulate", Color(1, 1, 1, 1))

# TODO: use the shot manager for this or something
#var ray_length = 1000

func aim():
#	$Camera/Gun.translation.x = 0.0008	
#	$Camera/Gun.translation.y = -0.03
	if !aiming:
		aiming = true
		$CanvasLayer/Control/TextureRect.visible = false
		ads_tween.interpolate_property(
			$Camera/Gun, "translation", 
			$Camera/Gun.transform.origin, Vector3(0.0005, -0.0275, $Camera/Gun.transform.origin.z), 0.18,
			Tween.TRANS_QUAD, Tween.EASE_IN)
		ads_tween.interpolate_property(
			$Camera, "fov", 
			$Camera.fov, ClientData.PLAYER_CAMERA_ADS_FOV, 0.18,
			Tween.TRANS_QUAD, Tween.EASE_IN)		
		ads_tween.start()
	
func unaim():
#	$Camera/Gun.translation.x = 0.06
#	$Camera/Gun.translation.y = -0.06
	if aiming:		
		aiming = false
		$CanvasLayer/Control/TextureRect.visible = true
		ads_tween.interpolate_property(
			$Camera/Gun, "translation", 
			$Camera/Gun.transform.origin, Vector3(0.06, -0.06, $Camera/Gun.transform.origin.z), 0.18,
			Tween.TRANS_QUAD, Tween.EASE_IN)
		ads_tween.interpolate_property(
			$Camera, "fov", 
			$Camera.fov, ClientData.PLAYER_CAMERA_DEFAULT_FOV, 0.18,
			Tween.TRANS_QUAD, Tween.EASE_IN)		
		ads_tween.start()
	
func fire_shot():
	pass
#	var from = $Camera.project_ray_origin(get_viewport().get_mouse_position())
#	var to = from + $Camera.project_ray_normal(get_viewport().get_mouse_position()) * ray_length
#
#	var color = Color(0.5, 0.5, 0.5)
#
#	var line = ImmediateGeometry.new()
#	var mat = SpatialMaterial.new()
#	mat.flags_unshaded = true
#	mat.vertex_color_use_as_albedo = true
#	line.material_override = mat
#
#	get_node('/root').add_child(line)
#	line.clear()
#	line.begin(Mesh.PRIMITIVE_LINE_STRIP)
#	line.set_color(color)
#	line.add_vertex(from)
#	line.add_vertex(to)
#	line.end()
	
