class_name CreditsEndingC extends Control

@onready var ReturnButton: Button = %MainMenuBtn
@onready var Anim: AnimationPlayer = $Anim

func _ready() -> void:
	Global.ending_triggered = false
	ReturnButton.pressed.connect(_on_main_menu_pressed)
	hide()

func _on_main_menu_pressed():
	print("Pressing")
	get_tree().change_scene_to_file("uid://oxgxc0rq0ps8")

func trigger_ending():
	Global.ending_triggered = true
	Anim.play("end")
	await Anim.animation_finished
	Global.player_can_move = false
