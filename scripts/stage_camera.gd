@tool
extends Camera2D

@export var stage_width: int = 1920
@export var stage_height: int = 1080

@export var debug_stage_range: int = 3:
	set(v):
		debug_stage_range = v
		queue_redraw()
@export var debug_stages := true:
	set(v):
		debug_stages = v
		queue_redraw()

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

func _process(_delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	position.x = floor(player.position.x / stage_width) * stage_width
	position.y = floor(player.position.y / stage_height) * stage_height
	pass

func _draw() -> void:
	if not Engine.is_editor_hint() or not debug_stages:
		return
	for x in range(-debug_stage_range, debug_stage_range):
		for y in range(-debug_stage_range+1, debug_stage_range+1):
			var rect := Rect2()
			rect.position = Vector2(x*stage_width, -y*stage_height)
			rect.size = Vector2(stage_width, stage_height)
			draw_rect(rect, Color.DARK_GRAY, false)