extends Control

@export var disable := false

func _ready() -> void:
	Global.player_can_move = false

	if disable:
		Global.player_can_move = true
		queue_free()

func allow_movement():
	Global.player_can_move = true
	pass