class_name AnxietyBoss extends PathFollow2D

@export var comfort_distance: float = 300.0
@export var move_speed: float = 1000.0

@export var StartArea: Area2D
@onready var Sprite: AnimatedSprite2D = $Sprite
@onready var Anim: AnimationPlayer = $Anim
@onready var Music: AudioStreamPlayer = $BossMusic

enum State {
	WAITING,
	ACTIVE,
	DEATH
}

var state := State.WAITING

func _ready() -> void:
	StartArea.body_entered.connect(_on_area_body_entered)
	pass

func _process(_delta: float) -> void:
	match state:
		State.WAITING:
			pass
		State.ACTIVE:
			var player: Node2D = get_tree().get_first_node_in_group("player")
			var distance := absf(player.global_position.x - global_position.x)
			var stray := signf(comfort_distance - distance)
			
			progress += _delta * move_speed * stray
			pass
		State.DEATH:
			Music["parameters/switch_to_clip"] = "Depths Anxiety Outro"
			pass
	pass

func _on_area_body_entered(body: Node2D):
	if body is PlayerC and state == State.WAITING:
		$BossMusic.play()
		Anim.play("wakeup")
		await Anim.animation_finished
		state = State.ACTIVE
		pass
	pass
