class_name PlayerC extends CharacterBody2D

signal wing_flapped()

@export_group("Game")
@export var hspeed: float = 500.0
@export var jump_velocity: float = 700.0
@export var flap_velocity: float = 700.0
@export var flap_duration: float = 0.3

@onready var OrbHolder: OrbHolderC = $OrbHolder
@onready var HitArea: Area2D = $HitArea
@onready var PlatformLocation: Node2D = $PlatformLocation

const PackedCrystalPlatform := preload("uid://cru4jlhhbwrqb")

enum State {
	GROUND,
	FLYING,
	FALLING
}
var state := State.GROUND
var fly_direction := Vector2.ZERO
var after_flap := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	HitArea.body_entered.connect(_on_hit_body_entered)

func _on_hit_body_entered(_body: Node2D):
	kill()

func _physics_process(delta: float) -> void:
	queue_redraw()
	
	match state:
		State.GROUND:
			if Input.is_action_just_pressed("jump"):
				velocity.y = -jump_velocity
				state = State.FALLING
			if not is_on_floor():
				state = State.FALLING
			if Input.is_action_just_pressed("flap") and OrbHolder.use_orb():
				flap()
			after_flap = false
			process_walk_movement(delta)
			pass
		
		State.FLYING:
			velocity = fly_direction * flap_velocity
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
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
			pass

func process_walk_movement(_delta: float):
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	var direction := Input.get_axis("move_left", "move_right")
	if not (after_flap and is_zero_approx(direction)):
		velocity.x = direction * hspeed if direction else move_toward(velocity.x, 0, hspeed)
		after_flap = false
	move_and_slide()

# Flap once with the wings.
func flap():
	fly_direction = get_local_mouse_position().normalized()
	state = State.FLYING
	after_flap = true
	wing_flapped.emit()
	await get_tree().create_timer(flap_duration).timeout
	state = State.FALLING

# Place platform underneath the player's feet.
func place_platform():
	var plat: CrystalPlatformC = PackedCrystalPlatform.instantiate()
	plat.top_level = true
	plat.global_position = PlatformLocation.global_position
	add_child(plat)

func kill():
	position = Global.active_checkpoint.position

func _draw() -> void:
	var mpos := get_local_mouse_position()
	#draw_line(Vector2.ZERO, mpos, Color.BLUE)
	draw_circle(mpos, 10.0, Color.SKY_BLUE, false, 1.0, true)
