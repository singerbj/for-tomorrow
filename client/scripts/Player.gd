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

func _ready() -> void:
	$CanvasLayer/Control/Label.text = weapon

func _process(delta):
	$CanvasLayer/Control/Label2.set_text(str(Engine.get_frames_per_second()))
	
func set_up(connect_info : Dictionary):
	# Called in server.confirm_connection
	transform = Utility.transform_from_array(connect_info["transform"])
	velocity = Utility.vec3_from_array(connect_info["velocity"])

func rotate_player(rot : Vector2):
	# Rotate body
	rotation_degrees.y -= ClientData.SENS_MULTIPLIER * rot.x
	# Rotate head
	head_angle -= ClientData.SENS_MULTIPLIER * rot.y
	head_angle = clamp(head_angle, -80, 90)
	$Camera.rotation_degrees.x = head_angle


func move(dir : Vector3, delta : float, jump : bool):
	dir = dir.x * transform.basis.x + dir.y * transform.basis.y + dir.z * transform.basis.z
	
	if jump && can_jump:
		dir.y = 20
		dir.x = dir.x * 20 * 4
		dir.z = dir.z * 20 * 4
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
		if "is_jumpable_surface" in collision.get_collider() && collision.get_collider().is_jumpable_surface:
			can_jump = true
		
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
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
