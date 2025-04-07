extends Control

@export var disable := false

func _ready() -> void:
	if disable:
		queue_free()

func allow_movement():
	Global.intro_finished = true
	pass