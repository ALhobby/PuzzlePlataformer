extends Node2D


var moth = preload("res://Moth.tscn")
onready var player = $Player

onready var new_moth : Node = null
onready var trayectory = $Line2D
onready var draw_trayectory : bool = false
onready var throw_range_x = 180
onready var throw_range_y = -200
onready var vertex : Vector2 = Vector2.INF


func _ready():
	player.connect("enter_launch_mode", self, "create_moth")
	player.connect("launch", self, "launch_moth")
	player.connect("recall_moth", self, "recall_moth")


func create_moth(launcher : Node):
	""" Instance a new Moth scene
	"""
	if new_moth != null:
		remove_child(new_moth)
	new_moth = moth.instance()
	new_moth.global_position = launcher.global_position + Vector2(0,-40)  # Spawn on top of player

	add_child(new_moth)
	draw_trayectory = true


func recall_moth():
	if new_moth:
		remove_child(new_moth)


func calculate_trayectory():
	"""Calculate the trayectory that moth would have if launched.
	"""
	
	var min_distance_for_collision = 5  # Minimum distance from where to start checking for collisions
	var x_distance_buffer = 100  # Additional distance for the for loop to cover, in case moth falls lower than the player position
	
	var start_point = new_moth.global_position
	var x_distance = clamp(get_global_mouse_position().x, start_point.x-throw_range_x, start_point.x+throw_range_x)
	var end_point = Vector2(x_distance, start_point.y)
	vertex = Vector2((start_point.x+x_distance)/2, start_point.y+throw_range_y)
	var output = PoolVector2Array()
	var space = get_world_2d().get_direct_space_state()

	var point : Vector2
	if  end_point.x > start_point.x:  # Shooting right
		for i in range(start_point.x, end_point.x + x_distance_buffer):
			var a = (start_point.y-vertex.y)/((vertex.x-start_point.x)*(vertex.x-end_point.x))
			point = Vector2(i, start_point.y - a*(i-start_point.x)*(i-end_point.x))
			var results = space.intersect_point(point, 32, [], 2147483647, 15)
			if results:
				if i > start_point.x + min_distance_for_collision and typeof(results[0]['collider']) == 17:  # TODO : trying to stop the line when it collides
					return output
			output.append(point) 

	elif end_point.x < start_point.x:  # Shooting left
		for i in range(start_point.x, end_point.x - x_distance_buffer, -1):
			var a = (start_point.y-vertex.y)/((vertex.x-start_point.x)*(vertex.x-end_point.x))
			point = Vector2(i, start_point.y - a*(i-start_point.x)*(i-end_point.x))
			var results = space.intersect_point(point, 32, [], 2147483647, 15)
			if results:
				if i < start_point.x - min_distance_for_collision and typeof(results[0]['collider']) == 17:  # TODO : trying to stop the line when it collides
					return output
			output.append(point) 
	else:  # Dead center
		pass

	return output


func update_trajectory(_delta):
	""" Reset and refull the 'trayectory' line2D
	"""
	trayectory.clear_points()
	trayectory.points = calculate_trayectory()


func launch_moth():
	new_moth.set_path(trayectory)
	trayectory.clear_points()
	draw_trayectory = false
	new_moth.launched = true
	update()


func _draw():
	#draw_circle(get_global_mouse_position(), 5.0, Color(1,0,0,1))
	if draw_trayectory:
		draw_circle(vertex, 10.0, Color(0,1,0,1))  # Draw vertex of parabola


func _process(delta):
	if draw_trayectory:
		trayectory.show()
		update_trajectory(delta)
		update()  # Draw




func _on_Spikes_body_entered(body):
	if body == player:
		print("DEAD") 
