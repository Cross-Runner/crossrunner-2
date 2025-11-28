extends Area2D

@export var level1_scene: String = "res://CR_Scene4.tscn"

var triggered := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if triggered:
		return

	if body.is_in_group("player"):
		triggered = true

		var stats = get_node("/root/PlayerStats")

		# Kill player
		stats.health = 0
		stats.health_changed.emit()

		await get_tree().create_timer(0.05).timeout

		# Reset BEFORE changing scene
		stats.reset()

		get_tree().change_scene_to_file(level1_scene)
