extends Area2D

@export var resource_type:='meat'
var reserved:=false
var collected:=false

#------------------------------------------
#Nodes
#------------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collect_audio: AudioStreamPlayer = $collect_audio

func _ready() -> void:
	z_index=5
	animation.play('spawn')
	await animation.animation_finished
	animation.play('idle')

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	if body.is_in_group("pawn"):
		collected=true
		collect()

func collect():
	if not collect_audio.playing:
		collect_audio.play()
	Global.add_meat(1)
	collision_shape_2d.disabled=true
	
	var tween:=create_tween()
	tween.set_parallel(true)
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(tween.TRANS_BACK)

#Fade
	tween.tween_property(self,"modulate:a",0.0,0.5)
#Scale
	tween.tween_property(self,"scale",Vector2(2.5,2.5),0.5)
#Remove
	tween.finished.connect(queue_free)
