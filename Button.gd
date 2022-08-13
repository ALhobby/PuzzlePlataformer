extends Area2D

signal button_pressed()

onready var pressed : bool = false


func _on_Button_area_entered(_area):
	print("BUTTON PRESSED")
	emit_signal("button_pressed")
