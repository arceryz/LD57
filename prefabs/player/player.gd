class_name PlayerC extends CharacterBody2D

const SPEED: float = 500.0
const JUMP_VELOCITY: float = 700.0
const JUMP_CHARGE_RESET_SEC: float = 2.0
const FLY_VELOCITY: float = 700.0

@onready var Wings: Node2D = $Wings
@onready var Anim: AnimationPlayer = $Anim
@onready var PipHolder: PipHolderC = $PipHolder

var jump_charges: int = 1

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -JUMP_VELOCITY
	else:
		velocity += get_gravity() * delta
		if Input.is_action_just_pressed("jump") and PipHolder.use_pip():
			flap()
	
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func is_falling() -> bool:
	return velocity.y > 0 and not is_on_floor()

func flap():
	velocity.y = -FLY_VELOCITY
	Anim.play("flap")