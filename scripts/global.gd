extends Node

var active_checkpoint: CheckpointC
var player_can_move := true

func _ready() -> void:
	randomize()