class_name AnxietyBoss extends PathFollow2D

@export var comfort_distance: float = 300.0
@export var move_speed: float = 1000.0
@export var needle_spawn_range: float = 100.0
@export var attack_interval: float = 1.0
@export var attack_interval_variation: float = 1.0
@export var attack_count_variation: int = 1

@export var StartArea: Area2D
@export var NoReturnWallBack: StaticBody2D
@export var WaitWallFront: StaticBody2D

@onready var Sprite: AnimatedSprite2D = %Sprite
@onready var Anim: AnimationPlayer = $Anim
@onready var Music: AudioStreamPlayer = $BossMusic
const NeedleProjectileP: PackedScene = preload("uid://butpnmv72t18n")
const LightOrbP: PackedScene = preload("uid://dq45dri0s7nq4")

enum State {
	WAITING,
	WAKING_UP,
	ACTIVE,
	DEATH
}

var state := State.WAITING
var attack_timer: Timer

func _ready() -> void:
	attack_timer = Timer.new()
	set_attack_interval()
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

	StartArea.body_entered.connect(_on_area_body_entered)
	pass

func _process(_delta: float) -> void:
	match state:
		State.WAITING:
			pass
		State.WAKING_UP:
			pass
		State.ACTIVE:
			var player: Node2D = get_tree().get_first_node_in_group("player")
			var distance := absf(player.global_position.x - global_position.x)
			var stray := signf(comfort_distance - distance)
			
			progress += _delta * move_speed * stray
			
			if progress_ratio == 1.0 and distance < 500:
				do_death()
			pass
		State.DEATH:
			# Effects when death -> see do_death() function.
			pass
	pass

func _on_attack_timer_timeout():
	for i in range(randi_range(1, 1+attack_count_variation)):
		spawn_needle()
	set_attack_interval()

func set_attack_interval():
	attack_timer.wait_time = attack_interval + randf() * attack_interval_variation
	pass

func spawn_needle():
	var needle: NeedleAttackC = NeedleProjectileP.instantiate()
	add_child(needle)
	needle.top_level = true

	var player: Node2D = get_tree().get_first_node_in_group("player")
	var spawn_pos := global_position + Vector2(randf_range(0.0, needle_spawn_range), 0).rotated(randf_range(0, TAU))
	var attack_pos := player.global_position
	needle.attack(spawn_pos, attack_pos)
	$Boss_Needles_Rotation.play()
	pass

func do_death():
	state = State.DEATH
	attack_timer.stop()

	Music["parameters/switch_to_clip"] = "Depths Anxiety Outro"
	$Boss_VoiceLayer01.stop()
	$Boss_VoiceLayer02.stop()
	$Boss_VoiceLayer03.stop()
	$Boss_Texture_Layer.stop()

	Anim.play("death")
	await Anim.animation_finished
	var orb: LightOrbC = LightOrbP.instantiate()
	get_tree().get_first_node_in_group("level").add_child(orb)
	orb.global_position = Sprite.global_position
	orb.scale *= 3.0
	orb.modulate.a = 0

	var ending: CreditsEndingC = get_tree().get_first_node_in_group("ending")
	orb.picked_up.connect(ending.trigger_ending)
	var tw := orb.create_tween()
	tw.tween_property(orb, "modulate:a", 1.0, 2.0)
	tw.parallel().tween_property($Light, "energy", 0, 2.0)
	tw.tween_callback($BossMusic.queue_free)
	tw.tween_callback(self.queue_free)


func _on_area_body_entered(body: Node2D):
	if body is PlayerC and state == State.WAITING:
		state = State.WAKING_UP
		NoReturnWallBack.collision_layer = 1
		$BossMusic.play()
		$Boss_VoiceLayer01.play()
		$Boss_VoiceLayer02.play()
		$Boss_VoiceLayer03.play()
		Anim.play("wakeup")
		await Anim.animation_finished
		WaitWallFront.collision_layer = 0
		state = State.ACTIVE
		attack_timer.start()
		pass
	pass
