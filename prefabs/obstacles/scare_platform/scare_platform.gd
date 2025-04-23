class_name ScarePlatformC extends PathFollow2D

@export var scare_move_time: float = 1.0
@export var return_wait_time: float = 2.0
@export var return_time: float = 2.0
@onready var TriggerArea: Area2D = $TriggerArea
@onready var Platform: AnimatableBody2D = $Platform

@onready var ScareGuidelightsP: PackedScene = preload("uid://bq3pa8qpn1hel")
var Guidelight: CPUParticles2D
var GuidelightPathFollow: PathFollow2D
var player_nearby := false
var is_guidelight_active := false
var player_can_fly := false

var scare_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TriggerArea.body_entered.connect(_on_trigger_body_entered)
	TriggerArea.body_exited.connect(_on_trigger_body_exited)
	Global.orb_collected.connect(_on_orb_collected)
	construct_guidelight()

func _on_trigger_body_entered(body: Node2D):
	if body is PlayerC:
		player_nearby = true
		body.wing_flapped.connect(trigger)
		trigger_guide()
	pass

func _on_trigger_body_exited(body: Node2D):
	if body is PlayerC:
		player_nearby = false
		body.wing_flapped.disconnect(trigger)
	pass

func _on_orb_collected():
	if not player_can_fly:
		player_can_fly = true
		if player_nearby:
			trigger_guide()

func trigger():
	if scare_tween:
		scare_tween.kill()

	scare_tween = create_tween()
	scare_tween.tween_property(self, "progress_ratio", 1.0, scare_move_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	scare_tween.tween_interval(return_wait_time)
	scare_tween.tween_property(self, "progress_ratio", 0.0, return_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func trigger_guide():
	if is_guidelight_active or not player_can_fly:
		return

	var tween := create_tween()
	GuidelightPathFollow.visible = true	
	Guidelight.emitting = true
	is_guidelight_active = true
	Guidelight.restart()
	tween.set_parallel(true)
	tween.tween_property(GuidelightPathFollow, "modulate:a", 1.0, 0.1)
	tween.tween_property(GuidelightPathFollow, "progress_ratio", 1.0, scare_move_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_parallel(false)

	tween.tween_property(Guidelight, "emitting", false, 0)
	tween.tween_property(GuidelightPathFollow, "modulate:a", 0.0, 2.0)
	tween.tween_property(GuidelightPathFollow, "visible", false, 0)
	tween.tween_property(GuidelightPathFollow, "progress_ratio", 0, 0)
	tween.tween_property(self, "is_guidelight_active", false, 0)
	tween.tween_callback(try_repeat_guidelight)

func try_repeat_guidelight():
	if player_nearby:
		trigger_guide()

func construct_guidelight():
	GuidelightPathFollow = PathFollow2D.new()
	GuidelightPathFollow.loop = false
	GuidelightPathFollow.rotates = false

	Guidelight = ScareGuidelightsP.instantiate()
	GuidelightPathFollow.visible = false
	GuidelightPathFollow.modulate.a = 0

	var parent: Path2D = get_parent()
	var pixel_offset := 40.0
	Guidelight.amount = int(parent.curve.get_baked_length() / (scare_move_time / Guidelight.lifetime * pixel_offset))

	GuidelightPathFollow.add_child(Guidelight)
	get_parent().add_child.call_deferred(GuidelightPathFollow)
