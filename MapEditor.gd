extends Node2D


# Declare member variables here. Examples:
onready var room_size = Vector2(640, 384)


# Called when the node enters the scene tree for the first time.
func _ready():
	save_map_to_json()


func save_map_to_json():
	var output_dict = {}
	# Fill coords
	for child in get_children():
		output_dict[child.room_name] = {"coords": [child.position.x, child.position.y], "neighbors": []}
		# How do I store neighbors?:
		# Idea 1: by distance. Loop all rooms again and if pos < pos_current + 640, record name
		# Idea 2: Store all coords as we loop once and calculate and fill retroactively
	# Fill neighbors
	for room in output_dict.keys():
		var coords = Vector2(output_dict[room]["coords"][0], output_dict[room]["coords"][1])
		var min_x = coords.x - room_size.x - 1
		var max_x = coords.x + room_size.x + 1
		var min_y = coords.y - room_size.y - 1
		var max_y = coords.y + room_size.y + 1
		print(room, " min_x: ", min_x, " min_y: ", min_y, " max_x: ", max_x, " max_y: ", max_y)

		for other_room in output_dict.keys():
			if other_room == room:
				pass
			else:
				var o_coords = Vector2 (output_dict[other_room]["coords"][0], output_dict[other_room]["coords"][1])
				if (o_coords.x > min_x and o_coords.x < max_x) and (o_coords.y > min_y and o_coords.y < max_y):
					 output_dict[room]["neighbors"].append(other_room)
	# Save dict to file
	print(output_dict)
	var file = File.new()
	var path = "res://map.json"
	file.open(path, file.WRITE)
	file.store_line(to_json(output_dict))
	file.close()
