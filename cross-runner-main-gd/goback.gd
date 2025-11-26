extends Button


@export var target_scene: String = "res://MainMenu.tscn"
@onready var sfx_button: AudioStreamPlayer2D = $"../../sfx_button"

func _ready() -> void:
	# safe connect using Callable
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed() -> void:
	var err = get_tree().change_scene_to_file(target_scene)
	if err != OK:
		push_error("Failed to change scene to '%s' (error code: %s)" % [target_scene, str(err)])


func _on_button_3_pressed() -> void:
	pass # Replace with function body.
