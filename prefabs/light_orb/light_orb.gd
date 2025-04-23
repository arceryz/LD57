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

func _ready() -> void:
	time = randf() * 1000.0

func _process(delta: float) -> void:
	match state:
		State.PICKUP:
			process_hover(delta)

		State.FLYING:
			move_to_target(delta)
		
		State.ACTIVATION:
			process_hover(delta)
			enforce_screen_position()
		
		State.ANCHORED:
			pass

func enforce_screen_position():
	var rect := get_viewport_rect()
	var camera: RoomCamera = get_viewport().get_camera_2d()
	var campos := camera.get_screen_center_position()
	rect.position += campos - rect.size / 2.0

	var lightrect := Rect2()
	var radius := 100.0
	lightrect.position = global_position - Vector2.ONE * radius
	lightrect.size = 2 * Vector2.ONE * radius

	if not rect.encloses(lightrect):
		global_position += camera.delta_pos

func move_to_target(delta: float):
	var diff: Vector2 = target_node.global_position - position
	if diff.length() > APPROACH_DISTANCE:
		position += diff.normalized() * fly_speed * delta
	pass

func pickup():
	if Engine.is_editor_hint():return
	%OrbLoop.stop()
	%OrbPickup.play()
	picked_up.emit()
	await get_tree().create_timer(2).timeout
	%Response.play()


func process_hover(delta):
	time += delta * hover_speed
	Sprite.position.x = hover_radius * hover_pattern.get_noise_1d(time+500.0)
	Sprite.position.y = hover_radius * hover_pattern.get_noise_1d(-time)

# Play sound/animation and start hovering again.
# After a delay, start flying back to the target.
func activate(delay: float):
	state = State.ACTIVATION
	print("moving")
	
	var steps := 2
	var step_dur := delay / steps
	var curscale := scale

	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)

	for i in range(steps):
		tw.tween_property(self, "scale", curscale * 1.0, step_dur / 3.0)
		tw.parallel().tween_property(self, "modulate:a", 0.1, step_dur / 3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

		tw.tween_property(self, "scale", curscale * 1.3, step_dur / 3.0)
		tw.parallel().tween_property(self, "modulate:a", 1.0, step_dur / 3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		
		tw.tween_interval(step_dur / 3.0)
	
	tw.tween_property(self, "scale", curscale * 1.0, 0)
	tw.tween_callback(finish_activation)

func finish_activation():
	state = State.FLYING
	finished_activation.emit(self)
