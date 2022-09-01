extends KinematicBody2D

signal enter_throw_mode(node)
signal launch()
signal recall_moth()
signal room_entered(room_name)

const speed = 210  # Running speed
const jump = -550  # Negative because negative 'y' is up
const gravity = 40
const acceleration = 100
const deacceleration_fraction = 0.4

const UP = Vector2(0, -1)  # Set upwards direction

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sprite = $Sprite

onready var throw_mode : bool = false
onready var mothless : bool = false

var velocity_vec = Vector2.ZERO
var jump_count = 0
export var extra_jumps = 1
export var extra_jump_percent = 0.8


func _ready():
	animation_tree.active = true
	#sprite.set_modulate(Color(0,1,0,1))


func die():
	if Checkpoint.last_position:
		position = Checkpoint.last_position
	# TODO : reset room on death


func _physics_process(_delta):

	# GRAVITY
	velocity_vec.y += gravity
	
	# LEFT AND RIGHT
	if not throw_mode:  # This stops movement in launch mode. Questionable design decision
		if Input.is_action_pressed("ui_right"):
			velocity_vec.x = min(velocity_vec.x + acceleration, speed)  # Smaller of either
			sprite.flip_h = false
			animation_state.travel("run_right")
		elif  Input.is_action_pressed("ui_left"):
			velocity_vec.x =  max(velocity_vec.x - acceleration, -speed)
			sprite.flip_h = true
			animation_state.travel("run_right")
		else:  # No left/right input
			if is_on_floor():
				velocity_vec.x = lerp(velocity_vec.x, 0, deacceleration_fraction)  # Smooth de-acceleration
			animation_state.travel("Idle_right")

		# JUMP
		if Input.is_action_just_pressed("ui_up"):
			if is_on_floor():
				velocity_vec.y = jump
				animation_state.travel("jump_loop_right")
			elif jump_count < extra_jumps and not mothless:
				velocity_vec.y = jump * extra_jump_percent
				jump_count += 1
		if is_on_floor():
			jump_count = 0
		else:
			animation_state.travel("fall_loop_right")

		# Go through 1-way platforms
		if Input.is_action_pressed("ui_down") and is_on_floor():
			self.position = Vector2(self.position.x, self.position.y + 1)

		velocity_vec = move_and_slide(velocity_vec, UP, false, 10)
	
	
	if Input.is_action_just_pressed("click"):
		if not throw_mode and not mothless and is_on_floor():
			throw_mode = true
			emit_signal("enter_throw_mode", self)
		elif throw_mode:
			emit_signal("launch")
			throw_mode = false
			mothless = true
			sprite.set_modulate(Color(1,0,0,1))
		elif mothless:
			emit_signal("recall_moth")
			mothless = false
			sprite.set_modulate(Color(1,1,1,1))


func _on_RoomDetector_area_entered(area):
	if area.has_method("get_room_name"):
		var collision_shape = area.get_node("CollisionShape2D")
		var size = collision_shape.shape.extents*2  # Get size of the room
		emit_signal("room_entered", area.room_name)
		# Set dimensions of the camera in the new room
		var camera = $Camera2D
		camera.limit_top = collision_shape.global_position.y - size.y/2
		camera.limit_left = collision_shape.global_position.x - size.x/2
		camera.limit_bottom = camera.limit_top + size.y
		camera.limit_right = camera.limit_left + size.x

