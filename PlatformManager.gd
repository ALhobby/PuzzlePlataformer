extends Node2D


"""This script manages buttons and appearing platforms.
Instead of assigning the nodes to variables directy. _ready() loops through all
children in case there are a variable number of elements.
"""


onready var plat_tilemap : Node = null

func _ready():
	for node in get_children():
		if node.is_in_group("Button"):
			print("Found button ", node)
			node.connect("button_pressed", self, "make_platform_solid")
			node.connect("button_unpressed", self, "make_platform_ghost")
		elif node.is_in_group("Platform"):
			print("Platform tileset name: ", node)
			# Set collision masks and layers to 0
			node.collision_layer = 0
			node.collision_mask = 0
			plat_tilemap = node
			plat_tilemap.modulate = Color(1,1,1,0.2)
		else:
			print("WARNING: unexpected node in PlatformManager lacks correct group")


func make_platform_solid(button_id):
	plat_tilemap.call_deferred("set_collision_layer_bit", 0, true)
	plat_tilemap.call_deferred("set_collision_mask_bit", 0, true)
	for tile in plat_tilemap.tile_set.get_tiles_ids():
		plat_tilemap.tile_set.tile_get_texture(tile).pause = false
		print("PAUSE tile ", tile, ": ", plat_tilemap.tile_set.tile_get_texture(tile).pause)
	plat_tilemap.modulate = Color(1,1,1,1)

func make_platform_ghost(button_id):
	plat_tilemap.call_deferred("set_collision_layer_bit", 0, false)
	plat_tilemap.call_deferred("set_collision_mask_bit", 0, false)
	plat_tilemap.modulate = Color(1,1,1,0.2)
