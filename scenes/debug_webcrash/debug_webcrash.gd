extends Node2D

@onready var ButtonX = $Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ButtonX.pressed.connect(_on_button_pressed)
	$BossMusic.play()

func _on_button_pressed():
	$BossMusic.stop()
	get_tree().change_scene_to_file.call_deferred("uid://oxgxc0rq0ps8")
	pass