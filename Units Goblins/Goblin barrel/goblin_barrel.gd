extends CharacterBody2D

#--------------------------------------------------
#Pack system (Global/Shared)
#--------------------------------------------------
static var reserved_targets:Dictionary={}
static var goblins:Array[CharacterBody2D]

const MAX_GOBLINS_PER_TARGET:int=4
const STEAL_DISTANCE:float=80.0
const SEPARATION_RADIUS:float=44.0
const SEPARATION_FORCE:float=55.0

#--------------------------------------------------
#Nodes
#--------------------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $hurtbox
@onready var detect_area: Area2D = $detect_area
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hurt_timer: Timer = $hurt
@onready var flash_timer: Timer = $flash
@onready var target_area: Area2D = $target_area
@onready var predictcast: ShapeCast2D = $PredictCast
#fx sound
@onready var throw_audio: AudioStreamPlayer = $"sound fx/throw_audio"
@onready var hit_attack_audio: AudioStreamPlayer = $"sound fx/hit_attack_audio"

#--------------------------------------------------
#Constants
#--------------------------------------------------
const ATTACK_DISTANCE:float=40.0
const CASTLE_ATTACK_DISTANCE:float=175.0
const KNOCKBACK_FORCE:float=1000.0
const KNOCKBACK_DECAY:float=0.85
const DETOUR_DISTANCE:float=24.0
const STUCK_DETOUR_DISTANCE:float=72.0

#--------------------------------------------------
#State machine
#--------------------------------------------------
enum State{IDLE,CHASE,ATTACK,HIT,DEAD}
var state:State=State.IDLE

#--------------------------------------------------
#Variables
#--------------------------------------------------
@export var SPEED:float=185.0
@export var health:int=7
var knockback_velocity:Vector2=Vector2.ZERO
var is_flashing:bool=false

var targets:Array[Node2D]=[]
var current_target:Node2D=null
var exploded:bool=false

#--------------------------------------------------
#Stuck and avoidance
#--------------------------------------------------
var stuck_timer:float=0.0
var stuck_threshold:float=0.8
var last_position:Vector2=Vector2.ZERO
var detour_timer:float=0.0
var detour_target:Vector2=Vector2.ZERO

#--------------------------------------------------
#Ready
#--------------------------------------------------
func _ready() -> void:
	z_index=4
	goblins.append(self)

	nav.path_desired_distance=6.0
	nav.target_desired_distance=6.0
	nav.max_speed=SPEED
	predictcast.add_exception(self)
	add_goblin_collision_exceptions()

#add all target initially
	for p in get_initial_targets():
		add_target(p)

func _exit_tree() -> void:
	goblins.erase(self)
	release_target()
	rebalance_pack()

#--------------------------------------------------
#Target / Pack logic
#--------------------------------------------------
func add_target(t:Node2D)->void:
	if not is_instance_valid(t):
		return
	if not targets.has(t):
		targets.append(t)
		choose_best_target()

func remove_target(t:Node2D)->void:
	targets.erase(t)
	if current_target==t:
		release_target()
		choose_best_target()

func choose_best_target()->void:
	var best_target:Node2D=null
	var best_dist:float=INF
	
	#step 1: Human unit as target
	for t in targets:
		if not is_instance_valid(t):
			continue
		var attackers:Array=reserved_targets.get(t,[])
		var d:float=global_position.distance_to(t.global_position)
		
		if attackers.size()<MAX_GOBLINS_PER_TARGET:
			if d<best_dist:
				best_dist=d
				best_target=t
		else:
			for g in attackers:
				if not is_instance_valid(g):
					continue
				if d+STEAL_DISTANCE<g.global_position.distance_to(t.global_position):
					best_dist=d
					best_target=t
					break
	#step 2: Attack the castle if the units are all killed
	if best_target==null or targets.is_empty():
		var castle:Array=get_tree().get_nodes_in_group("castle")
		if castle.size()>0:
			best_target=castle[-1]
			if not targets.has(best_target):
				targets.append(best_target)
	#step 3: For barrel if no targets explode
	if best_target==null:
		explode()
		return
	assign_target(best_target)

func assign_target(t:Node2D)->void:
	if current_target==t:
		return
	release_target()
	
	if t !=null:
		if not reserved_targets.has(t):
			reserved_targets[t]=[]
		var arr:Array=reserved_targets[t] as Array
		arr.append(self)
		reserved_targets[t]=arr
		
		current_target=t
		state=State.CHASE
	else:
		state=State.IDLE

func release_target()->void:
	if current_target==null:
		return
	if reserved_targets.has(current_target):
		var arr:Array=reserved_targets[current_target] as Array
		arr.erase(self)
		if arr.is_empty():
			reserved_targets.erase(current_target)
		else:
			reserved_targets[current_target]=arr

func rebalance_pack()->void:
	for g in goblins:
		if g==self:
			continue
		if is_instance_valid(g) and g.state !=State.DEAD:
			g.choose_best_target()

func validate_target()->bool:
	if current_target==null:
		state=State.IDLE
		return false
	if not is_instance_valid(current_target):
		release_target()
		state=State.IDLE
		return false
	return true

