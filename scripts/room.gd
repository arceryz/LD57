@tool
class_name RoomC extends Node

@export var force_screen_width := false
@export var force_screen_height := false

func _init() -> void:
	add_to_group("room")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var sw := 1920
		var sh := 1080

		if get_child_count() == 0: return
		var cs: CollisionShape2D = get_child(0)
		var shape: RectangleShape2D = cs.shape
		shape.size.x = max(sw, shape.size.x)
		shape.size.y = max(sh, shape.size.y)

		if force_screen_width: shape.size.x = sw
		if force_screen_height: shape.size.y = sh
	pass
