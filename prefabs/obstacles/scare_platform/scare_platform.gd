class_name ScarePlatformC extends PathFollow2D

@export var scare_move_time: float = 1.0
@export var return_wait_time: float = 2.0
@export var return_time: float = 2.0
@onready var TriggerArea: Area2D = $TriggerArea
@onready var Platform: AnimatableBody2D = $Platform

var player_nearby := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TriggerArea.body_entered.connect(_on_trigger_body_entered)
	TriggerArea.body_exited.connect(_on_trigger_body_exited)

func _on_trigger_body_entered(body: Node2D):
	if body is PlayerC:
		player_nearby = true
		body.wing_flapped.connect(trigger)
	pass

func _on_trigger_body_exited(body: Node2D):
	if body is PlayerC:
		player_nearby = false
		body.wing_flapped.disconnect(trigger)
	pass

func trigger():
	if self.progress_ratio > 0:
		return

	var tween := create_tween()
	#tween.set_parallel(true)
	#tween.tween_property(self, "modulate:a", 0.3, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	#tween.tween_property(Platform, "collision_layer", 0, 0)
	#tween.set_parallel(false)
	tween.tween_property(self, "progress_ratio", 1.0, scare_move_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	#tween.tween_property(Platform, "collision_layer", 1, 0)
	#tween.tween_property(self, "modulate:a", 1.0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(return_wait_time)
	tween.tween_property(self, "progress_ratio", 0.0, return_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
