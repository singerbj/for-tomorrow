extends KinematicBody

const ACC_GRAV = Vector3(0, -100, 0)
const ACC_MAG_INPUT = 100
const UP_DIR = Vector3(0, 1, 0)
const SNAP = Vector3(0, -2, 0)
const MAX_XZ_SPEED = 4
const FRICTION_XZ = 10
const FRICTION_Y = 1

var weapon : String = "gun"
var mass : float = 1
var velocity : Vector3 = Vector3(0, 0, 0)
var head_angle : float
var can_jump = false

var weapon_list := ["gun"]

var aiming = false
var ads_tween

func _ready() -> void:
	$CanvasLayer/Control/Label.text = weapon
	$CanvasLayer/Control/Hitmarker.set("modulate", Color(1, 1, 1, 0))
	
	ads_tween = Tween.new()
	add_child(ads_tween)

func _process(delta):
	$CanvasLayer/Control/Label2.set_text(str(Engine.get_frames_per_second()))
	
func _physics_process(delta):
	var alpha = $CanvasLayer/Control/Hitmarker.get("modulate").a
	$CanvasLayer/Control/Hitmarker.set("modulate", Color(1, 1, 1, alpha - 0.1))
	
func set_up(connect_info : Dictionary):
	# Called in server.confirm_connection
	transform = Utility.transform_from_array(connect_info["transform"])
	velocity = Utility.vec3_from_array(connect_info["velocity"])

func rotate_player(rot : Vector2):
	# Rotate body
	rotation_degrees.y -= ClientData.SENS_MULTIPLIER * rot.x
	# Rotate head
	head_angle -= ClientData.SENS_MULTIPLIER * rot.y
	head_angle = clamp(head_angle, -80, 80)
	$Camera.rotation_degrees.x = head_angle

func check_can_jump(node):
	return "is_jumpable_surface" in node && node.is_jumpable_surface
	
func move(dir : Vector3, delta : float, jump : bool):
	dir = dir.x * transform.basis.x + dir.y * transform.basis.y + dir.z * transform.basis.z
	
	if jump && can_jump:
		dir.y = 40
		can_jump = false
	
	velocity = velocity - Vector3(velocity.x, 0, velocity.z) * FRICTION_XZ * delta
	velocity.y = velocity.y - velocity.y * FRICTION_Y * delta
	
	velocity += ACC_GRAV * delta
		
	# TODO some kind of velocity cap
	velocity += ACC_MAG_INPUT * dir * delta
	if pow(velocity.x, 2) + pow(velocity.z, 2) > pow(MAX_XZ_SPEED, 2):
		var plane_vel = Vector2(velocity.x, velocity.z).normalized() * MAX_XZ_SPEED
		velocity.x = plane_vel.x
		velocity.z = plane_vel.y
	
	var motion = velocity * delta
	var collision = move_and_collide(motion)
	
	can_jump = false
	if collision:
		can_jump = check_can_jump(collision.get_collider())
		if can_jump == false:
			var parent = collision.get_collider().get_parent()
			while(can_jump == false && parent != null):
				can_jump = check_can_jump(parent)
				parent = parent.get_parent()
		
		# Determine vector parallel to move direction that continues the motion
		var remainder_motion = motion.slide(collision.normal)
		transform.origin += remainder_motion
		
		# Update velocity to match
		velocity = velocity.slide(collision.normal)
		


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
	
