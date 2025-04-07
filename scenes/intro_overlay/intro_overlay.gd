extends Control

@export var disable := false

func _ready() -> void:
	if disable:
		Global.intro_finished = true
		queue_free()

func allow_movement():
	Global.intro_finished = true
	pass