extends Area2D

@export var scene_to_load: String = "res://.tscn"

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(scene_to_load)
