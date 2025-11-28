extends Area2D

@export var kill_layer: int = 1  # Set this to your player collision layer

func _on_body_entered(body):
	# Check if the object is on the kill layer
	if body.collision_layer & (1 << (kill_layer - 1)):
		kill(body)

func kill(body):
	if body.has_method("die"):
		body.die()
	else:
		# Fallback if no die() function exists
		body.queue_free()
