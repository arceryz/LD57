@tool
class_name OrbHolderC extends Area2D

@export_group("Game")
@export var orb_recovery_time: float = 1.0

@export_group("Visuals")
@export var debug_count := 3
@export_range(0, 200.0) var rotation_xradius: float = 100.0
@export_range(0, 200.0) var rotation_yradius: float = 150.0
@export_range(0, 100.0) var rotation_variation: float = 30.0
@export_range(0, 3.0) var rotation_speed: float = 0.3
@export var rotation_pattern: FastNoiseLite

const PackedLightOrb := preload("uid://dq45dri0s7nq4")
var rng := RandomNumberGenerator.new()
var time := 0.0
var reposition_tween: Tween

# For each orb.
var anchored_orbs: Array[LightOrbC] = []
var all_collected_orbs: Array[LightOrbC] = []
var random_seeds: Array[int] = []
var reposition_start_points: Array[Vector2] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if Engine.is_editor_hint():
		for i in range(debug_count):
			generate_orb.call_deferred()
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		reposition_anchored_orbs()
	time = wrap(time+rotation_speed*delta, 0, 1)
	
	# Anchored orbs get their position updated.
	for i in range(len(anchored_orbs)):
		var orb: LightOrbC = anchored_orbs[i]
		orb.position = global_position +  sample_orb_trajectory(i)
	pass

func _on_area_entered(neworb: Area2D):
	# Incoming orbs get added back to the list.
	if neworb is LightOrbC:
		receive_orb(neworb)
	pass

func sample_orb_trajectory(i: int) -> Vector2:
	return sample_trajectory(time + float(i) / len(anchored_orbs), random_seeds[i])

func sample_trajectory(t: float, randomseed: int) -> Vector2:
	rng.seed = randomseed
	var vec := Vector2.ZERO
	var noise1 := rotation_pattern.get_noise_2d(rng.randf()*1000.0 + time, rng.randf()*1000.0)
	var noise2 := rotation_pattern.get_noise_2d(rng.randf()*1000.0 - time, rng.randf()*1000.0)
	vec.x = (rotation_xradius + noise1 * rotation_variation) * cos(t*TAU)
	vec.y = (rotation_yradius + noise2 * rotation_variation) * sin(t*TAU)
	return vec

# When an orb is to be added back, this function is called.
func receive_orb(neworb: LightOrbC):
	if not Engine.is_editor_hint():
		if neworb not in get_overlapping_areas(): return
		if neworb.state == LightOrbC.State.ACTIVATION: return
		if neworb in anchored_orbs: return
	anchored_orbs.append(neworb)

	# First time that the orb is added we add additional variables.
	if neworb not in all_collected_orbs:
		random_seeds.append(randi())
		reposition_start_points.append(Vector2.ZERO)
		all_collected_orbs.append(neworb)
		neworb.finished_activation.connect(receive_orb)
		neworb.pickup()
		Global.orb_collected.emit()

	neworb.target_node = self
	neworb.state = LightOrbC.State.ANCHORED
	if not Engine.is_editor_hint():
		reposition_anchored_orbs()
	pass

# Call this to smoothly interpolate orbs to their trajectories.
# Called when the amount of orbs change.
func reposition_anchored_orbs():
	if reposition_tween: reposition_tween.kill()
	for i in range(len(anchored_orbs)):
		reposition_start_points[i] = anchored_orbs[i].global_position - global_position
	reposition_tween = create_tween()
	reposition_tween.tween_method(reposition_lerp_orbs, 0.0, 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	pass

func reposition_lerp_orbs(f: float):
	for i in range(len(anchored_orbs)):
		var orb: LightOrbC = anchored_orbs[i]
		orb.position = global_position + lerp(reposition_start_points[i], sample_orb_trajectory(i), f)
	pass

# Uses an orb by un-anchoring it, and letting it fly back to the holder.
# It is removed from the anchored list.
# Returns whether orb could be removed successfully.
func use_orb() -> bool:
	if len(anchored_orbs) == 0:
		return false
	var orb: LightOrbC = anchored_orbs.pop_back()
	orb.activate(orb_recovery_time)
	return true

func generate_orb():
	var orb := PackedLightOrb.instantiate()
	orb.top_level = true
	add_child(orb)
	orb.global_position = global_position
	receive_orb(orb)
