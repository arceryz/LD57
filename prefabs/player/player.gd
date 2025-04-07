class_name PlayerC extends CharacterBody2D

signal wing_flapped()

@export_group("Game")
@export var hspeed: float = 500.0
@export var jump_velocity: float = 700.0
@export var flap_velocity: float = 700.0
@export var flap_after_velocity: float = 100.0

@export var flap_windup: float = 0.05
@export var flap_winddown: float = 0.05
@export var flap_duration: float = 0.3

@export var walk_accel: float = 20.0
@export var walk_deaccel: float = 30.0
@export var start_orbs: int = 0

@onready var OrbHolder: OrbHolderC = $OrbHolder
@onready var HitArea: Area2D = $HitArea
@onready var PlatformLocation: Node2D = $PlatformLocation
@onready var Sprite: AnimatedSprite2D = $Sprite

const PackedCrystalPlatform := preload("uid://cru4jlhhbwrqb")

enum State {
	GROUND,
	FLYING,
	FALLING,
	RESPAWNING,
}
var state := State.GROUND
var fly_direction := Vector2.ZERO
var fly_speed: float = 0.0
var target_hvelocity := 0.0
var immunity := false

func _ready() -> void:
	HitArea.body_entered.connect(_on_hit_body_entered)
	Sprite.frame_changed.connect(OnFrameChange)
	HitArea.area_entered.connect(_on_hit_body_entered)
	for i in range(start_orbs):
		OrbHolder.generate_orb.call_deferred()
	
	Sprite.animation = "walk"
	Sprite.speed_scale = 0

func _on_hit_body_entered(_body: Node2D):
	kill()

func _physics_process(delta: float) -> void:
	if not Global.player_can_move:
		return
	
	Sprite.flip_h = velocity.x < 0

	match state:
		State.GROUND:
			if Input.is_action_just_pressed("jump"):
				velocity.y = -jump_velocity
				state = State.FALLING
			if not is_on_floor():
				state = State.FALLING
			if Input.is_action_just_pressed("flap") and OrbHolder.use_orb():
				flap()
			process_walk_movement(delta)
			pass
		
		State.FLYING:
			velocity = fly_direction * fly_speed
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
			Sprite.speed_scale = 1.0
			Sprite.animation = "flying"
			move_and_slide()
			pass
		
		State.FALLING:
			velocity += get_gravity() * delta
			if is_on_floor():
				state = State.GROUND
			if Input.is_action_just_pressed("flap") and OrbHolder.use_orb():
				flap()
			if Input.is_action_just_pressed("place_platform") and OrbHolder.use_orb():
				place_platform()
			process_walk_movement(delta)
			Sprite.speed_scale = 0.0
			pass

func process_walk_movement(_delta: float):
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	var direction := Input.get_axis("move_left", "move_right")
	target_hvelocity = direction * hspeed
	Sprite.animation = "walk"
	Sprite.speed_scale = 0.0 if is_zero_approx(direction) else 1.0

	var acc := walk_deaccel if is_zero_approx(direction) else walk_accel
	velocity.x = lerp(velocity.x, target_hvelocity, acc * _delta)
	move_and_slide()

# Flap once with the wings.
func flap():
	fly_direction = get_local_mouse_position().normalized()
	state = State.FLYING
	wing_flapped.emit()
	$Flap.play()
	
	var tw := create_tween()
	tw.tween_property(self, "fly_speed", flap_velocity, flap_windup)
	tw.tween_interval(flap_duration)
	tw.tween_property(self, "fly_speed", flap_after_velocity, flap_winddown)
	tw.tween_property(self, "state", State.FALLING, 0)

# Place platform underneath the player's feet.
func place_platform():
	var plat: CrystalPlatformC = PackedCrystalPlatform.instantiate()
	plat.top_level = true
	plat.global_position = PlatformLocation.global_position
	add_child(plat)
	$Place_Platform_SFX.play()

func kill():
	if immunity or state == State.RESPAWNING:
		return
	immunity = true
	state = State.RESPAWNING
	var tw := create_tween()

	tw.tween_property(self, "modulate", Color.RED, 0.5)
	tw.tween_interval(0.5)
	tw.tween_property(self, "position", Global.active_checkpoint.position, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "state", State.GROUND, 0)
	tw.tween_interval(1.0)
	tw.tween_property(self, "modulate", Color.WHITE, 0.5)
	tw.tween_property(self, "immunity", false, 0)

func OnFrameChange(): 
	if (Sprite.frame==1 or Sprite.frame==3) and state==State.GROUND:
		$Footstep.play()
