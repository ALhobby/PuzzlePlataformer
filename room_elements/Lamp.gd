extends Area2D


func trap_moth(body):
	#body.global_position = self.global_position
	#body.velocity_vec = Vector2()
	body.become_hypnotized(self.global_position)  # Moth goes towards the lamps position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Lamp_body_entered(body):
	if body.has_method("set_launched"):
		print("MOTH ENTERED LAMP AREA")
		trap_moth(body)
