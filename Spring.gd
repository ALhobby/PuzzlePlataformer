extends Area2D


export var bounce_strength : int = 1600

onready var theta = self.rotation_degrees  # Angle of the spring
onready var unitary_vector : Vector2 = Vector2(sin(deg2rad(theta)), -cos(deg2rad(theta)))


func _on_Spring_body_entered(body):
	if body is KinematicBody2D:
		print("SPRING PRESSED")
		# Q1 is +,+
		# Q4 is -,-
		if body.get_name() == "Player":
			body.velocity_vec = bounce_strength * unitary_vector
