extends Area2D

@onready var animation: AnimatedSprite2D = $animation
@onready var tnt: Area2D = $"."


#variables
var velocity:Vector2=Vector2.ZERO
var stuck:bool=false
var stuck_body:Node2D=null
var stick_offset:Vector2=Vector2.ZERO

#variables of group affected by dynamite
@export var stick_groups:Array=["player","building","castle"]

#dynamite lifespan
@export var lifespan:float=0.3

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_start_lifespan_timer()

#launch dynamite
func launch(target_position:Vector2,speed:float) -> void:
	velocity=(target_position-global_position).normalized()*speed
	rotation=velocity.angle()

func _physics_process(delta: float) -> void:
	if stuck:
		if is_instance_valid(stuck_body):
			global_position=stuck_body.global_position+stick_offset
		return

	global_position+=velocity*delta
	rotation=velocity.angle()

func _on_body_entered(body: Node2D) -> void:
	if stuck:
		return

	var can_stick:bool=false
	for group in stick_groups:
		if body.is_in_group(group) or body.name==group:
			can_stick=true
			break
	if not can_stick:
		return
	stuck=true
	stuck_body=body
	velocity=Vector2.ZERO
	stick_offset=global_position-body.global_position

	_fade_and_die()

func _start_lifespan_timer() -> void:
	await get_tree().create_timer(lifespan).timeout
	if not stuck:
		_fade_and_die()

func _fade_and_die():
	await get_tree().create_timer(0.15).timeout
	spawn_explosion()
	var tween:=create_tween()
	tween.tween_property(self,"modulate.a",0.0,0.25)
	tween.finished.connect(queue_free)

func spawn_explosion():
	await get_tree().create_timer(0.1).timeout
	var explosion:=preload("res://Units/effect fx/explosion/explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	explosion.global_position=global_position
	explosion.z_index=6
	queue_free()
