extends KinematicBody

export var is_player = true;

enum State { IDLE, WALKING, SPRINTING, JUMPING, FALLING }

const ACCELERATION = 0.5
const MOVE_SPEED = 10
#const SPRINT_SPEED = 14
const MOVE_FRICTION = 1.15
const FALL_FRICTION = 1
const MAX_CLIMB_ANGLE = 0.6
const ANGLE_OF_FREEDOM = 80
const JUMP_SPEED = 45

var state = State.FALLING
var on_floor = false
#var crouching = false
#var crouch_floor = false #true if started crouching on the floor
var collision : KinematicCollision  # Stores the collision from move_and_collide
var velocity := Vector3(0, 0, 0)

var head_angle : float
var aiming = false
var ads_tween

var raycast_node

var weapon : String	= "gun"		# Currently equipped weapon
var weapon_list := ["gun"]

#func _ready():
#	raycast_node = RayCast.new()
#	raycast_node.cast_to(Vector3(0, -0.1, 0))
#	self.add_child(raycast_node)

func rotate_player(rot : Vector2):
	# Rotate body
	rotation_degrees.y -= SharedData.SENS_MULTIPLIER * rot.x
	# Rotate head
	head_angle -= SharedData.SENS_MULTIPLIER * rot.y
	head_angle = clamp(head_angle, -80, 80)
	$Camera.rotation_degrees.x = head_angle

func get_camera():
	return $Camera
	
func move(input_dir : Vector3, delta : float, jump : bool):
	if jump && on_floor && state != State.FALLING:
		state = State.JUMPING
	
	# state management
	if !collision:
		on_floor = false
		if state != State.JUMPING:
			state = State.FALLING
	else:
		if state == State.JUMPING:
			pass
		elif Vector3.UP.dot(collision.normal) < MAX_CLIMB_ANGLE:
			state = State.FALLING
		else:
			on_floor = true
			if input_dir.length() > .1: 
				state = State.WALKING
			else:
				state = State.IDLE
	
	#jump state
	if state == State.JUMPING:
		velocity.y = JUMP_SPEED
		state = State.FALLING

	#fall state
	if state == State.FALLING:
		if velocity.y > SharedData.GRAVITY:
			velocity.y += SharedData.GRAVITY * delta * 4
	
	#run state
	if state == State.WALKING:
		velocity += input_dir.rotated(Vector3(0, 1, 0), rotation.y) * ACCELERATION
		if Vector2(velocity.x, velocity.z).length() > MOVE_SPEED: 
			velocity = velocity.normalized() * MOVE_SPEED
			velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1)
		
		# fake gravity to keep character on the ground
		# increase if player is falling down slopes instead of WALKING
		velocity.y -= .0001 + (int(velocity.y < 0) * 1.1)  
		

	#idle state
	if state == State.IDLE: 
		if velocity.length() > .5:
			velocity /= MOVE_FRICTION
			velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1) - .0001

	#apply
	if velocity.length() >= .5: # || inbetween:
		collision = move_and_collide(velocity * delta)
	else:
		velocity = Vector3(0, velocity.y, 0)
	if collision:
		if Vector3.UP.dot(collision.normal) < .5:
			velocity.y += delta * SharedData.GRAVITY
			velocity.y = clamp(velocity.y, SharedData.GRAVITY, 9999)
			velocity = velocity.slide(collision.normal).normalized() * velocity.length()
		else:
			velocity = velocity

