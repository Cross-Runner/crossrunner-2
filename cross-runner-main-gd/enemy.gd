extends CharacterBody2D

@onready var target = $"../CharacterBody2D"
@onready var sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox        # Area2D
@onready var hurtbox_shape = $Hurtbox/CollisionShape2D

var speed = 70
var aggro_distance = 200
var is_dead = false


func _ready():
	# Sørg for at hurtbox er påslått
	hurtbox.monitoring = true
	hurtbox_shape.disabled = false


func _physics_process(delta):
	if is_dead:
		return  # NPC stopper all logikk om den er død

	# --- BEVEGELSE / AI ---
	var dist_to_player = global_position.distance_to(target.global_position)

	if dist_to_player < aggro_distance:

		var direction = sign(target.global_position.x - global_position.x)

		velocity.x = direction * speed

		# Flip animasjon (du sa den er speilvendt)
		sprite.flip_h = direction > 0

		if sprite.animation != "walk":
			sprite.play("walk")

	else:
		velocity.x = 0

		if sprite.animation != "idle":
			sprite.play("idle")

	# Utfør bevegelsen
	move_and_slide()

	# --- KONTAKT-SKADE I GODOT 4 (erstatter body_entered) ---
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider and collider.name == "CharacterBody2D":
			if collider.has_method("hurt"):
				collider.hurt()


# NPC blir truffet av spillerens angrep
func _on_Hurtbox_area_entered(area):
	if area.name == "AttackHitbox":
		die()


func die():
	if is_dead:
		return

	is_dead = true

	if sprite.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished

	queue_free()
