class_name CreditsEndingC extends Control

@onready var ReturnButton: Button = %MainMenuBtn
@onready var Anim: AnimationPlayer = $Anim
const MainMenuP: PackedScene = preload("uid://oxgxc0rq0ps8")

func _ready() -> void:
	Global.ending_triggered = false
	hide()
	ReturnButton.pressed.connect(_on_main_menu_pressed)

func _on_main_menu_pressed():
	get_tree().change_scene_to_packed(MainMenuP)

func trigger_ending():
	Global.ending_triggered = true
	Anim.play("end")
	await Anim.animation_finished
	Global.player_can_move = false
