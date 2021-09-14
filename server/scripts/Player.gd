extends KinematicBody

# Forces
const ACC_GRAV = Vector3(0, -100, 0)
const ACC_MAG_INPUT = 100
const UP_DIR = Vector3(0, 1, 0)
const SNAP = Vector3(0, -2, 0)
const MAX_XZ_SPEED = 4
const FRICTION_XZ = 10
const FRICTION_Y = 1

# Object representing abstract player

var weapon : String			# Currently equipped weapon
var mass : float = 1		# kg
var velocity : Vector3 = Vector3(0, 0, 0)
var head_angle : float
var can_jump

func rotate_player(rot : Vector2):
	# Rotate body
	rotation_degrees.y -= ServerData.SENS_MULTIPLIER * rot.x
	# Rotate head
	head_angle -= ServerData.SENS_MULTIPLIER * rot.y
	head_angle = clamp(head_angle, -80, 90)

func check_can_jump(node):
	return "is_jumpable_surface" in node && node.is_jumpable_surface

func move(dir : Vector3, delta : float, jump : bool):
	dir = dir.x * transform.basis.x + dir.y * transform.basis.y + dir.z * transform.basis.z
	
	if jump && can_jump:
		dir.y = 20
		dir.x = dir.x * 20 * 2
		dir.z = dir.z * 20 * 2
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
