extends AnimatedSprite2D

@onready var attackeffect: AnimatedSprite2D = $"."
var tool_type:String="hand"


func _ready() -> void:
	z_index=4
	attackeffect.play("sp")

func die():
	queue_free()

func _on_animation_finished() -> void:
	die()
