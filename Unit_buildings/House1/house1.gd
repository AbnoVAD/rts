extends StaticBody2D

#node references
@onready var animation: AnimatedSprite2D = $animation
@onready var shape: CollisionShape2D = $shape
@onready var marker_1: Marker2D = $Marker1
@onready var marker_2: Marker2D = $Marker1
@onready var house_area: Area2D = $houses
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
@export var max_life:int=9
@export var repair_time:float=4.0
@export var pawn_capacity:int=2
@export var spawn_radius:float=60.0
@export var repair_gold_cost:=30
@export var repair_wood_cost:=20
@export var repair_health_amount:int=2
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
var hit_flash_time:=0.15
var is_being_repaired:=false

#--------------------------------------------------
#Pawn scenes "non_moving"
#--------------------------------------------------
var pawn_black=preload("res://Units/Pawns/pawn_black.tscn")
var pawn_blue=preload("res://Units/Pawns/pawn_blue.tscn")
var pawn_red=preload("res://Units/Pawns/pawn_red.tscn")
var pawn_purple=preload("res://Units/Pawns/pawn_purple.tscn")
var pawn_yellow=preload("res://Units/Pawns/pawn_yellow.tscn")

var spawned_pawns:Array=[]

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
var movement_colliding:=false
var movement_collision_timer:=0.0
var movement_valid:=true
var drag_offset:=Vector2.ZERO
var original_position:Vector2=Vector2.ZERO
var overlapping_objects_count:=0

#--------------------------------------------------
#Double click
#--------------------------------------------------
var last_click_time:=0.0
var is_selected:=false

#--------------------------------------------------
#Signals
#--------------------------------------------------
signal died(building:Node2D)

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
	shape.disabled=true

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
func _process(_delta:float) -> void:
	if state==STATE_IDLE and spawned_pawns.size()<pawn_capacity and Global.can_spawn():
		spawn_pawns()
	if is_hit:
		hit_flash_timer-=_delta
		if hit_flash_timer<=0:
			is_hit=false
			animation.modulate=Color.WHITE
	if movement_colliding:
		movement_collision_timer-=_delta
		if movement_collision_timer<=0:
			movement_colliding=false
			_update_movement_color()

	# In move mode, follow mouse continuously until placed/cancelled.
	if is_moving:
		global_position=get_global_mouse_position()-drag_offset
		_check_movement_collisions()

#--------------------------------------------------
#Input from mouse
#--------------------------------------------------
@warning_ignore("unused_parameter")
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		var now=Time.get_ticks_msec()/1000.0
		if now-last_click_time<=DOUBLE_CLICK_TIME:
			_on_double_click()
		else:
			_on_single_click()
		last_click_time=now

func _on_single_click()->void:
	is_selected=true
	if animation:
		animation.modulate=Color(1,1,1,1)

func _on_double_click()->void:
	if state!=STATE_IDLE:
		return
	start_moving()

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
	movement_colliding=false

	shape.disabled=true

	if not place_fx.playing:
		place_fx.play()

	placement_checker.monitoring=true
	if animation:
		animation.modulate=Color.WHITE

func finalize_movement() -> void:
	if !movement_valid:
		var return_tween=create_tween()
		return_tween.tween_property(self,"global_position",original_position,0.2)
		return_tween.tween_callback(_reset_after_movement)
	else:
		_reset_after_movement()

func _reset_after_movement():
	update_collision_logic()
	is_moving=false
	overlapping_objects_count=0
	movement_valid=true
	if not drop_fx.playing:
		drop_fx.play()
	movement_colliding=false
	input_pickable=true

	placement_checker.monitoring=false
	shape.disabled=false
	animation.modulate=Color.WHITE

	if state==STATE_IDLE:
		spawn_pawns()

func _cancel_movement()->void:
	var return_tween=create_tween()
	return_tween.tween_property(self,"global_position",original_position,0.2)
	return_tween.tween_callback(_reset_after_movement)

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

