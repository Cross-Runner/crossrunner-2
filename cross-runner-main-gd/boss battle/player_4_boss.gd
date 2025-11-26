extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

const MAX_JUMPS = 2
var jumps_left = MAX_JUMPS

# --- REFERENCES TO NODES ---
# Make sure these nodes exist as CHILDREN of your player!
@onready var anim = $AnimatedSprite2D
@onready var coin_label = %Label

# These lines use "$sfx_attack" which means "Look for a child node named sfx_attack"
@onready var sfx_attack = $sfx_attack
@onready var sfx_jump = $sfx_jump
@onready var sfx_coin = $sfx_coin

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

	# Attack Input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		# Check if the sound node exists before playing to prevent crashes
		if sfx_attack:
			sfx_attack.play()
		else:
			print("WARNING: sfx_attack node is missing!")
			
		_play_attack()
		return  # Stops other movement logic while attacking

	# Jump Input
	# Checks for Spacebar (ui_accept) OR Up Arrow (ui_up)
	# Note: To add 'W' for jump correctly, it's best to use Input Map settings, 
	# but 'ui_up' usually covers the Up Arrow.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and jumps_left > 0:
		if sfx_jump:
			sfx_jump.play()
			
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	# Movement
	# We manually check for Left/Right actions (Arrows) AND the A/D keys
	var move_left = Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A)
	var move_right = Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D)
	
	# Calculate direction based on which keys are pressed
	var direction = 0
	if move_right:
		direction += 1
	if move_left:
		direction -= 1

	if direction != 0:
		velocity.x = direction * SPEED

		# Flip sprite depending on direction
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

	# Turn on hitbox
	# Check if nodes exist to avoid crash if they are missing
	if attack_hitbox and attack_shape:
		attack_hitbox.monitoring = true
		attack_shape.disabled = false

	# Wait until attack animation is finished
	await anim.animation_finished

	# Turn off hitbox
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
	# Check if label exists
	if coin_label:
		coin_label.text = "Coin Count: " + str(coin_counter)
