extends Area2D

@export var target_scene: String = "res://CR_Scene4.tscn"
@export var bounce_force := Vector2(0, -450)

var triggered := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if triggered:
		return

	if body.is_in_group("player"):
		triggered = true

		var stats = get_node("/root/PlayerStats")

		# Lose a heart
		stats.health = max(stats.health - 1, 0)
		stats.health_changed.emit()

		# Bounce
		if body is CharacterBody2D:
			body.velocity = bounce_force

		await get_tree().create_timer(0.1).timeout

		# If dead -> reset + restart scene
		if stats.health <= 0:
			stats.reset()
			get_tree().change_scene_to_file(target_scene)
		else:
			await get_tree().create_timer(0.2).timeout
			triggered = false


func _on_hurtbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