#checker signal
func _on_placement_area_entered(area:Area2D) -> void:
	if not is_moving:return
	var parent=area.get_parent()
	if parent and parent!=self:
		if parent.is_in_group("building") or parent.is_in_group("block_building"):
			overlapping_objects_count+=1
			_update_collision_state()

func _on_placement_area_exited(area:Area2D) -> void:
	if not is_moving:return
	var parent=area.get_parent()
	if parent and parent!=self:
		if parent.is_in_group("building") or parent.is_in_group("block_building"):
			overlapping_objects_count=max(0,overlapping_objects_count-1)
			_update_collision_state()

func _on_placement_body_entered(body:Node) -> void:
	if not is_moving:return
	if body !=self:
		if body.is_in_group("building") or body.is_in_group("block_building"):
			overlapping_objects_count+=1
			_update_collision_state()

func _on_placement_body_exited(body:Node) -> void:
	if not is_moving:return
	if body !=self:
		if body.is_in_group("building") or body.is_in_group("block_building"):
			overlapping_objects_count=max(0,overlapping_objects_count-1)
			_update_collision_state()

func _update_collision_state():
	if not is_moving:return
	movement_valid=(overlapping_objects_count==0)
	_update_movement_color()
	if not movement_valid and not movement_colliding:
		movement_colliding=true
		movement_collision_timer=0.2
		if animation:
			animation.modulate=Color.RED

func _check_movement_collisions()->void:
	if not is_moving:return
	if animation:
		animation.modulate=Color.GREEN if movement_valid else Color.RED

func _unhandled_input(event:InputEvent) -> void:
	if not is_moving:
		return

	# Left click confirms placement
	if event is InputEventMouseButton and event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index==MOUSE_BUTTON_LEFT:
			finalize_movement()
			return
		elif mouse_event.button_index==MOUSE_BUTTON_RIGHT:
			_cancel_movement()
			return

	# Esc cancels movement
	if event is InputEventKey and event.pressed:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_cancel_movement()

func _update_movement_color() -> void:
	if not is_moving:
		return

	movement_valid=overlapping_objects_count==0
	animation.modulate=Color.GREEN if movement_valid else Color.RED

#--------------------------------------------------
#Timers and Tweens
#--------------------------------------------------
func clear_timers_and_tweens() -> void:
	if tween and tween.is_running():tween.kill()
	tween=null
	if construct_timer:construct_timer.queue_free();construct_timer=null
	if repair_timer:repair_timer.queue_free();repair_timer=null

#--------------------------------------------------
#States
#--------------------------------------------------
func enter_construct_state() -> void:
	clear_timers_and_tweens()
	state=STATE_CONSTRUCT
	animation.play("construct")
	if not construct_fx.playing:
		construct_fx.play()
		scale=Vector2.ZERO
		shape.disabled=true
		update_collision_logic()
		input_pickable=false

	tween=create_tween()
	tween.tween_property(self,"scale",FINAL_SCALE,construction_time)

	construct_timer=Timer.new()
	construct_timer.wait_time=construction_time
	construct_timer.one_shot=true
	add_child(construct_timer)
	construct_timer.timeout.connect(enter_idle_state)
	construct_timer.start()

func _on_construct_finished():
	enter_idle_state()
	construct_fx.stop()
	update_collision_logic()

func enter_idle_state() -> void:
	clear_timers_and_tweens()
	update_collision_logic()
	state=STATE_IDLE
	life=max_life
	animation.play("idle")
	construct_fx.stop()
	scale=FINAL_SCALE
	shape.disabled=false
	input_pickable=true
	is_moving=false
	movement_valid=true
	movement_colliding=false
	overlapping_objects_count=0
	placement_checker.monitoring=false
	if animation:
		animation.modulate=Color.WHITE
	spawned_pawns.clear()
	spawn_pawns()

