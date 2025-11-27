extends Control  # eller CanvasLayer, alt etter hva du bruker

@onready var quit_button = $VBoxContainer/QuitButton
@onready var quit_popup = $QuitPopup


func _ready():
	# Koble knappene
	quit_button.pressed.connect(_on_quit_button_pressed)
	quit_popup.confirmed.connect(_on_quit_confirmed)
	quit_popup.canceled.connect(_on_quit_canceled)


# Når Quit-knappen trykkes
func _on_quit_button_pressed():
	quit_popup.title = "Quit Game?"
	quit_popup.dialog_text = "Are you sure you want to quit?"
	quit_popup.popup_centered()


# Når man trykker OK i popup
func _on_quit_confirmed():
	get_tree().quit()


# Når man trykker Cancel i popup
func _on_quit_canceled():
	quit_popup.hide()
