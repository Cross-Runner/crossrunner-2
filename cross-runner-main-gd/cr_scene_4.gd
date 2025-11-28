extends Node

@export var main_menu_scene: String = "res://MainMenu.tscn"
var is_paused := false

# På ready kobler vi knappene og skjuler popup
func _ready():
	# Popup starter skjult
	$CanvasLayer/PausePopup.visible = false

	# Koble knappene til funksjoner
	var resume_button = $CanvasLayer/PausePopup/VBoxContainer/resume
	var mainmenu_button = $CanvasLayer/PausePopup/VBoxContainer/mainmenu

	resume_button.pressed.connect(_on_resume_pressed)
	mainmenu_button.pressed.connect(_on_main_menu_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	$CanvasLayer/PausePopup.visible = is_paused

func _on_resume_pressed():
	toggle_pause()

func _on_main_menu_pressed():
	# Gå til Main Menu og fjern pause
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)
