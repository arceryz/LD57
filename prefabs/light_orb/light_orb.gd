@tool
class_name LightOrbC extends Area2D

signal finished_activation(pip)
signal picked_up

@export_group("Game")
@export var fly_speed: float = 1000.0

@export_group("Visuals")
@export var hover_radius: float = 50.0
@export var hover_speed: float = 1.0
@export var hover_pattern: FastNoiseLite

@onready var Sprite: Node2D = $Sprite
const APPROACH_DISTANCE: float = 10.0

enum State {
	PICKUP,
	ACTIVATION,
	FLYING,
	ANCHORED
}

var state := State.PICKUP
var time: float = 0.0
var target_node: Node2D

var activation_cooldown: float = 0.0
var activation_timer: SceneTreeTimer

func _ready() -> void:
	time = randf() * 1000.0

func _process(delta: float) -> void:
	match state:
		State.PICKUP:
			process_hover(delta)

		State.FLYING:
			var diff: Vector2 = target_node.global_position - position
			if diff.length() > APPROACH_DISTANCE:
				position += diff.normalized() * fly_speed * delta
		
		State.ACTIVATION:
			process_hover(delta)
			queue_redraw()
		
		State.ANCHORED:
			pass

func pickup():
	if Engine.is_editor_hint():return
	%OrbLoop.stop()
	%OrbPickup.play()
	await get_tree().create_timer(2).timeout
	%Response.play()
	picked_up.emit()


func process_hover(delta):
	time += delta * hover_speed
	Sprite.position.x = hover_radius * hover_pattern.get_noise_1d(time+500.0)
	Sprite.position.y = hover_radius * hover_pattern.get_noise_1d(-time)

# Play sound/animation and start hovering again.
# After a delay, start flying back to the target.
func activate(delay: float):
	state = State.ACTIVATION

	activation_timer = get_tree().create_timer(delay)
	activation_cooldown = delay
	await activation_timer.timeout

	state = State.FLYING
	queue_redraw()
	finished_activation.emit(self)

# This code is for a progress circle to indicate activation delay.
#func _draw() -> void:
#	if is_activated:
#		var f := activation_timer.time_left / activation_cooldown
#		draw_arc(Sprite.position, 25.0, 0, TAU - TAU * f, 32, Color.WHITE, 2.0, true)
