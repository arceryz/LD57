@tool
class_name PipHolderC extends Area2D

@export_group("Visuals")
@export var debug_count := 3
@export_range(0, 200.0) var xradius: float = 100.0
@export_range(0, 200.0) var yradius: float = 150.0
@export_range(0, 100.0) var variation: float = 30.0
@export_range(0, 3.0) var rotation_speed: float = 0.3
@export var noise: FastNoiseLite

const PIP_RECOVERY_TIME: float = 1.0

const PackedLightPip := preload("uid://dq45dri0s7nq4")
var rng := RandomNumberGenerator.new()
var time := 0.0

var anchored_pips: Array[LightPipC] = []
var all_collected_pips: Array[LightPipC] = []
var random_seeds: Array[int] = []
var reposition_tween: Tween
var reposition_start_points: Array[Vector2] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	if Engine.is_editor_hint():
		for i in range(debug_count):
			var pip := PackedLightPip.instantiate()
			add_child(pip)
			receive_pip(pip)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		reposition_anchored_pips()
	time = wrap(time+rotation_speed*delta, 0, 1)
	
	# Anchored pips get their position updated.
	for i in range(len(anchored_pips)):
		var pip: LightPipC = anchored_pips[i]
		pip.position = global_position +  sample_pip_trajectory(i)

func sample_pip_trajectory(i: int) -> Vector2:
	return sample_trajectory(time + float(i) / len(anchored_pips), random_seeds[i])

func sample_trajectory(t: float, randomseed: int) -> Vector2:
	rng.seed = randomseed
	var vec := Vector2.ZERO
	var noise1 := noise.get_noise_2d(rng.randf()*1000.0 + time, rng.randf()*1000.0)
	var noise2 := noise.get_noise_2d(rng.randf()*1000.0 - time, rng.randf()*1000.0)
	vec.x = (xradius + noise1 * variation) * cos(t*TAU)
	vec.y = (yradius + noise2 * variation) * sin(t*TAU)
	return vec

func _on_area_entered(newpip: Area2D):
	# Incoming pips get added back to the list.
	if newpip is LightPipC:
		receive_pip(newpip)

func receive_pip(newpip: LightPipC):
	if not Engine.is_editor_hint():
		if newpip not in get_overlapping_areas(): return
		if newpip.is_activated: return
		if newpip in anchored_pips: return
	anchored_pips.append(newpip)

	# First time.
	if newpip not in all_collected_pips:
		random_seeds.append(randi())
		reposition_start_points.append(Vector2.ZERO)
		all_collected_pips.append(newpip)
		newpip.finished_activation.connect(receive_pip)

	newpip.target_node = self
	newpip.is_hovering = false
	newpip.is_approaching = false
	reposition_anchored_pips()
	pass

func reposition_anchored_pips():
	if reposition_tween: reposition_tween.kill()
	for i in range(len(anchored_pips)):
		reposition_start_points[i] = anchored_pips[i].global_position - global_position
	reposition_tween = create_tween()
	reposition_tween.tween_method(reposition_lerp_pips, 0.0, 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func reposition_lerp_pips(f: float):
	for i in range(len(anchored_pips)):
		var pip: LightPipC = anchored_pips[i]
		pip.position = global_position + lerp(reposition_start_points[i], sample_pip_trajectory(i), f)
	pass

# We try to take an anchored pip and activate it,
# if we have pips left, returns true.
# Pips return automatically after hovering for a while.
func use_pip() -> bool:
	if len(anchored_pips) == 0:
		return false
	var pip: LightPipC = anchored_pips.pop_back()
	pip.activate(PIP_RECOVERY_TIME)
	return true
