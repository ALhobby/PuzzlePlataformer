extends Area2D


func _on_CheckpointMarker_body_entered(body):
	""" Update the respawn position store in AutoLoad 'Checkpoint.gd' to that
	of the entered checkpoint.
	"""
	print("CHECKPOINT UPDATED!")
	Checkpoint.set_respawn_pos(self.global_position)

