extends KinematicBody2D

signal enter_throw_mode(node)
signal launch()
signal recall_moth()

const speed = 240
const jump = -900  # Negative because negative 'y' is up
const gravity = 50
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

		velocity_vec = move_and_slide(velocity_vec, UP, false, 10)
	
	
	if Input.is_action_just_pressed("click"):
		if not throw_mode and not mothless and is_on_floor():
			throw_mode = true
			emit_signal("enter_throw_mode", self)
		elif throw_mode:
			emit_signal("launch")
			throw_mode = false
			mothless = true
		elif mothless:
			emit_signal("recall_moth")
			mothless = false


func _on_RoomDetector_area_entered(area):
	var collision_shape = area.get_node("CollisionShape2D")
	var size = collision_shape.shape.extents*2  # Get size of the room
	
	# Set dimensions of the camera in the new room
	var camera = $Camera2D
	camera.limit_top = collision_shape.global_position.y - size.y/2
	camera.limit_left = collision_shape.global_position.x - size.x/2
	camera.limit_bottom = camera.limit_top + size.y
	camera.limit_right = camera.limit_left + size.x

