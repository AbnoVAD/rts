extends StaticBody2D

#node references
@onready var animation: AnimatedSprite2D = $animation
@onready var shape: CollisionShape2D = $shape
@onready var marker_2d: Marker2D = $Marker2D
@onready var tower: Area2D = $tower
@onready var explosion_detector: Area2D = $ExplosionDetector
@onready var repair_detector: Area2D = $RepairDetector
@onready var placement_checker: Area2D = $PlacementChecker

#var for collision
var collision_disabled:bool=false

#sound fx
@onready var destroyed_fx: AudioStreamPlayer = $"sound fx/destroyed_fx"
@onready var construct_fx: AudioStreamPlayer = $"sound fx/construct_fx"
@onready var place_fx: AudioStreamPlayer = $"sound fx/place_fx"
@onready var drop_fx: AudioStreamPlayer = $"sound fx/drop_fx"

#--------------------------------------------------
#Variables
#--------------------------------------------------
@export var construction_time:float=2.0
@export var max_life:int=10
@export var repair_time:float=4.0
var is_dead:bool=false

#--------------------------------------------------
#Constants
#--------------------------------------------------
const FINAL_SCALE:=Vector2(0.7,0.7)
const DOUBLE_CLICK_TIME:=0.3

#--------------------------------------------------
#States
#--------------------------------------------------
enum {
	STATE_CONSTRUCT,
	STATE_IDLE,
	STATE_DESTROYED
}
var state:=STATE_CONSTRUCT

#--------------------------------------------------
#Life/Hit
#--------------------------------------------------
var life:int
var is_hit:=false
var hit_flash_timer:=0.0

#--------------------------------------------------
#Archer scenes "non_moving"
#--------------------------------------------------
var archer_black=preload("res://Unit_buildings/Tower/Archer Tower/archer_black.tscn")
var archer_blue=preload("res://Unit_buildings/Tower/Archer Tower/archer_blue.tscn")
var archer_red=preload("res://Unit_buildings/Tower/Archer Tower/archer_red.tscn")
var archer_purple=preload("res://Unit_buildings/Tower/Archer Tower/archer_purple.tscn")
var archer_yellow=preload("res://Unit_buildings/Tower/Archer Tower/archer_yellow.tscn")

var spawned_archer:Node2D=null

#--------------------------------------------------
#Timers and tweens
#--------------------------------------------------
var tween:Tween
var construct_timer:Timer
var repair_timer:Timer
var hit_tween:Tween
var repair_tween:Tween

#--------------------------------------------------
#Drag and drop movement logic
#--------------------------------------------------
var is_moving:=false
var movement_valid:=true
var drag_offset:=Vector2.ZERO
var original_position:Vector2=Vector2.ZERO
var overlapping_objects_count:=0

#--------------------------------------------------
#Double click
#--------------------------------------------------
var last_click_time:=0.0

#--------------------------------------------------
#Ready func
#--------------------------------------------------
func _ready() -> void:
	z_index=5
	scale=Vector2(0.9,0.9)
	Global.load_colour()
	life=max_life
	add_to_group("building")
	input_pickable=true

	placement_checker.monitoring=false
	placement_checker.monitorable=true

	placement_checker.area_entered.connect(_on_placement_area_entered)
	placement_checker.area_exited.connect(_on_placement_area_exited)
	placement_checker.body_entered.connect(_on_placement_body_entered)
	placement_checker.body_exited.connect(_on_placement_body_exited)

	explosion_detector.area_entered.connect(_on_explosion_area_entered)
	repair_detector.area_entered.connect(_on_repair_detector_area_entered)
	
	enter_construct_state()

#--------------------------------------------------
#Process
#--------------------------------------------------
func _process(delta:float) -> void:
	if is_hit:
		hit_flash_timer-=delta
		if hit_flash_timer<=0:
			is_hit=false
			animation.modulate=Color.WHITE
	if is_moving:
		global_position=get_global_mouse_position()-drag_offset
		_update_movement_color()

#--------------------------------------------------
#Input from mouse
#--------------------------------------------------
@warning_ignore("unused_parameter")
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton\
	and event.button_index==MOUSE_BUTTON_LEFT\
	and event.pressed:

		var now=Time.get_ticks_msec()/1000.0
		if now-last_click_time<=DOUBLE_CLICK_TIME:
			if state==STATE_IDLE:
				start_moving()
			last_click_time=now

func _unhandled_input(event):
	if not is_moving:
		return
	if event is InputEventMouseButton\
	and event.button_index==MOUSE_BUTTON_LEFT\
	and event.pressed:
		finalize_movement()

#--------------------------------------------------
#Movement
#--------------------------------------------------
func start_moving() -> void:
	update_collision_logic()
	is_moving=true
	original_position=global_position
	drag_offset=get_global_mouse_position()-global_position
	overlapping_objects_count=0
	movement_valid=true
	if not place_fx.playing:
		place_fx.play()

#remove the archer on the building when moving it
	if spawned_archer:
		spawned_archer.queue_free()
		spawned_archer=null

	collision_disabled=true
	placement_checker.monitoring=true

func finalize_movement() -> void:
	if movement_valid:
		_reset_after_movement()
	else:
		create_tween()\
			.tween_property(self,"global_position",original_position,0.25)\
			.finished.connect(_reset_after_movement)

func _reset_after_movement():
	update_collision_logic()
	is_moving=false
	overlapping_objects_count=0
	movement_valid=true
	if not drop_fx.playing:
		drop_fx.play()

	placement_checker.monitoring=false
	shape.disabled=false
	animation.modulate=Color.WHITE

	if state==STATE_IDLE:
		spawn_archer()

