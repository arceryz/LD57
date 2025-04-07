extends Control

@onready var MainMenuButton: Button = %MainMenu
@onready var ReturnButton: Button = %Return
@onready var Root: ColorRect = $ColorRect

const MainMenuP: PackedScene = preload("uid://oxgxc0rq0ps8")

var is_active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Root.hide()
	MainMenuButton.pressed.connect(_on_main_menu_pressed)
	ReturnButton.pressed.connect(_on_return_pressed)

func _on_main_menu_pressed():
	get_tree().change_scene_to_packed(MainMenuP)

func _on_return_pressed():
	toggle_active()

func _process(_delta: float) -> void:
	queue_redraw()

func toggle_active():
	if is_active:
		get_tree().paused = false
		Root.hide()
	else:
		get_tree().paused = true
		Root.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_active()
		pass
	pass

func _draw() -> void:
	var mpos := get_local_mouse_position()
	draw_circle(mpos, 10.0, Color.SKY_BLUE, false, 1.0, true)