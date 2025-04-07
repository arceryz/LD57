extends Node

var active_checkpoint: CheckpointC
var player_can_move := true
var ending_triggered := false

func _ready() -> void:
	randomize()