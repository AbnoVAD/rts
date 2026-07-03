extends Node2D

@onready var animation: AnimatedSprite2D = $animation
@onready var attack_zone: Area2D = $"attack zone"
@onready var marker_2d: Marker2D = $Marker2D
@onready var throw_audio: AudioStreamPlayer = $"sound fx/throw_audio"

@export var tnt_scene:PackedScene=preload("res://Units Goblins/Tower/Goblin Tower/tnt.tscn")
@export var tnt_speed:float=340.0
@export var tracking_interval:float=0.1
@export var fire_cooldown:float=2.2

var target:Node2D=null
var candidates:Array[Node2D]=[]
var tracking_timer:float=0.0
var cooldown_timer:float=0.0

func _ready() -> void:
	animation.play("idle")
	_scan_for_new_targets()

func _physics_process(delta:float) -> void:
	tracking_timer-=delta
	cooldown_timer-=delta

	if tracking_timer<=0.0:
		tracking_timer=tracking_interval
		_scan_for_new_targets()
		_pick_best_target()

	if target==null or not is_instance_valid(target) or _target_is_destroyed(target):
		_release_target()
		_pick_best_target()
		return

	update_facing()

	if cooldown_timer<=0.0:
		shoot()
		cooldown_timer=fire_cooldown

func _on_attack_zone_body_entered(body:Node2D) -> void:
	if not _is_valid_target(body):
		return
	if body not in candidates:
		candidates.append(body)
		_connect_death_signal(body)
	_pick_best_target()

func _on_attack_zone_body_exited(body:Node2D) -> void:
	if body in candidates:
		candidates.erase(body)
	if body==target:
		_release_target()
		_pick_best_target()

func _pick_best_target() -> void:
	var best:Node2D=null
	var best_dist:float=INF

	for candidate in candidates:
		if not is_instance_valid(candidate) or not _is_valid_target(candidate):
			continue
		var dist:float=global_position.distance_to(candidate.global_position)
		if dist<best_dist:
			best_dist=dist
			best=candidate

	if best and best!=target:
		target=best
		animation.play("idle")
	elif best==null:
		_release_target()

func _release_target() -> void:
	target=null
	animation.play("idle")

func _on_target_died(dead_target:Node2D) -> void:
	if dead_target in candidates:
		candidates.erase(dead_target)
	if dead_target==target:
		_release_target()
		_pick_best_target()

func shoot() -> void:
	if target==null or not is_instance_valid(target):
		return

	animation.play("shoot")
	var tnt:Node2D=tnt_scene.instantiate()
	get_parent().add_child(tnt)
	tnt.global_position=marker_2d.global_position
	tnt.z_index=6

	if tnt.has_method("launch"):
		if throw_audio and not throw_audio.playing:
			throw_audio.play()
		tnt.launch(_predict_target_position(target,tnt_speed),tnt_speed)

func _on_animation_finished() -> void:
	if animation.animation=="shoot":
		animation.play("idle")

func update_facing() -> void:
	if target:
		animation.flip_h=target.global_position.x<global_position.x

func _scan_for_new_targets() -> void:
	for body in attack_zone.get_overlapping_bodies():
		if _is_valid_target(body) and body not in candidates:
			candidates.append(body)
			_connect_death_signal(body)

func _connect_death_signal(body:Node2D) -> void:
	if body.has_signal("died") and not body.is_connected("died",Callable(self,"_on_target_died")):
		body.died.connect(Callable(self,"_on_target_died"))

func _is_valid_target(body:Node2D) -> bool:
	if _target_is_destroyed(body):
		return false
	return body.is_in_group("player") or body.is_in_group("castle") or body.is_in_group("building")

func _target_is_destroyed(body:Node2D) -> bool:
	return body.has_method("is_destroyed") and body.is_destroyed()

func _predict_target_position(target_node:Node2D,projectile_speed:float) -> Vector2:
	if not (target_node is CharacterBody2D):
		return target_node.global_position

	var target_vel:Vector2=target_node.velocity
	var to_target:Vector2=target_node.global_position-marker_2d.global_position
	var a:float=target_vel.length_squared()-projectile_speed*projectile_speed
	var b:float=2.0*to_target.dot(target_vel)
	var c:float=to_target.length_squared()
	var discriminant:float=b*b-4.0*a*c

	if discriminant<0.0 or abs(a)<0.001:
		return target_node.global_position

	var t1:float=(-b+sqrt(discriminant))/(2.0*a)
	var t2:float=(-b-sqrt(discriminant))/(2.0*a)
	var t:float=max(t1,t2,0.0)
	return target_node.global_position+target_vel*t
