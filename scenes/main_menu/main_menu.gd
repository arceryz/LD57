extends Control

@onready var PlayButton: Button = %PlayButton

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PlayButton.pressed.connect(_on_play_pressed)
	PlayButton.grab_focus()

func _on_play_pressed():
	$AnimationPlayer.play("play")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("uid://bofpqf5so0am4")
