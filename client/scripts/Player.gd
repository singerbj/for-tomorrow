extends "res://shared/scripts/BasePlayer.gd"


func _ready() -> void:
	$CanvasLayer/Control/Label.text = weapon
	$CanvasLayer/Control/Hitmarker.set("modulate", Color(1, 1, 1, 0))
	$Camera.fov = ClientData.PLAYER_CAMERA_DEFAULT_FOV
	
	ads_tween = Tween.new()
	add_child(ads_tween)

func _process(delta):
	$Camera.make_current()
	$CanvasLayer/Control/Label2.set_text(str(Engine.get_frames_per_second()))
	
func _physics_process(delta):
	var alpha = $CanvasLayer/Control/Hitmarker.get("modulate").a
	$CanvasLayer/Control/Hitmarker.set("modulate", Color(1, 1, 1, alpha - 0.1))
	
func set_up(connect_info : Dictionary):
	# Called in server.confirm_connection
	transform = Utility.transform_from_array(connect_info["transform"])
	velocity = Utility.vec3_from_array(connect_info["velocity"])

func construct(block_id):
	var c = $RayCast.get_collider()
	var target : Vector3
	if c is GridMap:
		var pos : Vector3 = $RayCast.get_collision_point()
		var normal : Vector3 = $RayCast.get_collision_normal()
		target = c.world_to_map(pos + normal * 0.5)
		#c.set_cell_item(target.x, target.y, target.z, 0)
	Server.construct(target, block_id)
	
	
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
	
var player_last_shot = 0
func fire_shot():
	pass
#	var now = OS.get_system_time_msecs()
#	if (now - 100) > player_last_shot:
#		player_last_shot = now
#		var from = $Camera.project_ray_origin(get_viewport().get_mouse_position())
#		var to = from + $Camera.project_ray_normal(get_viewport().get_mouse_position()) * 10000
#
#		var color = Color(0.5, 0.5, 0.5)
#
#		var line = ImmediateGeometry.new()
#		var mat = SpatialMaterial.new()
#		mat.flags_unshaded = true
#		mat.vertex_color_use_as_albedo = true
#		line.material_override = mat
#
#		get_node('/root').add_child(line)
#		line.clear()
#		line.begin(Mesh.PRIMITIVE_LINE_STRIP)
#		line.set_color(color)
#		line.add_vertex(from)
#		line.add_vertex(to)
#		line.end()
	
