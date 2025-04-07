extends Node

var active_checkpoint: CheckpointC
var intro_finished := false

func _ready() -> void:
	randomize()