extends Area2D

signal button_pressed(id)
signal button_unpressed(id)

onready var pressed : bool = false
export var button_id : int = 1
var button_presser_num : int = 0


func get_button_pressed():
	return pressed


func _on_Button_body_entered(body):
	if body is KinematicBody2D:
		# TODO : this should only fire if body is moth or not mothless player
		print("BUTTON PRESSED")
		pressed = true
		button_presser_num += 1
		emit_signal("button_pressed", button_id)


func _on_Button_body_exited(body):
	if body is KinematicBody2D:
		button_presser_num -= 1
	if button_presser_num == 0:
		print("BUTTON UNPRESSED")
		pressed = false
		emit_signal("button_unpressed", button_id)
