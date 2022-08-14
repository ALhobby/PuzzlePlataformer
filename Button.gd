extends Area2D

signal button_pressed()
signal button_unpressed()

onready var pressed : bool = false


func _on_Button_area_entered(_area):
	print("BUTTON PRESSED")
	emit_signal("button_pressed")


func _on_Button_area_exited(area):
	print("BUTTON UNPRESSED")
	emit_signal("button_unpressed")