func enter_destroyed_state() -> void:
	update_collision_logic()
	is_dead=true
	emit_signal("died",self)
	if state == STATE_DESTROYED:
		return

	input_pickable=false
	is_moving=false
	overlapping_objects_count=0
	remove_from_group("building")
	add_to_group("damaged_buildings")

	state=STATE_DESTROYED
	animation.play("destroyed")
	if not destroyed_fx.playing:
		destroyed_fx.play()

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
	if life>=max_life or is_being_repaired:
		return
	is_being_repaired=true

	if state==STATE_DESTROYED:
		_repair_destroyed()
	else:
		_repair_damaged()

func _repair_damaged() -> void:
	life=min(life+repair_health_amount,max_life)
	flash_green_once()
	show_repair_pulse()
	if not construct_fx.playing:
		construct_fx.play()
	is_being_repaired=false
	if life==max_life and state!=STATE_IDLE:
		enter_idle_state()

func _repair_destroyed():
	flash_green_once()
	show_repair_pulse()
	state=STATE_CONSTRUCT
	animation.play("construct")
	if not construct_fx.playing:
		construct_fx.play()

	scale=Vector2.ZERO
	input_pickable=false
	if tween and tween.is_running():
		tween.kill()
	tween=create_tween()
	tween.tween_property(self,"scale",FINAL_SCALE,repair_time)

	repair_timer=Timer.new()
	repair_timer.wait_time=repair_time
	repair_timer.one_shot=true
	add_child(repair_timer)
	repair_timer.timeout.connect(_on_destroyed_repair_finished)
	repair_timer.start()

func _on_destroyed_repair_finished():
	is_dead=false
	flash_green_once()
	show_repair_pulse()
	life=max_life
	is_being_repaired=false
	enter_idle_state()
	shape.disabled=false

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
#Death handler
#--------------------------------------------------
func _on_pawn_died(pawn)->void:
	if spawned_pawns.has(pawn):
		spawned_pawns.erase(pawn)

#--------------------------------------------------
#Spawn pawns
#--------------------------------------------------
func spawn_pawns() -> void:
	if spawned_pawns.size()>=pawn_capacity:
		return

	# meat availability (kept consistent with other buildings)
	var meat_available=Global.meat
	if meat_available<=0:
		return

	# count max pawn capacity
	var remaining_capacity=pawn_capacity-spawned_pawns.size()
	var spawn_count=min(remaining_capacity,meat_available)
	if spawn_count<=0:
		return

	var pawn_scene:PackedScene
	match Global.choosed_colour.to_lower():
		"black":pawn_scene=pawn_black
		"blue":pawn_scene=pawn_blue
		"red":pawn_scene=pawn_red
		"purple":pawn_scene=pawn_purple
		"yellow":pawn_scene=pawn_yellow
		_: return

	# House1 scene only has Marker1. Use it for all spawns.
	_spawn_pawns_around_marker(marker_1.global_position,spawn_count,pawn_scene)

func _spawn_pawns_around_marker(center:Vector2,count:int,pawn_scene:PackedScene) -> void:
	for i in count:
		var new_pawn=pawn_scene.instantiate()
		get_parent().add_child(new_pawn)
		new_pawn.z_index=4
		new_pawn.scale=Vector2(0.7,0.7)

		var pos:Vector2=center
		var tries=0
		while tries < 10:
			var angle=randf()*TAU
			var radius=randf()*spawn_radius
			var candidate=center+Vector2(cos(angle),sin(angle))*radius
			var overlapping=false
			for other in spawned_pawns:
				if candidate.distance_to(other.global_position)<16.0:
					overlapping=true
					break
			tries+=1
			if not overlapping:
				pos=candidate
				break
		new_pawn.global_position=pos
		spawned_pawns.append(new_pawn)

		# death signal connected
		new_pawn.died.connect(_on_pawn_died)

		# consume meat
		Global.consume_meat(1)

var last_collision_state:bool=false
func update_collision_logic():
	var new_disabled=(state==STATE_CONSTRUCT) or (state==STATE_DESTROYED) or is_moving
	if new_disabled!=collision_disabled:
		collision_disabled=new_disabled
		if shape:
			shape.disabled=collision_disabled
