extends Sprite2D

func _process(delta):
	position = position.lerp(get_global_mouse_position(), 1 * delta)
