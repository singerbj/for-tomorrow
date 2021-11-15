extends KinematicBody

var is_player = true;

enum State { IDLEING, WALKING, SPRNTING, JUMPING, FALLING }

const ACCELERATION : float = 1.0
const MOVE_SPEED : float = 10.0
#const SPRINT_SPEED : float = 14.0
const MOVE_FRICTION : float = 1.25
const MAX_CLIMB_ANGLE : float = 0.6
const ANGLE_OF_FREEDOM : float = 80.0
const JUMP_SPEED : float = 18.0
const FLOOR_HISTORY_MAX_LENGTH : float = 5.0

var state = State.FALLING
var previous_state = State.FALLING
var floor_history = []
var on_floor = false
#var crouching = false
#var crouch_floor = false #true if started crouching on the floor
var collision : KinematicCollision  # Stores the collision from move_and_collide
var velocity := Vector3(0, 0, 0)
var just_jumped : bool = false


var head_angle : float
var aiming = false
var ads_tween

var raycast_node

var weapon : String	= "gun"		# Currently equipped weapon
var weapon_list := ["gun"]

#func _ready():
#	raycast_node = RayCast.new()
#	self.add_child(raycast_node)
#	print("********************************************")
#	raycast_node.cast_to(Vector3(0, -0.1, 0))
#	raycast_node.enabled = true
#	print("********************************************RayCastPos: ", raycast_node.transform.origin)

var input_dir : Vector3
var jump : bool

func _physics_process(delta):
	move(delta)

func rotate_player(rot : Vector2):
	# Rotate body
	rotation_degrees.y -= SharedData.SENS_MULTIPLIER * rot.x
	# Rotate head
	head_angle -= SharedData.SENS_MULTIPLIER * rot.y
	head_angle = clamp(head_angle, -80, 80)
	$Camera.rotation_degrees.x = head_angle

func get_camera():
	return $Camera
	
func set_input_values(new_input_dir : Vector3, new_jump : bool):
	input_dir = new_input_dir
	jump = 	new_jump
	
func move(delta):
	# state management
	var new_state
	if !collision && !$RayCast.is_colliding():
		on_floor = false
		new_state = State.FALLING
	elif !collision && $RayCast.is_colliding():
		on_floor = true
		if input_dir.length() > 0.1: 
			new_state = State.WALKING
		else:
			if !just_jumped:
				new_state = State.IDLEING
			else:
				new_state = State.FALLING
	else:
		if Vector3.UP.dot(collision.normal) < MAX_CLIMB_ANGLE:
			on_floor = false
			new_state = State.FALLING
		else:
			on_floor = true
			if input_dir.length() > 0.1: 
				new_state = State.WALKING
			else:
				if !just_jumped:
					new_state = State.IDLEING
				else:
					new_state = State.FALLING
	
	
	if just_jumped && !$RayCast.is_colliding():
		just_jumped = false
	
	if jump && on_floor && !just_jumped:
		new_state = State.JUMPING
		
	previous_state = state
	state = new_state
	
	if previous_state != state:	
		print(State.keys()[state]) #, " - ", collision != null, " - ", $RayCast.is_colliding())
	
	# JUMPING state
	if state == State.JUMPING:
		velocity.y = JUMP_SPEED
		just_jumped = true

	# FALLING state
	if state == State.FALLING:
		if velocity.y > SharedData.GRAVITY:
			velocity.y += SharedData.GRAVITY * delta
	
	# WALKING state
	if state == State.WALKING:
		velocity += input_dir.rotated(Vector3(0, 1, 0), rotation.y) * ACCELERATION
		if Vector2(velocity.x, velocity.z).length() > MOVE_SPEED: 
			velocity = velocity.normalized() * MOVE_SPEED
			if collision != null:
				velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1)
#			else:
#				velocity.y = $RayCast.get_collision_point().y
		
		# fake gravity to keep character on the ground
		# increase if player is falling down slopes instead of WALKING
#		if previous_state != State.FALLING:
			velocity.y -= 0.5 + (int(velocity.y < 0) * 1.1)  
		

	# IDLE state
	if state == State.IDLEING: 
		if velocity.length() > 0.5:
			velocity /= MOVE_FRICTION
			if collision != null:
				velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1)
#			else:
#				velocity.y = $RayCast.get_collision_point().y
		
		# fake gravity to keep character on the ground
		# increase if player is falling down slopes instead of WALKING
#		if previous_state != State.FALLING:
			velocity.y -= 0.5 + (int(velocity.y < 0) * 1.1)  
		
			
			
#	if velocity.y > SharedData.GRAVITY:
#		velocity.y += SharedData.GRAVITY * delta	

	#apply
	if velocity.length() >= 0.5: # || inbetween:
		collision = move_and_collide(velocity * delta)
	else:
		velocity = Vector3(0, velocity.y, 0)
	if collision:
		if Vector3.UP.dot(collision.normal) < 0.5:
			velocity.y += delta * SharedData.GRAVITY
			velocity.y = clamp(velocity.y, SharedData.GRAVITY, 9999)
			velocity = velocity.slide(collision.normal).normalized() * velocity.length()
		else:
			velocity = velocity

