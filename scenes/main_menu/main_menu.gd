extends Control

@export var Level1: PackedScene
@onready var PlayButton: Button = %PlayButton

func _ready() -> void:
	PlayButton.pressed.connect(_on_play_pressed)
	PlayButton.grab_focus()

func _on_play_pressed():
	get_tree().change_scene_to_packed(Level1)
