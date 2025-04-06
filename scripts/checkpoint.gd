class_name CheckpointC extends Area2D

@export var order_index := 0

func _ready() -> void:
	body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node2D):
	if body is PlayerC:
		if Global.active_checkpoint != null:
			if Global.active_checkpoint.order_index > order_index:
				return
		print("Checkpoint is %s" % name)
		Global.active_checkpoint = self
				