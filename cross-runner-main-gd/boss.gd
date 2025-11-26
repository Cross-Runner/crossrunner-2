# boss.gd
extends CharacterBody2D

@export var max_health: int = 100
@export var attack_damage: int = 20
@export var attack_cooldown_time: float = 1.5
@export var attack_hit_duration: float = 0.2

var health: int
var can_attack: bool = true
var player: Node = null

# expected children (exact names)
@onready var player_detect: Area2D = $PlayerDetect
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var cooldown_timer: Timer = $AttackCooldown
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var healthbar = $Healthbar

func _ready() -> void:
	health = max_health
	if health_bar:
		healthbar.init_health(health)
		health_bar.max_value = max_health
		health_bar.value = health
		healthbar.health = health

	attack_hitbox.monitoring = false
	can_attack = true

	# Connect signals using the stable connect API
	if player_detect:
		player_detect.connect("body_entered", Callable(self, "_on_player_detected"))
		player_detect.connect("body_exited",  Callable(self, "_on_player_exited"))
	else:
		push_warning("Boss: missing PlayerDetect node")

	if attack_hitbox:
		attack_hitbox.connect("body_entered", Callable(self, "_on_attack_hitbox_entered"))
	else:
		push_warning("Boss: missing AttackHitbox node")

	if cooldown_timer:
		cooldown_timer.one_shot = true
		cooldown_timer.wait_time = attack_cooldown_time
		cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))
	else:
		push_warning("Boss: missing AttackCooldown Timer node")

	if anim_player:
		anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

	print_debug("[BOSS] ready (health=%d)" % health)

func _on_player_detected(body: Node) -> void:
	if body and body.is_in_group("player"):
		print_debug("[BOSS] player detected: %s" % body.name)
		player = body
		_try_attack()

func _on_player_exited(body: Node) -> void:
	if body == player:
		print_debug("[BOSS] player left")
		player = null

func _try_attack() -> void:
	if not player or not can_attack:
		return
	can_attack = false
	print_debug("[BOSS] attack start")
	# enable hitbox for a short time (animation optional)
	_enable_hitbox_temporarily(attack_hit_duration)
	if cooldown_timer:
		cooldown_timer.start()
	else:
		# fallback timer via SceneTree
		get_tree().create_timer(attack_cooldown_time).connect("timeout", Callable(self, "_on_cooldown_timeout"))

func _enable_hitbox_temporarily(duration: float) -> void:
	attack_hitbox.monitoring = true
	print_debug("[BOSS] hitbox ON")
	# Use scene tree timer to disable after 'duration'
	get_tree().create_timer(duration).connect("timeout", Callable(self, "_disable_hitbox"))

func _disable_hitbox() -> void:
	attack_hitbox.monitoring = false
	print_debug("[BOSS] hitbox OFF")

func _on_attack_hitbox_entered(body: Node) -> void:
	if body and body.is_in_group("player"):
		print_debug("[BOSS] hit player: %s" % body.name)
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
		else:
			print_debug("[BOSS] player missing take_damage()")

func _on_cooldown_timeout() -> void:
	can_attack = true
	print_debug("[BOSS] cooldown done")
	if player:
		_try_attack()

func take_damage(amount: int) -> void:
	health -= amount
	print_debug("[BOSS] took %d dmg -> hp %d" % [amount, health])
	if health_bar:
		health_bar.value = max(0, health)
	if health <= 0:
		_die()

func _die() -> void:
	print_debug("[BOSS] died")
	# disable interactions
	set_physics_process(false)
	if collision_shape:
		collision_shape.disabled = true
	attack_hitbox.monitoring = false
	queue_free()

func _on_animation_finished(anim_name: String) -> void:
	# keep this for safety if you add animations later
	if anim_name == "death":
		queue_free()

func print_debug(text: String) -> void:
	# print only in editor or debug builds
	if Engine.is_editor_hint() or OS.is_debug_build():
		print(text)
