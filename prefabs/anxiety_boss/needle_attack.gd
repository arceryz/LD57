class_name NeedleAttackC extends Area2D

@export var lifetime: float = 4.0
@export var fly_speed: float = 100.0
@export var accel: float = 10.0
@onready var Anim: AnimationPlayer = $Anim
@onready var Sprite: AnimatedSprite2D = %Sprite

enum State {
	WIND_UP,
	FLYING
}

var speed: float = 0.0
var speed_target: float = 0.0
var state := State.WIND_UP
var direction := Vector2.ZERO

func _ready() -> void:
	monitorable = false

func _process(_delta: float) -> void:
	match state:
		State.FLYING:
			speed = lerp(speed, speed_target, _delta * accel)
			global_position += direction * _delta * speed
	pass

func attack(from: Vector2, attack_target: Vector2):
	global_position = from
	look_at(attack_target)
	direction = (attack_target - from).normalized()

	Anim.play("spawn")
	await Anim.animation_finished
	state = State.FLYING
	monitorable = true
	speed_target = fly_speed
	Sprite.play("flying")

	await get_tree().create_timer(lifetime).timeout

	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(queue_free)