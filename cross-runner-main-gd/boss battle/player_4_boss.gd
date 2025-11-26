extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

const MAX_JUMPS = 2
var jumps_left = MAX_JUMPS

# --- REFERENCES TO NODES ---
@onready var anim = $AnimatedSprite2D
@onready var coin_label = %Label
@onready var sfx_attack = $sfx_attack
@onready var sfx_jump = $sfx_jump
@onready var sfx_coin = $sfx_coin

# Attack hitbox
@onready var attack_hitbox = $AttackHitbox
@onready var attack_shape = $AttackHitbox/CollisionShape2D

var is_attacking = false
var coin_counter = 0

# --- ADDED DEATH VARIABLES AND REFERENCES ---
# Set the Y value where falling kills the player (Adjust this in the inspector/editor)
@export var death_y_level: float = 600.0 
# Reference the Timer node (MUST be named DeathTimer in the Scene Tree!)
@onready var death_timer: Timer = $DeathTimer 
var is_dying: bool = false # Flag to prevent starting the timer multiple times

func _physics_process(delta: float) -> void:
	# ADDED: Check if player falls off the map
	if global_position.y > death_y_level:
		if not is_dying:
			start_death_sequence()
			# Don't return here if you want physics process to continue running immediately after trigger

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reset jumps when grounded
	if is_on_floor():
		jumps_left = MAX_JUMPS

	# Attack Input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		if sfx_attack:
			sfx_attack.play()
		else:
			print("WARNING: sfx_attack node is missing!")
			
		_play_attack()
		return  # Stops other movement logic while attacking

	# Jump Input
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and jumps_left > 0:
		if sfx_jump:
			sfx_jump.play()
			
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	# Movement
	var move_left = Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A)
	var move_right = Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D)
	
	var direction = 0
	if move_right:
		direction += 1
	if move_left:
		direction -= 1

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

	if attack_hitbox and attack_shape:
		attack_hitbox.monitoring = true
		attack_shape.disabled = false

	await anim.animation_finished

	if attack_hitbox and attack_shape:
		attack_hitbox.monitoring = false
		attack_shape.disabled = true

	is_attacking = false

# When NPC hits player
func hurt():
	if not is_attacking:
		anim.play("hurt")

func _on_area_2d_coin_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		if sfx_coin:
			sfx_coin.play()
		set_coin(coin_counter + 1)
		print(coin_counter)

func set_coin(new_coin_count: int) -> void:
	coin_counter = new_coin_count
	if coin_label:
		coin_label.text = "Coin Count: " + str(coin_counter)

# --- ADDED DEATH FUNCTIONS ---

func start_death_sequence() -> void:
	is_dying = true
	velocity = Vector2.ZERO # Stop movement immediately
	# Optional: set_physics_process(false) # If you want ALL physics to stop instantly
	death_timer.start() # This is the line that needs the timer node to exist
	print("Player is falling! Dying in 2 seconds...")

func _on_death_timer_timeout() -> void:
	# This function is called after the 2-second timer finishes
	die()

func die() -> void:
	print("Player has died.")
	# The actual death action:
	get_tree().reload_current_scene() 
