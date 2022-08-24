extends KinematicBody2D

const speed : int = 800
const gravity = 50
const acceleration = 100

onready var launched : bool = false
onready var path : PoolVector2Array
onready var velocity_vec = Vector2.ZERO

func set_launched(new_bool):
	launched = new_bool


func set_path(new_path):
	path = new_path.get_points()


func _physics_process(delta):
	
	if launched and velocity_vec:
		velocity_vec.y += gravity
		#velocity_vec = move_and_collide(velocity_vec)
		var collide = move_and_collide(velocity_vec * delta)
		if collide:
			velocity_vec = Vector2.ZERO
