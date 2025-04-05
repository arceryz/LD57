class_name PlayerC extends CharacterBody2D

@export_group("Game")
@export var hspeed: float = 500.0
@export var jump_velocity: float = 700.0
@export var flap_velocity: float = 700.0

@onready var Wings: Node2D = $Wings
@onready var Anim: AnimationPlayer = $Anim
@onready var OrbHolder: OrbHolderC = $OrbHolder

var jump_charges: int = 1

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
	else:
		velocity += get_gravity() * delta
		if Input.is_action_just_pressed("jump") and OrbHolder.use_orb():
			flap()
	
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * hspeed if direction else move_toward(velocity.x, 0, hspeed)
	move_and_slide()

func is_falling() -> bool:
	return velocity.y > 0 and not is_on_floor()

func flap():
	velocity.y = -flap_velocity
	Anim.play("flap")