@tool
class_name CrystalPlatformC extends StaticBody2D

@export var platform_lifetime = 2.0
var timer: SceneTreeTimer

func _ready() -> void:
	if not Engine.is_editor_hint():
		timer = get_tree().create_timer(platform_lifetime)
		await timer.timeout
		queue_free()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var rect := Rect2()
	rect.size = Vector2(96, 16)
	rect.position.x = -rect.size.x / 2.0
	
	var color := Color.WHITE
	if timer != null:
		color.a = timer.time_left / platform_lifetime
	draw_rect(rect, color, false, 1.0, true)