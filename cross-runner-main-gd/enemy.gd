extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var hurtbox_shape = $Hurtbox/CollisionShape2D
@onready var sfx_npc: AudioStreamPlayer2D = $"../sfx_npc"

var target : Node2D = null
var speed = 40
var aggro_distance = 200
var is_dead = false

func _ready():
	# Finn spilleren automatisk uansett hvor den står
	target = get_tree().get_first_node_in_group("player")

	hurtbox.monitoring = true
	hurtbox_shape.disabled = false

	# Spill default animasjon
	sprite.play()

func _physics_process(delta):
	if is_dead:
		return

	if not target:
		return

	var dist_to_player = global_position.distance_to(target.global_position)

	if dist_to_player < aggro_distance:
		var direction = sign(target.global_position.x - global_position.x)
		velocity.x = direction * speed

		# 🔥 RIKTIG snu-retning for din sprite:
		sprite.flip_h = direction > 0

	else:
		velocity.x = 0

	move_and_slide()

	# Kontakt-skade
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.has_method("hurt"):
			collider.hurt()

# Treffer av angrepshitbox
func _on_hurtbox_area_entered(area):
	if area.name == "AttackHitbox":
		sfx_npc.play()
		die()

func die():
	if is_dead:
		return

	is_dead = true
	queue_free()