#--------------------------------------------------
#Main loop
#--------------------------------------------------
func _physics_process(delta: float) -> void:
	if state==State.DEAD:
		return
	detour_timer=max(0.0,detour_timer-delta)
	
	#knock back decay
	if knockback_velocity.length()>1:
		velocity=knockback_velocity
		knockback_velocity*=KNOCKBACK_DECAY

	validate_target()

	match state:
		State.IDLE:
			if targets.is_empty():
				animation.play("explode")
				await get_tree().create_timer(0.2).timeout
				explode()
				return
			idle_state()
			if health <=0:
				explode()

		State.CHASE:
			chase_state()
			idle_state()
			if health <=0:
				explode()

		State.ATTACK:
			attack_state()
			if health <=0:
				explode()

		State.HIT:
			chase_state()
			if health <=0:
				explode()

	if state in [State.IDLE,State.CHASE]:
		var sep:Vector2=separation_vector()
		if sep.dot(velocity.normalized())>-0.45:
			velocity+=sep*SEPARATION_FORCE
	avoid_obstacles()

#--------------------------------------------------
#Stuck detection
#--------------------------------------------------
	if state in [State.CHASE,State.IDLE]:
		detect_stuck(delta)
	move_and_slide()

#--------------------------------------------------
#States
#--------------------------------------------------
func idle_state()->void:
	animation.play("idle")

func chase_state()->void:
	if not validate_target():
		return
	if detour_timer>0.0:
		set_navigation_target(detour_target)
	else:
		set_navigation_target(current_target.global_position)
	var next_point:Vector2=nav.get_next_path_position()
	var dir:Vector2=(next_point-global_position).normalized()
	if dir==Vector2.ZERO:
		velocity=Vector2.ZERO
		return
	
	velocity=dir*SPEED
	animation.flip_h=dir.x<0
	animation.play("run")

	if global_position.distance_to(current_target.global_position)<=get_attack_distance(current_target):
		state=State.ATTACK

func get_attack_distance(target:Node2D)->float:
	if is_instance_valid(target) and target.is_in_group("castle"):
		return CASTLE_ATTACK_DISTANCE
	return ATTACK_DISTANCE

func attack_state()->void:
	if state==State.DEAD:
		return
	velocity=Vector2.ZERO
	animation.play("explode")
	await animation.animation_finished
	_on_attack_finished()

func _on_attack_finished()->void:
	animation.play("explode" if animation.sprite_frames.has_animation("explode") else "hide")
	hurt_timer.start()
	
	if health<=0:
		explode()
	else:
		state=State.CHASE if current_target else State.IDLE

#--------------------------------------------------
#Separation between the barrels (distance)
#--------------------------------------------------
func separation_vector()->Vector2:
	var force:Vector2=Vector2.ZERO
	for g in get_tree().get_nodes_in_group("goblin"):
		if g==self or not is_instance_valid(g):
			continue
		var dist:float=global_position.distance_to(g.global_position)
		if dist>0 and dist < SEPARATION_RADIUS:
			force+=(global_position-g.global_position).normalized()*(1.0-dist/SEPARATION_RADIUS)
	return force.normalized() if force.length()>0 else Vector2.ZERO

#--------------------------------------------------
#Damage system
#--------------------------------------------------
func take_damage(damage:int,source_pos:Vector2)->void:
	if state==State.DEAD:
		return
	health-=damage
	if not hit_attack_audio.playing:
		hit_attack_audio.play()
	knockback_velocity=(global_position-source_pos).normalized()*KNOCKBACK_FORCE
	state=State.HIT
	start_flashing()
	hurt_timer.start(0.3)

func start_flashing()->void:
	if is_flashing:
		return
	is_flashing=true
	flash_timer.start(0.1)
	
	var t=create_tween()
	t.tween_property(animation,"modulate",Color.RED,0.05)
	t.tween_property(animation,"modulate",Color.WHITE,0.05)
	t.set_loops(4)

#--------------------------------------------------
#Hurt box
#--------------------------------------------------
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("attackeffect") or area.is_in_group("arrow"):
		take_damage(1,area.global_position)
		area.queue_free()

#--------------------------------------------------
#Timers
#--------------------------------------------------
func _on_hurt_timeout() -> void:
	knockback_velocity=Vector2.ZERO
func _on_flash_timeout() -> void:
	is_flashing=false
	animation.modulate=Color.WHITE

#--------------------------------------------------
#Signals for detection
#--------------------------------------------------

#Detector area
func _on_detect_area_body_entered(body: Node2D) -> void:
	if exploded:
		return
	if is_valid_target(body):
		add_target(body)
		var t=Timer.new()
		t.one_shot=true
		t.wait_time=0.2
		add_child(t)
		t.timeout.connect(func()->void:
			t.queue_free()
			explode())
		t.start()

func _on_detect_area_body_exited(body: Node2D) -> void:
	if is_valid_target(body):
		remove_target(body)

