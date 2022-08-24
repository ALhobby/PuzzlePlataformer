extends Area2D


export var bounce_strength : int = 1600

onready var sprite = $Sprite
onready var theta = self.rotation_degrees  # Angle of the spring
# Unitary vector normal to the spring surface
onready var unitary_vector : Vector2 = Vector2(sin(deg2rad(theta)), -cos(deg2rad(theta)))


func _on_Spring_body_entered(body):
	if body is KinematicBody2D:
		print("SPRING PRESSED")
		# Animation
		sprite.set_frame(0)
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timer_timeout")
		timer.set_wait_time(0.2)
		add_child(timer) #to process
		timer.start() #to start
		
		# Physiscs
		if body.get_name() == "Player":
			body.velocity_vec = bounce_strength * unitary_vector
		elif body.has_method("set_launched"):  # is moth
			body.velocity_vec = bounce_strength * unitary_vector


func _on_timer_timeout():
	sprite.set_frame(1)