#--------------------------------------------------
#Placement checker
#--------------------------------------------------
func _handle_overlap(node:Node,entered:bool) -> void:
	if not is_moving:
		return
	if node == self or is_ancestor_of(node):
		return

	if node.is_in_group("building") or node.is_in_group("block_building"):
		overlapping_objects_count+=1 if entered else -1
		overlapping_objects_count=max(0,overlapping_objects_count)

func _on_placement_area_entered(area:Area2D) -> void:
	_handle_overlap(area.get_parent(),true)
func _on_placement_area_exited(area:Area2D) -> void:
	_handle_overlap(area.get_parent(),false)
func _on_placement_body_entered(body:Node) -> void:
	_handle_overlap(body.get_parent(),true)
func _on_placement_body_exited(body:Node) -> void:
	_handle_overlap(body.get_parent(),false)

func _update_movement_color() -> void:
	if not is_moving:
		return

	movement_valid=overlapping_objects_count==0
	animation.modulate=Color.GREEN if movement_valid else Color.RED

#--------------------------------------------------
#States
#--------------------------------------------------
func enter_construct_state() -> void:
	state=STATE_CONSTRUCT
	animation.play("construct")
	if not construct_fx.playing:
		construct_fx.play()
		scale=Vector2.ZERO
		shape.disabled=true
		update_collision_logic()

	tween=create_tween()
	tween.tween_property(self,"scale",FINAL_SCALE,construction_time)

	construct_timer=Timer.new()
	construct_timer.wait_time=construction_time
	construct_timer.one_shot=true
	add_child(construct_timer)
	construct_timer.timeout.connect(enter_idle_state)
	construct_timer.start()

func enter_idle_state() -> void:
	update_collision_logic()
	state=STATE_IDLE
	life=max_life
	animation.play("idle")
	construct_fx.stop()
	scale=FINAL_SCALE
	shape.disabled=false
	spawn_archer()

signal died(building:Node2D)
func enter_destroyed_state() -> void:
	update_collision_logic()
	is_dead=true
	emit_signal("died",self)
	if state == STATE_DESTROYED:
		return

	state=STATE_DESTROYED
	animation.play("destroyed")
	if not destroyed_fx.playing:
		destroyed_fx.play()

#remove the archer when tower is destroyed
	if spawned_archer:
		spawned_archer.queue_free()
		spawned_archer=null

	remove_from_group("building")
	remove_from_group("block_building")
	add_to_group("damaged_buildings")

#--------------------------------------------------
#Damage logic
#--------------------------------------------------
func _on_explosion_area_entered(area:Area2D) -> void:
	if state == STATE_IDLE and area.is_in_group("explosion"):
		take_damage(1)

func take_damage(amount:int) -> void:
	life-=amount
	is_hit=true
	hit_flash_timer=0.15
	flash_red_once()
	if life <=0:
		enter_destroyed_state()

func flash_red_once():
	if hit_tween and hit_tween.is_running():
		hit_tween.kill()
	hit_tween=create_tween()
	hit_tween.tween_property(animation,"modulate",Color.RED,0.05)
	hit_tween.tween_property(animation,"modulate",Color.WHITE,0.08)

#--------------------------------------------------
#Repair logic
#--------------------------------------------------
func _on_repair_detector_area_entered(area:Area2D) -> void:
	if area.is_in_group("repair_effect"):
		if state ==STATE_DESTROYED:
			start_repair()

func start_repair() -> void:
	if state != STATE_DESTROYED:
		return

#to show repair
	flash_green_once()

	state=STATE_CONSTRUCT
	animation.play("construct")
	if not construct_fx.playing:
		construct_fx.play()

	repair_timer=Timer.new()
	repair_timer.wait_time=repair_time
	repair_timer.one_shot=true
	add_child(repair_timer)
	repair_timer.timeout.connect(finish_repair)
	repair_timer.start()	

	show_repair_pulse()

func finish_repair() -> void:
	is_dead=false
	
	flash_green_once()
	
	if repair_timer:
		repair_timer.queue_free()
	
	enter_idle_state()
	
	shape.disabled=false
	
	add_to_group("building")
	add_to_group("block_building")
	remove_from_group("damaged_buildings")

func flash_green_once():
	if repair_tween and repair_tween.is_running():
		repair_tween.kill()
	repair_tween=create_tween()
	repair_tween.tween_property(animation,"modulate",Color.GREEN,0.01)
	repair_tween.tween_property(animation,"modulate",Color.WHITE,0.15) 

func show_repair_pulse() -> void:
	if repair_tween and repair_tween.is_running():
		repair_tween.kill()
	repair_tween=create_tween()
	repair_tween.tween_property(animation,"modulate",Color(0.6,1.0,0.6,1.0),0.3)
	repair_tween.tween_property(animation,"modulate",Color.GREEN,0.3)
	repair_tween.set_loops()	 

#--------------------------------------------------
#Spawn archer
#--------------------------------------------------
func spawn_archer() -> void:
	if spawned_archer:
		return
	
	var scene:PackedScene
	match Global.choosed_colour.to_lower():
		"black":scene=archer_black
		"blue":scene=archer_blue
		"red":scene=archer_red
		"purple":scene=archer_purple
		"yellow":scene=archer_yellow
		_: return

	spawned_archer=scene.instantiate()
	add_child(spawned_archer)
	spawned_archer.scale=Vector2(0.9,0.9)
	spawned_archer.position=marker_2d.position

var last_collision_state:bool=false
func update_collision_logic():
	var new_disabled=(state==STATE_CONSTRUCT) or (state==STATE_DESTROYED) or is_moving
	if new_disabled!=collision_disabled:
		collision_disabled=new_disabled
		if shape:
			shape.disabled=collision_disabled
