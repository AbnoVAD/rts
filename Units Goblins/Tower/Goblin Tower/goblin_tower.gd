extends StaticBody2D

@onready var animation: AnimatedSprite2D = $animation
@onready var shape: CollisionShape2D = $shape
@onready var marker_2d: Marker2D = $Marker2D
@onready var destroyed_fx: AudioStreamPlayer = $"sound fx/throw_audio"
@onready var hit_fx: AudioStreamPlayer = $"sound fx/hit_attack_audio"

@export var tower_tnt_scene:PackedScene=preload("res://Units Goblins/Tower/Goblin Tower/tower_tnt.tscn")
@export var construction_time:float=2.0
@export var max_life:int=180
@export var final_scale:Vector2=Vector2.ONE

enum {
	STATE_CONSTRUCT,
	STATE_IDLE,
	STATE_DESTROYED
}

var state:=STATE_CONSTRUCT
var life:int
var is_dead:=false
var spawned_tnt:Node2D=null
var construct_timer:Timer
var tween:Tween
var hit_tween:Tween

signal died(building:Node2D)

func _ready() -> void:
	z_index=4
	life=max_life
	add_to_group("block_building")
	add_to_group("goblinbuildings")
	remove_from_group("goblin")
	enter_construct_state()

func enter_construct_state() -> void:
	_clear_build_timer()
	state=STATE_CONSTRUCT
	is_dead=false
	animation.play("construction")
	shape.disabled=true
	_free_spawned_tnt()
	scale=Vector2.ZERO

	tween=create_tween()
	tween.tween_property(self,"scale",final_scale,construction_time)

	construct_timer=Timer.new()
	construct_timer.wait_time=construction_time
	construct_timer.one_shot=true
	add_child(construct_timer)
	construct_timer.timeout.connect(enter_idle_state)
	construct_timer.start()

func enter_idle_state() -> void:
	_clear_build_timer()
	state=STATE_IDLE
	is_dead=false
	life=max_life
	scale=final_scale
	shape.disabled=false
	animation.modulate=Color.WHITE
	animation.play("idle")
	add_to_group("block_building")
	add_to_group("goblinbuildings")
	spawn_tnt()

func enter_destroyed_state() -> void:
	if state==STATE_DESTROYED:
		return

	state=STATE_DESTROYED
	is_dead=true
	emit_signal("died",self)
	_clear_build_timer()
	_free_spawned_tnt()
	shape.disabled=true
	remove_from_group("block_building")
	remove_from_group("goblinbuildings")
	animation.modulate=Color.WHITE
	animation.play("destroyed")
	if destroyed_fx and not destroyed_fx.playing:
		destroyed_fx.play()

func take_damage(amount:int,_source_pos:Vector2=Vector2.ZERO) -> void:
	if state!=STATE_IDLE:
		return
	life-=amount
	flash_red_once()
	if hit_fx and not hit_fx.playing:
		hit_fx.play()
	if life<=0:
		enter_destroyed_state()

func is_destroyed() -> bool:
	return state==STATE_DESTROYED

func spawn_tnt() -> void:
	if spawned_tnt or not tower_tnt_scene:
		return
	spawned_tnt=tower_tnt_scene.instantiate()
	add_child(spawned_tnt)
	spawned_tnt.position=marker_2d.position
	spawned_tnt.z_index=5

func flash_red_once() -> void:
	if hit_tween and hit_tween.is_running():
		hit_tween.kill()
	hit_tween=create_tween()
	hit_tween.tween_property(animation,"modulate",Color.RED,0.05)
	hit_tween.tween_property(animation,"modulate",Color.WHITE,0.08)

func _free_spawned_tnt() -> void:
	if spawned_tnt and is_instance_valid(spawned_tnt):
		spawned_tnt.queue_free()
	spawned_tnt=null

func _clear_build_timer() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween=null
	if construct_timer:
		construct_timer.queue_free()
		construct_timer=null
