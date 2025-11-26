extends Button

var scene_to_load = preload("res://SkinsS.tscn")

func _ready() -> void:
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(scene_to_load)
