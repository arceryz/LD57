class_name RoomCamera extends Camera2D

var active_room: RoomC
var room_center := Vector2.ZERO
var room_size := Vector2.ZERO
var offset2 := Vector2.ZERO

func _ready() -> void:
	for el in get_tree().get_nodes_in_group("room"):
		var room: RoomC = el
		room.body_entered.connect(_on_room_body_entered.bind(room))

func _process(delta: float) -> void:
	process_position(delta)

func _on_room_body_entered(body: Node2D, room: RoomC):
	if body is PlayerC:
		var cs: CollisionShape2D = room.get_child(0)
		var shape: RectangleShape2D = cs.shape
		room_size = shape.size
		room_center = cs.global_position

		print(room_size)
		var halfsize := room_size / 2.0
		limit_left = int(cs.position.x - halfsize.x)
		limit_top = int(cs.position.y - halfsize.y)
		limit_right = int(cs.position.x + halfsize.x)
		limit_bottom = int(cs.position.y + halfsize.y)

		# First time we must teleport to the player.
		if active_room == null:
			process_position(0)
			reset_smoothing()
		active_room = room

		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(self, "zoom", Vector2.ONE * room.camera_zoom, 3.0)
		tw.tween_property(self, "offset2", room.camera_offset, 3.0)
		print("Player entered %s" % room.name)
	pass

func process_position(_delta: float):
	var player: Node2D = get_tree().get_first_node_in_group("player")
	position = player.global_position + offset2

	# Just in case.
	if active_room != null:
		var viewport := get_viewport_rect()
		if room_size.x < viewport.size.x:
			position.x = room_center.x
		if room_size.y < viewport.size.y:
			position.y = room_center.y
