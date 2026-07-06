extends StaticBody2D

#------------------------------------------------
#Constants
#------------------------------------------------
const GOLD_SCENE:=preload("res://Units/Materials/gold/gold.tscn")
const RESTORE_TIME:=20.0
const HIT_COOLDOWN:=0.5
const GOLD_Z_INDEX:=6

#------------------------------------------------
#Nodes
#------------------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var rock_audio: AudioStreamPlayer = $rock_audio
@onready var mine_zone: Area2D = $"mine zone"
@onready var marker_2d: Marker2D = $Marker2D
@onready var health_bar: ProgressBar = $health_bar

#------------------------------------------------
#Variables
#------------------------------------------------
@export var Mine_level:=1
@export var min_gold=2
@export var max_gold=4
@export var source_type:="gold"
var reserved_by:Node2D=null

var max_life:=5
var current_life:=max_life
var is_regenerating:=false
var can_take_damage:=true

var restore_timer:Timer
var hit_cooldown_timer:Timer

#------------------------------------------------
#Ready
#------------------------------------------------
func _ready() -> void:
	z_index=4
	add_to_group("block_building")
	add_to_group("resource_source")
	setup_restore_timer()
	setup_hit_cooldown()
	health_bar.max_value=max_life
	health_bar.value=current_life
	health_bar.visible=false

#------------------------------------------------
#Timers
#------------------------------------------------
func setup_restore_timer()->void:
	restore_timer=Timer.new()
	restore_timer.one_shot=true
	restore_timer.wait_time=RESTORE_TIME
	add_child(restore_timer)
	restore_timer.timeout.connect(_on_restore_timer_timeout)

func setup_hit_cooldown()->void:
	hit_cooldown_timer=Timer.new()
	hit_cooldown_timer.one_shot=true
	hit_cooldown_timer.wait_time=HIT_COOLDOWN
	add_child(hit_cooldown_timer)
	hit_cooldown_timer.timeout.connect(func():can_take_damage=true)

func _on_mine_zone_area_entered(area: Area2D) -> void:
	if not can_take_damage:
		return
	if area.is_in_group("attackeffect"):
		var effect:=area.get_parent()
		if effect==null or str(effect.get("tool_type"))!="pickaxe":
			return
		take_damage()

func is_available_for_gathering() -> bool:
	return current_life>0 and not is_regenerating

func get_worker_target_position() -> Vector2:
	if is_instance_valid(mine_zone):
		return mine_zone.global_position
	return global_position

func can_be_reserved_by(worker:Node2D) -> bool:
	return is_instance_valid(worker) and is_available_for_gathering() and (reserved_by==null or reserved_by==worker)

func reserve_for(worker:Node2D) -> bool:
	if not can_be_reserved_by(worker):
		return false
	reserved_by=worker
	return true

func release_reservation(worker:Node2D=null) -> void:
	if worker==null or reserved_by==worker or not is_instance_valid(reserved_by):
		reserved_by=null

func is_reserved_by(worker:Node2D) -> bool:
	return reserved_by!=null and reserved_by==worker

func perform_auto_work(tool_name:String, worker:Node2D) -> bool:
	if tool_name!="pickaxe":
		return false
	if not is_available_for_gathering():
		return false
	if reserved_by!=null and reserved_by!=worker:
		return false

	take_damage()
	return true

#------------------------------------------------
#Damage system
#------------------------------------------------
func take_damage(amount:int=1, _hit_data=null):
	if current_life<=0 or is_regenerating:
		return
	can_take_damage=false
	hit_cooldown_timer.start()
	current_life-=1
	if not rock_audio.playing:
		rock_audio.play()
	health_bar.visible=true
	health_bar.value=current_life
	
	spawn_gold()
	play_hit_feedback()
	update_transparency()
	if current_life<=0:
		handle_depletion()

func play_hit_feedback()->void:
	animation.modulate=Color.RED
	animation.create_tween().tween_property(animation,'modulate',Color.WHITE,0.25)

func handle_depletion():
	is_regenerating=true
	release_reservation()
	health_bar.visible=true
	
	collision_shape_2d.disabled=true
	mine_zone.monitoring=false
	
	animation.modulate=Color(1,0.3,0.3,0.5)
	update_transparency()
	
	restore_timer.start()

func spawn_gold()->void:
	var gold_count:=randi_range(min_gold,max_gold)
	var parent_node:=get_parent()
	if not is_instance_valid(parent_node) or not is_instance_valid(marker_2d):
		return
	
	for i in range(gold_count):
		var gold=GOLD_SCENE.instantiate()
		var offset:=Vector2(
			randf_range(-28,28),
			randf_range(-24,24)
		)
		var spawn_position:=marker_2d.global_position+offset
		var spawn_rotation:=randf_range(-PI,PI)
		call_deferred("_spawn_gold_deferred", parent_node, gold, spawn_position, spawn_rotation)

func _spawn_gold_deferred(parent_node: Node, gold: Node2D, spawn_position: Vector2, spawn_rotation: float)->void:
	if not is_instance_valid(gold):
		return
	if not is_instance_valid(parent_node):
		gold.queue_free()
		return
	parent_node.add_child(gold)
	gold.global_position=spawn_position
	gold.rotation=spawn_rotation
	gold.z_index=GOLD_Z_INDEX

func _on_restore_timer_timeout()->void:
	current_life=max_life
	is_regenerating=false
	can_take_damage=true
	
	health_bar.value=current_life
	
	collision_shape_2d.disabled=false
	mine_zone.monitoring=true
	
	animation.modulate=Color.GREEN
	animation.create_tween().tween_property(animation,"modulate",Color.WHITE,0.5)
	
	update_transparency()

func _exit_tree() -> void:
		if restore_timer:
			restore_timer.queue_free()
		if hit_cooldown_timer:
			hit_cooldown_timer.queue_free()

func update_transparency():
	if current_life<max_life:
		animation.modulate.a=0.5
	else:
		animation.modulate.a=1.0

func update_to_level():
	if Mine_level==1:
		min_gold=2
		max_gold=4
		animation.play("level1")
	if Mine_level==2:
		min_gold=2
		max_gold=4
		animation.play("level2")
	if Mine_level==3:
		min_gold=2
		max_gold=4
		animation.play("level3")
	if Mine_level==4:
		min_gold=2
		max_gold=4
		animation.play("level4")
	if Mine_level==5:
		min_gold=2
		max_gold=4
		animation.play("level5")
	if Mine_level==6:
		min_gold=2
		max_gold=4
		animation.play("level6")
