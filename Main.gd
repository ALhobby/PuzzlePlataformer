extends Node2D


var moth = preload("res://Moth.tscn")
onready var player = $Player
onready var map_dict = {}
onready var loaded_rooms_dict = {}

onready var new_moth : Node = null
onready var trayectory = $Line2D
onready var draw_trayectory : bool = false
onready var throw_range_x = 180
onready var throw_range_y = -100
onready var vertex : Vector2 = Vector2.INF
onready var start_point : Vector2 = Vector2.ZERO
onready var end_point : Vector2 = Vector2.ZERO
onready var target_point : Vector2 = Vector2.ZERO


func _ready():
	print("READY CALLED")
	Checkpoint.set_respawn_pos(player.position)  # Set initial respawn point
	player.connect("enter_throw_mode", self, "create_moth")
	player.connect("launch", self, "launch_moth")
	player.connect("recall_moth", self, "recall_moth")
	var file = File.new()
	map_dict = load_json_file("res://map.json")
	#file.store_string("{'Room1': {}, 'Room2': {}, 'Room3': {}}")
	print("Full map_dict", map_dict)
	load_room_and_neighbors('RoomA01')
	player.connect("room_entered", self, "load_room_and_neighbors")


func load_json_file(path):
	"""Loads a JSON file from the given res path and return the loaded JSON object.
	https://godotengine.org/qa/8291/how-to-parse-a-json-file-i-wrote-myself"""
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	print("text", text)
	var result_json = JSON.parse(text)
	if result_json.error != OK:
		print("[load_json_file] Error loading JSON file '" + str(path) + "'.")
		print("\tError: ", result_json.error)
		print("\tError Line: ", result_json.error_line)
		print("\tError String: ", result_json.error_string)
		return null
	var obj = result_json.result
	return obj


func load_room_and_neighbors(current_room):
	"""Loads the current room and every room stored in its 'neighbors' list"""
	var next_room_resource = null  # Return of 'load' call
	var next_level = null  # Actual instance of the scene
	
	# Main scene. It should almost always already be loaded
	var coords = map_dict[current_room]["coords"]  # Entered room coords
	if not loaded_rooms_dict.has(current_room):
		next_room_resource = load("res://rooms/"+current_room+".tscn")
		next_level = next_room_resource.instance()
		next_level.position = Vector2(coords[0], coords[1])
		loaded_rooms_dict[current_room] = next_level
		get_tree().root.call_deferred("add_child", next_level)
	
	# Neighbors
	var neighbors = map_dict[current_room]["neighbors"]
	for room in neighbors:
		if not loaded_rooms_dict.has(room):
			next_room_resource = load("res://rooms/"+room+".tscn")
			print("Room ", room, " loaded!")
			next_level = next_room_resource.instance()
			coords = map_dict[room]["coords"]
			next_level.position = Vector2(coords[0], coords[1])
			loaded_rooms_dict[room] = next_level
			get_tree().root.call_deferred("add_child", next_level)

	# Unload far away rooms
	for loaded_room in loaded_rooms_dict.keys():
		if loaded_room != current_room and not neighbors.has(loaded_room):
			print("Unloading ", loaded_room)
			loaded_rooms_dict[loaded_room].queue_free()
			loaded_rooms_dict.erase(loaded_room)
			
	print("loaded_rooms_dict: ", loaded_rooms_dict)

func create_moth(launcher : Node):
	""" Instance a new Moth scene
	"""
	if new_moth:
		remove_child(new_moth)
	new_moth = moth.instance()
	new_moth.global_position = launcher.global_position + Vector2(0,-45)  # Spawn on top of player

	add_child(new_moth)
	draw_trayectory = true


func recall_moth():
	if new_moth:
		remove_child(new_moth)


func calculate_trayectory():
	"""Calculate the trayectory that moth would have if launched.
	"""
	start_point = new_moth.global_position
	var mouse_pos = get_global_mouse_position()
	var x_distance = null
	var min_x_distance = 0  # Minimum distance mouse needs from Vest for line to be drawn
	if start_point.x < mouse_pos.x:  # Shooting right
		x_distance = clamp(mouse_pos.x, start_point.x+min_x_distance, start_point.x+throw_range_x)
	elif start_point.x > mouse_pos.x:  # Shooting left
		x_distance = clamp(mouse_pos.x, start_point.x-throw_range_x, start_point.x-min_x_distance)
	if not x_distance:	return
	end_point = Vector2(x_distance, start_point.y)
	vertex = Vector2((start_point.x+x_distance)/2, start_point.y+throw_range_y)

	var output = PoolVector2Array()
	var space = get_world_2d().get_direct_space_state()
	var x_distance_buffer = 1000
	var min_distance_for_collision = 10

	var point : Vector2
	if  end_point.x > start_point.x:  # Shooting right
		player.sprite.flip_h = false
		# 'a' is a constant used in the parabola calculation
		var a = (start_point.y-vertex.y)/((vertex.x-start_point.x)*(vertex.x-end_point.x))

		for i in range(start_point.x, end_point.x + x_distance_buffer):
			point = Vector2(i, start_point.y - a*(i-start_point.x)*(i-end_point.x))
			var results = space.intersect_point(point, 32, [], 2147483647, 15)
			if results:
				if i > start_point.x + min_distance_for_collision and typeof(results[0]['collider']) == 17:  # TODO : trying to stop the line when it collides
					return output
			output.append(point) 
	
	elif end_point.x < start_point.x:  # Shooting left
		player.sprite.flip_h = true
		var a = (start_point.y-vertex.y)/((vertex.x-start_point.x)*(vertex.x-end_point.x))
		
		for i in range(start_point.x, end_point.x - x_distance_buffer, -1):
			point = Vector2(i, start_point.y - a*(i-start_point.x)*(i-end_point.x))
			var results = space.intersect_point(point, 32, [], 2147483647, 15)
			if results:
				if i < start_point.x - min_distance_for_collision and typeof(results[0]['collider']) == 17:  # TODO : trying to stop the line when it collides
					return output
			output.append(point) 
	else:  # Dead center
		pass
	return


func update_trajectory(_delta):
	""" Reset and refull the 'trayectory' line2D
	"""
	trayectory.clear_points()
	var output_of_calc_trayect = calculate_trayectory()
	if output_of_calc_trayect:
		trayectory.points = output_of_calc_trayect
		target_point = output_of_calc_trayect[1]


func launch_moth():
	new_moth.set_path(trayectory)
	trayectory.clear_points()
	draw_trayectory = false
	new_moth.launched = true

	var launch_vector_magnitude = 800
	#var target_point = new_moth.global_position + Vector2(0.2,-1)
	var launch_unit_vector = new_moth.global_position.direction_to(target_point).normalized()
	var launch_vector = launch_vector_magnitude * launch_unit_vector
	print("launch_vector: ", launch_vector)
	new_moth.velocity_vec = launch_vector
	update()


func _draw():
	#draw_circle(get_global_mouse_position(), 5.0, Color(1,0,0,1))
	if draw_trayectory:
		draw_circle(vertex, 10.0, Color(0,1,0,1))  # Draw vertex of parabola
		draw_circle(end_point, 10.0, Color(0,1,1,1))
		draw_circle(target_point, 10.0, Color(1,0,0,1))


func _process(delta):
	if Input.is_action_just_pressed("reset"):
		player.die()
	
	if draw_trayectory:
		trayectory.show()
		update_trajectory(delta)
		update()  # Draw
