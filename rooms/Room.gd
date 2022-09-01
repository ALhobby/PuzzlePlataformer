extends Area2D


export var room_name = "RoomXYY"


func _ready():
	get_parent().move_child(self, 0)


func get_room_name():
	return room_name
