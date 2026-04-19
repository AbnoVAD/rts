extends Area2D
@onready var animations: AnimatedSprite2D = $animations

func _ready() -> void:
	z_index=5
	animations.play("sp")

func _on_animations_animation_finished() -> void:
	queue_free()
