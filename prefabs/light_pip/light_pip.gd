@tool
class_name LightPipC extends Area2D

signal finished_activation(pip)

@export var hover_radius: float = 50.0
@export var hover_speed: float = 1.0
@export var noise: FastNoiseLite

const FLY_SPEED: float = 1000.0
const APPROACH_DISTANCE: float = 10.0

@onready var Sprite: Node2D = $Sprite
var activation_cooldown: float = 0.0
var activation_timer: SceneTreeTimer

var time: float = 0.0
var target_node: Node2D
var is_approaching := true
var is_hovering := true
var is_activated := false

func _ready() -> void:
	time = randf() * 1000.0

func _process(delta: float) -> void:
	# Pip is hovering if it has no target.
	# Else it will fly to target with certain speed.
	if is_hovering:
		time += delta*hover_speed
		Sprite.position.x = hover_radius*noise.get_noise_1d(time+500.0)
		Sprite.position.y = hover_radius*noise.get_noise_1d(-time)
	elif is_approaching:
		var diff: Vector2 = target_node.global_position - position
		if diff.length() > APPROACH_DISTANCE:
			position += diff.normalized() * FLY_SPEED * delta
	
	if is_activated:
		queue_redraw()
		
# Play sound/animation and start hovering again.
# After a delay, start flying back to the target.
func activate(delay: float):
	is_hovering = true
	is_activated = true
	is_approaching = true

	activation_timer = get_tree().create_timer(delay)
	activation_cooldown = delay
	await activation_timer.timeout

	is_hovering = false
	is_activated = false
	queue_redraw()
	finished_activation.emit(self)

#func _draw() -> void:
#	if is_activated:
#		var f := activation_timer.time_left / activation_cooldown
#		draw_arc(Sprite.position, 25.0, 0, TAU - TAU * f, 32, Color.WHITE, 2.0, true)
