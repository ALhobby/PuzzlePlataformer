extends Area2D

signal button_pressed(id)
signal button_unpressed(id)

onready var pressed : bool = false
export var button_id : int = 1


func _on_Button_area_entered(area):
	if area.get_parent() is KinematicBody2D:
		print("BUTTON PRESSED")
		pressed = true
		emit_signal("button_pressed", button_id)


func _on_Button_area_exited(_area):
	print("BUTTON UNPRESSED")
	pressed = false
	emit_signal("button_unpressed", button_id)


func get_button_pressed():
	return pressed
