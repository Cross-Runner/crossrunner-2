extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

const MAX_JUMPS = 2
var jumps_left = MAX_JUMPS

@onready var anim = $AnimatedSprite2D
@onready var coin_label = %Label
@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
@onready var sfx_attack: AudioStreamPlayer2D = $sfx_attack
@onready var sfx_coin: AudioStreamPlayer2D = $sfx_coin


# Attack hitbox
@onready var attack_hitbox = $AttackHitbox
@onready var attack_shape = $AttackHitbox/CollisionShape2D

var is_attacking = false
var coin_counter = 0

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reset jumps when grounded
	if is_on_floor():
		jumps_left = MAX_JUMPS

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		sfx_attack.play()
		_play_attack()
		return

	# Jump
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		sfx_jump.play()
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0

		if is_on_floor() and not is_attacking:
			if anim.animation != "walk":
				anim.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		if is_on_floor() and not is_attacking:
			if anim.animation != "idle":
				anim.play("idle")

	move_and_slide()


func _play_attack() -> void:
	is_attacking = true
	anim.play("attack")

	attack_hitbox.monitoring = true
	attack_shape.disabled = false

	await anim.animation_finished

	attack_hitbox.monitoring = false
	attack_shape.disabled = true

	is_attacking = false


func hurt():
	if not is_attacking:
		anim.play("hurt")


func _on_area_2d_coin_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		sfx_coin.play()
		set_coin(coin_counter + 1)
		print(coin_counter)


func set_coin(new_coin_count: int) -> void:
	coin_counter = new_coin_count
	coin_label.text = "Coin Count: " + str(coin_counter)
