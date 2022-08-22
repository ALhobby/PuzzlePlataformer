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
		
		velocity_vec = move_and_slide(velocity_vec, Vector2(0,1))
	# FOLLOWING THE PATH
#	if launched:  # If Moth has been launched
#		var distance_to_walk = speed * delta  # Walk distance for this frame,
#		# product of moths speed and the time elapsed from the previous frame
#		# Move moth along the path until he runs out of movement or path ends.
#		while distance_to_walk > 0 and path.size() > 0: 
#			var distance_to_next_point = get_global_position().distance_to(path[0])
#			# Moth doesn't have enough movement left to get to the next point.
#			if distance_to_walk <= distance_to_next_point:
#				global_position += get_global_position().direction_to(path[0]) * distance_to_walk
#				# Unitary vector * distance
#			else: # Moth gets to the next point this 'tick'
#				global_position = path[0]
#				path.remove(0)  # Same as 'pop'?
#			distance_to_walk -= distance_to_next_point  # Update the distance to walk
#		if is_on_floor():  # Touchdown
#			launched = false
