extends StaticBody2D

#-------------------------------------------
#Undead boss spawn house
#-------------------------------------------

#-------------------------------------------
#Nodes
#-------------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $hitbox
@onready var marker_1: Marker2D = $Marker1
@onready var marker_2: Marker2D = $Marker2
@onready var marker_3: Marker2D = $Marker3

#-------------------------------------------
#Scenes
#-------------------------------------------
const BOSS_SCENE:PackedScene=preload("res://Units Goblins/WizardBoss/wizard_boss.tscn")

#-------------------------------------------
#Spawn vars
#-------------------------------------------
@export var spawn_offset:float=18.0
@export var collision_size:Vector2=Vector2(96,112)
@export var collision_offset:Vector2=Vector2(0,8)
@export var max_life:int=220

var spawned_boss:bool=false
var life:int=0
var destroyed:bool=false
var registered_as_active:bool=false

func _ready() -> void:
	z_index=4
	life=max_life
	if not Global.register_goblin_house(true):
		queue_free()
		return
	registered_as_active=true
	if not tree_exited.is_connected(_on_tree_exited):
		tree_exited.connect(_on_tree_exited)
	_apply_visual_setup()
	if hitbox and not hitbox.area_entered.is_connected(_on_hitbox_area_entered):
		hitbox.area_entered.connect(_on_hitbox_area_entered)
	if Global.wave_active and Global.current_wave>=Global.max_waves:
		_spawn_final_boss()
	Global.connect("wave_started_signal",_on_wave_started)

func _on_wave_started(wave_number:int) -> void:
	if wave_number<Global.max_waves:
		return
	_spawn_final_boss()

func _spawn_final_boss() -> void:
	if spawned_boss:
		return
	if not Global.try_spawn_final_boss():
		return
	spawned_boss=true
	Global.register_spawner()

	var markers:Array[Marker2D]=[marker_1,marker_2,marker_3]
	var boss:Node2D=BOSS_SCENE.instantiate() as Node2D
	get_parent().add_child.call_deferred(boss)
	boss.scale=Vector2(0.82,0.82)
	boss.global_position=_boss_spawn_position(markers[randi() % markers.size()])
	if not boss.tree_exited.is_connected(_on_spawned_boss_tree_exited):
		boss.tree_exited.connect(_on_spawned_boss_tree_exited)

func _boss_spawn_position(marker:Marker2D) -> Vector2:
	return marker.global_position+Vector2(
		randf_range(-spawn_offset,spawn_offset),
		randf_range(-spawn_offset,spawn_offset)
	)

func _on_spawned_boss_tree_exited() -> void:
	Global.unregister_spawner()

func _on_tree_exited() -> void:
	if not registered_as_active:
		return
	registered_as_active=false
	Global.unregister_goblin_house()

func _apply_visual_setup() -> void:
	if animation:
		animation.play("default")
	animation.flip_h = false
	_apply_collision_shape()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if destroyed:
		return
	if not area.is_in_group("arrow") and not area.is_in_group("attackeffect"):
		return
	if area.is_in_group("attackeffect"):
		take_damage(1)

func take_damage(damage:int) -> void:
	if destroyed:
		return
	life-=damage
	animation.modulate=Color(1,0.35,0.35)
	var tween:=create_tween()
	tween.tween_property(animation,"modulate",Color.WHITE,0.12)
	if life<=0:
		destroy_house()

func destroy_house() -> void:
	if destroyed:
		return
	destroyed=true
	spawned_boss=false
	collision_shape_2d.set_deferred("disabled", true)
	if hitbox:
		hitbox.set_deferred("monitoring", false)
	var tween:=create_tween()
	tween.tween_property(self,"modulate:a",0.0,0.9)
	await tween.finished
	queue_free()

func _apply_collision_shape() -> void:
	if collision_shape_2d == null:
		return
	var rect := collision_shape_2d.shape as RectangleShape2D
	if rect == null:
		return
	rect.size = collision_size
	collision_shape_2d.position = collision_offset
