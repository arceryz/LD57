extends Sprite2D

@export var light_orb: LightOrbC

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	light_orb.picked_up.connect(fadein)


func fadein():
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 1.0)