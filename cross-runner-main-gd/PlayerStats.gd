extends Node

var max_health := 3
var health := 3
var invincible := false

signal health_changed

func reset():
	health = max_health
	invincible = false
	health_changed.emit()