#--------------------------------------------------
#Target area signals
#--------------------------------------------------
func _on_target_area_body_entered(body: Node2D) -> void:
	if not is_valid_target(body):
		return
	if current_target==null:
		add_target(body)
		return
	var current_dist:float=global_position.distance_to(current_target.global_position)
	var new_dist:float=global_position.distance_to(body.global_position)
	
	if new_dist+STEAL_DISTANCE<current_dist:
		add_target(body)

func _on_target_area_body_exited(body: Node2D) -> void:
	if is_valid_target(body):
		remove_target(body)

func get_initial_targets() -> Array:
	var result:Array=[]
	result.append_array(get_tree().get_nodes_in_group("player"))
	result.append_array(get_tree().get_nodes_in_group("castle"))
	result.append_array(get_tree().get_nodes_in_group("building"))
	return result

func is_valid_target(body:Node2D) -> bool:
	return body.is_in_group("player") or body.is_in_group("castle") or body.is_in_group("building")

#--------------------------------------------------
#Obstacles avoidance system
#--------------------------------------------------
func avoid_obstacles():
	if not predictcast.is_enabled():
		predictcast.enabled=true

	if velocity.length()>0:
		predictcast.global_rotation=velocity.angle()
		predictcast.force_update_transform()

		if predictcast.is_colliding():
			var collider:Object=predictcast.get_collider(0)
			if collider is Node and collider.is_in_group("goblin"):
				return
			var n:Vector2=predictcast.get_collision_normal(0)
			var slide_dir:Vector2=velocity-n*velocity.dot(n)
			
			if slide_dir.length()<0.1:
				slide_dir=velocity.normalized()+Vector2(-n.y,n.x)*0.25
			velocity=velocity.move_toward(slide_dir.normalized()*SPEED,DETOUR_DISTANCE)

#--------------------------------------------------
#Death/Explosion
#--------------------------------------------------
func explode():
	if state==State.DEAD or exploded:
		return
	
	exploded=true
	state=State.DEAD
	release_target()
	rebalance_pack()
	
	var e=preload("res://Units/effect fx/explosion/explosion.tscn").instantiate()
	get_parent().add_child(e)
	e.global_position=global_position
	e.scale=Vector2(1.5,1.5)
	e.z_index=6

	queue_free()
func detect_stuck(delta:float)->void:
	if last_position.distance_to(global_position)<0.5 and velocity.length()>1.0:
		stuck_timer+=delta
	else:
		stuck_timer=0.0

	last_position=global_position

	if stuck_timer>stuck_threshold:
		unstuck()

func unstuck():
	if is_instance_valid(current_target):
		detour_target=find_detour_target()
		detour_timer=0.8
		set_navigation_target(detour_target)
	var path_dir:Vector2=(nav.get_next_path_position()-global_position).normalized()
	if path_dir==Vector2.ZERO:
		path_dir=velocity.normalized()
	var side:Vector2=Vector2(-path_dir.y,path_dir.x)
	velocity=(path_dir+side*0.25).normalized()*SPEED
	stuck_timer=0.0

func set_navigation_target(pos:Vector2) -> void:
	var map:RID=nav.get_navigation_map()
	if map.is_valid():
		nav.target_position=NavigationServer2D.map_get_closest_point(map,pos)
	else:
		nav.target_position=pos

func find_detour_target() -> Vector2:
	var base_dir:Vector2=velocity.normalized()
	if base_dir==Vector2.ZERO and is_instance_valid(current_target):
		base_dir=(current_target.global_position-global_position).normalized()
	if base_dir==Vector2.ZERO:
		base_dir=Vector2.RIGHT
	var side:Vector2=Vector2(-base_dir.y,base_dir.x)
	var candidates:Array[Vector2]=[
		global_position+side*STUCK_DETOUR_DISTANCE,
		global_position-side*STUCK_DETOUR_DISTANCE,
		global_position+(base_dir+side).normalized()*STUCK_DETOUR_DISTANCE,
		global_position+(base_dir-side).normalized()*STUCK_DETOUR_DISTANCE,
		global_position+base_dir*STUCK_DETOUR_DISTANCE
	]
	var best:Vector2=global_position+base_dir*STUCK_DETOUR_DISTANCE
	var best_score:float=INF
	for candidate in candidates:
		var nav_point:Vector2=get_closest_nav_point(candidate)
		var score:float=nav_point.distance_to(current_target.global_position)
		if score<best_score:
			best_score=score
			best=nav_point
	return best

func get_closest_nav_point(pos:Vector2) -> Vector2:
	var map:RID=nav.get_navigation_map()
	if map.is_valid():
		return NavigationServer2D.map_get_closest_point(map,pos)
	return pos

func add_goblin_collision_exceptions() -> void:
	for goblin in get_tree().get_nodes_in_group("goblin"):
		if goblin==self or not (goblin is PhysicsBody2D):
			continue
		add_collision_exception_with(goblin)
		goblin.add_collision_exception_with(self)
		predictcast.add_exception(goblin)

var _attackers:Array=[]

func can_accept_attacker()->bool:
	return _attackers.size()<2
func add_attacker(knight):
	if knight not in _attackers:
		_attackers.append(knight)
func remove_attacker(knight):
	_attackers.erase(knight)
