extends CharacterBody2D

var health = 1 # Initial health


@onready var healthbar = $Healthbar

func _ready():
	# Assuming you fixed the node name to $Hurtbox from the previous issues
	$Hurtbox.area_entered.connect(_on_hurtbox_entered)
	# Change the 6 to your desired starting health (e.g., 100)
	health = 3
	healthbar.init_health(health)

	
	

func _on_hurtbox_entered(area):
	# Check if the colliding area is a player attack hitbox
	if area.name == "PlayerSwordHitbox" or area.is_in_group("player_attacks"):
		# 💥 ONE-TAP FIX: Pass a damage amount guaranteed to be higher than the boss's health
		take_damage(1) 

# --- New Functions ---

func take_damage(amount):
	health -= amount
	print("Boss took damage! Health is now: ", health)
	
	if health <= 0:
		die()

func die():
	print("Boss has been defeated!")
	# You would usually add animations or effects here before removing the boss
	queue_free() # Removes the boss node from the scene
	
	
func _set_health(value):
	health = value   # <--- This replaces the red line
	
	if health <= 0: # I removed 'and is_alive' to keep it simple
		die()	
