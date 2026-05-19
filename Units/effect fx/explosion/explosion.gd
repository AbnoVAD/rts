extends AnimatedSprite2D

@onready var explosion: AnimatedSprite2D = $"."
@onready var explo: Area2D = $explo
@onready var shape: CollisionShape2D = $explo/shape
@onready var explosion_audio: AudioStreamPlayer = $explosion_audio

@export var unit_damage:=25
@export var building_damage:=1

var pos
var damaged_targets:={}

func _ready() -> void:
	if not explosion_audio.playing:
		explosion_audio.play()
		explosion.play("sp")
		scale=Vector2(2,2)
	if not explo.body_entered.is_connected(_on_explo_body_entered):
		explo.body_entered.connect(_on_explo_body_entered)
	if not explo.area_entered.is_connected(_on_explo_area_entered):
		explo.area_entered.connect(_on_explo_area_entered)
	call_deferred("apply_initial_damage")

func _on_animation_finished() -> void:
	queue_free()

func _on_explo_body_entered(body: Node2D) -> void:
	apply_damage_to_target(body)
	if body.is_in_group("building"):
		pos=body.global_position
		fire()
	if body.is_in_group("player"):
		pos=body.global_position
		flame()

func _on_explo_area_entered(area: Area2D) -> void:
	apply_damage_to_target(area)
	if area.get_parent() is Node2D:
		apply_damage_to_target(area.get_parent())

func apply_initial_damage() -> void:
	for body in explo.get_overlapping_bodies():
		_on_explo_body_entered(body)
	for area in explo.get_overlapping_areas():
		_on_explo_area_entered(area)

func apply_damage_to_target(target:Node) -> void:
	if target==null or not is_instance_valid(target):
		return
	if damaged_targets.has(target):
		return
	if is_goblin_side_target(target):
		return
	if target.has_method("take_damage"):
		damaged_targets[target]=true
		if target.is_in_group("sheep"):
			target.take_damage(global_position)
		elif target.is_in_group("mines"):
			return
		elif is_building_damage_target(target):
			target.take_damage(building_damage)
		elif is_direction_damage_target(target):
			target.take_damage(unit_damage,target.global_position-global_position)
		else:
			target.take_damage(unit_damage,global_position)

func is_building_damage_target(target:Node) -> bool:
	return target.is_in_group("building") or \
		target.is_in_group("castle") or \
		target.is_in_group("goblinbuildings") or \
		target.is_in_group("damaged_buildings")

func is_goblin_side_target(target:Node) -> bool:
	return target.is_in_group("goblin") or target.is_in_group("goblinbuildings")

func is_direction_damage_target(target:Node) -> bool:
	var target_name:=String(target.name).to_lower()
	return target_name=="archer" or target_name=="knight" or target_name=="lancer"

func fire():
	var scene=preload("res://Units/effect fx/fire/fire.tscn")
	var _scene=scene.instantiate()
	_scene.global_position=pos
	_scene.z_index=10
	get_parent().add_child.call_deferred(_scene)
func flame():
	var scene=preload("res://Units/effect fx/fire/flame1.tscn")
	var _scene=scene.instantiate()
	_scene.global_position=pos
	_scene.z_index=10
	get_parent().add_child.call_deferred(_scene)
