extends CharacterBody2D

@onready var terget=$"../playerTEST"

var speed=150
func _physics_process(delta):
	var direction=(terget.position-position).normalized()
	velocity=direction * speed
	look_at(terget.position)
	move_and_slide() 
