extends Control

var blessing_of_ares := false

@onready var wings_button = $Shield/WarCouncil/WingsOfHermes
@onready var ambrosia_button = $Shield/WarCouncil/Ambrosia
@onready var admin_menu = $Shield  # The root node of the admin menu (CanvasLayer)

func _ready():
	# Hide the menu at the start
	admin_menu.visible = false

	# Connect the buttons to functions
	if wings_button:
		wings_button.pressed.connect(toggle_blessing)
	else:
		print("Error: WingsOfHermes button not found.")
		
	if ambrosia_button:
		ambrosia_button.pressed.connect(grant_ambrosia)
	else:
		print("Error: Ambrosia button not found.")

func _process(delta: float) -> void:
	# Check if the "M" key is pressed
	if Input.is_action_just_pressed("ui_select"):  # "ui_select" defaults to "M" in Godot (you can change this in the Input Map)
		toggle_admin_menu()

func toggle_admin_menu():
	# Toggle the visibility of the admin menu
	admin_menu.visible = not admin_menu.visible
	print("Admin Menu Visible: " + str(admin_menu.visible))  # Optional: Debug message

func toggle_blessing():
	blessing_of_ares = !blessing_of_ares

	# Get the player node and call set_fly_mode if it exists
	var warrior = get_tree().get_first_node_in_group("player")
	if warrior and warrior.has_method("set_fly_mode"):
		warrior.set_fly_mode(blessing_of_ares)
	else:
		print("Error: Player node not found or 'set_fly_mode' method is missing.")

func grant_ambrosia():
	if PlayerStats:  # Ensure PlayerStats exists and is valid
		PlayerStats.health = min(PlayerStats.health + 1, PlayerStats.max_health)
		PlayerStats.health_changed.emit()
	else:
		print("Error: PlayerStats not found or not initialized.")
