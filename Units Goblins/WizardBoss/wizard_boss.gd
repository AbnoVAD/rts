extends CharacterBody2D

static var wizards:Array[CharacterBody2D]=[]

const IDLE_SHEET:Texture2D = preload("res://assets/EVil Wizard 2/Sprites/Idle.png")
const RUN_SHEET:Texture2D = preload("res://assets/EVil Wizard 2/Sprites/Run.png")
const ATTACK1_SHEET:Texture2D = preload("res://assets/EVil Wizard 2/Sprites/Attack1.png")
const ATTACK2_SHEET:Texture2D = preload("res://assets/EVil Wizard 2/Sprites/Attack2.png")
const HIT_SHEET:Texture2D = preload("res://assets/EVil Wizard 2/Sprites/Take hit.png")
const DEATH_SHEET:Texture2D = preload("res://assets/EVil Wizard 2/Sprites/Death.png")
const SPELL_SCENE:PackedScene = preload("res://Units Goblins/WizardBoss/wizard_spell.tscn")
const SKULL_SCENE:PackedScene = preload("res://materials_effects/skull/skull.tscn")

const SEPARATION_RADIUS:float=56.0
const SEPARATION_FORCE:float=60.0
const KNOCKBACK_FORCE:float=560.0
const KNOCKBACK_DECAY:float=0.84
const DETOUR_DISTANCE:float=24.0
const STUCK_DETOUR_DISTANCE:float=72.0

enum State{IDLE,CHASE,ATTACK,HIT,DEAD}

@onready var animation: AnimatedSprite2D = $animation
@onready var shape: CollisionShape2D = $shape
@onready var detector_zone: Area2D = $"detector zone"
@onready var hitbox: Area2D = $hitbox
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var avoid_cast: ShapeCast2D = $PredictCast
@onready var hp_bar: ProgressBar = $ProgressBar
@onready var cast_marker: Marker2D = $Marker2D
@onready var death_audio: AudioStreamPlayer = $"sound fx/death_audio"
@onready var cast_audio: AudioStreamPlayer = $"sound fx/cast_audio"

@export_group("Boss Stats")
@export var max_life:int=140
@export var speed:float=104.0
@export var attack_damage:int=8
@export var attack_range:float=230.0
@export var preferred_range:float=155.0
@export var attack_cooldown:float=2.6
@export var attack_windup:float=0.45
@export var spell_speed:float=340.0

var life:int=0
var state:State=State.IDLE
var current_target:Node2D=null
var targets:Array[Node2D]=[]
var last_mov_dir:Vector2=Vector2.RIGHT
var knockback_velocity:Vector2=Vector2.ZERO
var attack_in_progress:bool=false
var attack_cooldown_timer:float=0.0
var is_flashing:bool=false
var stuck_timer:float=0.0
var stuck_threshold:float=0.8
var last_position:Vector2=Vector2.ZERO
var detour_timer:float=0.0
var detour_target:Vector2=Vector2.ZERO
var registered_as_active:bool=false

func _ready() -> void:
	z_index=6
	life=max_life
	add_to_group("goblin")
	add_to_group("goblinboss")
	Global.register_goblin_boss()
	registered_as_active=true
	wizards.append(self)
	if not tree_exited.is_connected(_on_tree_exited):
		tree_exited.connect(_on_tree_exited)

	hp_bar.max_value=max_life
	hp_bar.value=life
	hp_bar.visible=false

	_build_sprite_frames()
	animation.play("idle")
	if not animation.animation_finished.is_connected(_on_animation_finished):
		animation.animation_finished.connect(_on_animation_finished)

	nav.path_desired_distance=10.0
	nav.target_desired_distance=16.0
	nav.max_speed=speed
	nav.avoidance_enabled=true
	nav.radius=16
	nav.neighbor_distance=48
	nav.max_neighbors=16

	avoid_cast.add_exception(self)
	add_goblin_collision_exceptions()

	if not hitbox.area_entered.is_connected(_on_hitbox_area_entered):
		hitbox.area_entered.connect(_on_hitbox_area_entered)
	if not detector_zone.body_entered.is_connected(_on_detector_zone_body_entered):
		detector_zone.body_entered.connect(_on_detector_zone_body_entered)
	if not detector_zone.body_exited.is_connected(_on_detector_zone_body_exited):
		detector_zone.body_exited.connect(_on_detector_zone_body_exited)

	death_audio.stream=preload("res://Audio/Death/14_human_death_spin.wav")
	cast_audio.stream=preload("res://Audio/Explosion/Fireball 2.wav")

	last_position=global_position
	rebuild_targets()
	choose_best_target()

func _exit_tree() -> void:
	wizards.erase(self)
	release_target()

func _on_tree_exited() -> void:
	if not registered_as_active:
		return
	registered_as_active=false
	Global.unregister_goblin_boss()

func _build_sprite_frames() -> void:
	var frames:=SpriteFrames.new()
	_add_sheet_frames(frames,"idle",IDLE_SHEET,8,250,250,true,10.0)
	_add_sheet_frames(frames,"run",RUN_SHEET,8,250,250,true,12.0)
	_add_sheet_frames(frames,"attack1",ATTACK1_SHEET,8,250,250,false,12.0)
	_add_sheet_frames(frames,"attack2",ATTACK2_SHEET,8,250,250,false,12.0)
	_add_sheet_frames(frames,"hit",HIT_SHEET,3,250,250,false,12.0)
	_add_sheet_frames(frames,"death",DEATH_SHEET,7,250,250,false,10.0)
	animation.sprite_frames=frames

func _add_sheet_frames(frames:SpriteFrames,anim_name:String,sheet:Texture2D,count:int,frame_width:int,frame_height:int,loop:bool,speed_value:float) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name,loop)
	frames.set_animation_speed(anim_name,speed_value)
	for i in range(count):
		var atlas:=AtlasTexture.new()
		atlas.atlas=sheet
		atlas.region=Rect2(i*frame_width,0,frame_width,frame_height)
		frames.add_frame(anim_name,atlas)

func _physics_process(delta: float) -> void:
	if state==State.DEAD:
		return

	attack_cooldown_timer=max(0.0,attack_cooldown_timer-delta)
	detour_timer=max(0.0,detour_timer-delta)

	if knockback_velocity.length()>1.0:
		velocity=knockback_velocity
		knockback_velocity*=KNOCKBACK_DECAY
	else:
		knockback_velocity=Vector2.ZERO

	if state in [State.IDLE,State.CHASE]:
		if targets.is_empty():
			rebuild_targets()
		validate_target()
		if current_target==null:
			choose_best_target()

	match state:
		State.IDLE:
			idle_state()
		State.CHASE:
			chase_state()
		State.ATTACK:
			attack_state()
		State.HIT:
			hit_state()

	if state in [State.IDLE,State.CHASE]:
		var sep:Vector2=separation_vector()
		if sep!=Vector2.ZERO and velocity.length()>0.0 and sep.dot(velocity.normalized())>-0.45:
			velocity+=sep*SEPARATION_FORCE
	avoid_obstacles()

	if state in [State.IDLE,State.CHASE]:
		detect_stuck(delta)

	move_and_slide()

func idle_state() -> void:
	velocity=separation_vector()*SEPARATION_FORCE
	animation.play("idle")

func chase_state() -> void:
	if not validate_target():
		state=State.IDLE
		return

	var distance_to_target:float=global_position.distance_to(current_target.global_position)
	if distance_to_target<preferred_range*0.75:
		var retreat_dir:Vector2=(global_position-current_target.global_position).normalized()
		if retreat_dir==Vector2.ZERO:
			retreat_dir=last_mov_dir
		last_mov_dir=retreat_dir
		velocity=retreat_dir*speed
		animation.flip_h=retreat_dir.x<0
		animation.play("run")
		return

	if distance_to_target<=attack_range:
		if attack_cooldown_timer<=0.0 and not attack_in_progress:
			start_attack()
		else:
			velocity=Vector2.ZERO
			animation.play("idle")
		return

	if detour_timer>0.0:
		set_navigation_target(detour_target)
	else:
		set_navigation_target(get_target_navigation_point(current_target,preferred_range))

	var next_point:Vector2=nav.get_next_path_position()
	var dir:Vector2=(next_point-global_position).normalized()
	if dir==Vector2.ZERO:
		velocity=Vector2.ZERO
		return

	last_mov_dir=dir
	velocity=dir*speed
	animation.flip_h=dir.x<0
	animation.play("run")

func attack_state() -> void:
	velocity=Vector2.ZERO

func hit_state() -> void:
	velocity=knockback_velocity
	if knockback_velocity.length()<=1.0 and not attack_in_progress:
		state=State.CHASE if current_target else State.IDLE

func start_attack() -> void:
	if attack_in_progress or state==State.DEAD:
		return
	if not validate_target():
		state=State.IDLE
		return

	attack_in_progress=true
	state=State.ATTACK
	velocity=Vector2.ZERO

	var attack_anim:=pick_attack_animation()
	animation.flip_h=last_mov_dir.x<0
	animation.play(attack_anim)
	if not cast_audio.playing:
		cast_audio.play()

	await get_tree().create_timer(attack_windup).timeout
	if state==State.DEAD or not attack_in_progress or not is_instance_valid(current_target):
		return
	if global_position.distance_to(current_target.global_position)<=attack_range+48.0:
		cast_spell(attack_anim)

	attack_cooldown_timer=attack_cooldown

func pick_attack_animation() -> String:
	return "attack1" if randf()<0.5 else "attack2"

func cast_spell(attack_anim:String) -> void:
	if SPELL_SCENE==null:
		return
	var spell:=SPELL_SCENE.instantiate() as Node2D
	get_parent().add_child(spell)
	spell.global_position=cast_marker.global_position
	var projectile_speed:float=spell_speed
	var projectile_damage:int=attack_damage
	if attack_anim=="attack2":
		projectile_speed*=0.9
		projectile_damage+=6
	if spell.has_method("launch"):
		spell.call("launch",cast_marker.global_position,current_target.global_position,projectile_speed,projectile_damage,self)

func take_damage(amount:int,source_pos:Vector2) -> void:
	if state==State.DEAD:
		return
	life-=amount
	hp_bar.value=life
	if life<=0:
		die()
		return
	knockback_velocity=(global_position-source_pos).normalized()*KNOCKBACK_FORCE
	attack_in_progress=false
	state=State.HIT
	animation.play("hit")
	start_flashing()

func start_flashing() -> void:
	if is_flashing:
		return
	is_flashing=true
	var tween:=create_tween()
	tween.tween_property(animation,"modulate",Color(1,0.45,0.45),0.05)
	tween.tween_property(animation,"modulate",Color.WHITE,0.05)
	tween.set_loops(4)
	await tween.finished
	is_flashing=false
	if is_instance_valid(animation):
		animation.modulate=Color.WHITE

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("attackeffect") or area.is_in_group("arrow"):
		take_damage(1,area.global_position)

func _on_detector_zone_area_entered(_area: Area2D) -> void:
	pass

func _on_detector_zone_body_entered(body: Node2D) -> void:
	if is_valid_target(body):
		add_target(body)
		choose_best_target()

func _on_detector_zone_body_exited(body: Node2D) -> void:
	if is_valid_target(body):
		remove_target(body)
		choose_best_target()

func _on_animation_finished() -> void:
	if state==State.DEAD:
		return
	if animation.animation=="hit":
		attack_in_progress=false
		state=State.CHASE if current_target else State.IDLE
	elif animation.animation in ["attack1","attack2"]:
		attack_in_progress=false
		state=State.CHASE if current_target else State.IDLE
	elif animation.animation=="death":
		queue_free()

func rebuild_targets() -> void:
	targets.clear()
	for body in get_tree().get_nodes_in_group("player"):
		add_target(body)
	for body in get_tree().get_nodes_in_group("castle"):
		add_target(body)
	for body in get_tree().get_nodes_in_group("building"):
		add_target(body)

func add_target(t:Node2D) -> void:
	if not is_valid_target(t):
		return
	if not targets.has(t):
		targets.append(t)

func remove_target(t:Node2D) -> void:
	targets.erase(t)
	if current_target==t:
		release_target()

func choose_best_target() -> void:
	var best_target:Node2D=null
	var best_dist:float=INF
	for t in targets:
		if not is_valid_target(t):
			continue
		var d:float=global_position.distance_to(t.global_position)
		if d<best_dist:
			best_dist=d
			best_target=t
	if best_target==null:
		current_target=null
		state=State.IDLE
		return
	assign_target(best_target)

func assign_target(t:Node2D) -> void:
	if current_target==t:
		return
	release_target()
	current_target=t
	state=State.CHASE

func release_target() -> void:
	current_target=null

func validate_target() -> bool:
	if current_target==null:
		return false
	if not is_instance_valid(current_target):
		release_target()
		return false
	if current_target.has_method("is_destroyed") and current_target.is_destroyed():
		var dead_target:=current_target
		release_target()
		targets.erase(dead_target)
		choose_best_target()
		return false
	return true

func is_valid_target(body:Variant) -> bool:
	if body==null or not is_instance_valid(body):
		return false
	if not (body is Node2D):
		return false
	var target_body := body as Node2D
	if target_body == null:
		return false
	return target_body.is_in_group("player") or target_body.is_in_group("castle") or target_body.is_in_group("building")

func separation_vector() -> Vector2:
	var force:=Vector2.ZERO
	for g in wizards:
		if g==self or not is_instance_valid(g):
			continue
		var dist:=global_position.distance_to(g.global_position)
		if dist>0.0 and dist<SEPARATION_RADIUS:
			force+=(global_position-g.global_position).normalized()*(1.0-dist/SEPARATION_RADIUS)
	return force.normalized() if force.length()>0.0 else Vector2.ZERO

func avoid_obstacles() -> void:
	if velocity.length()<=0.0:
		return
	avoid_cast.global_rotation=velocity.angle()
	avoid_cast.force_update_transform()
	if avoid_cast.is_colliding():
		var collider:Object=avoid_cast.get_collider(0)
		if collider is Node and collider.is_in_group("goblin"):
			return
		var n:Vector2=avoid_cast.get_collision_normal(0)
		var slide_dir:Vector2=velocity-n*velocity.dot(n)
		if slide_dir.length()<0.1:
			slide_dir=velocity.normalized()+Vector2(-n.y,n.x)*0.25
		velocity=velocity.move_toward(slide_dir.normalized()*speed,DETOUR_DISTANCE)

func detect_stuck(delta:float) -> void:
	if last_position.distance_to(global_position)<0.5 and velocity.length()>1.0:
		stuck_timer+=delta
	else:
		stuck_timer=0.0
	last_position=global_position
	if stuck_timer>stuck_threshold:
		unstuck()

func unstuck() -> void:
	if is_instance_valid(current_target):
		detour_target=find_detour_target()
		detour_timer=0.8
		set_navigation_target(detour_target)
	var path_dir:Vector2=(nav.get_next_path_position()-global_position).normalized()
	if path_dir==Vector2.ZERO:
		path_dir=last_mov_dir
	var side:Vector2=Vector2(-path_dir.y,path_dir.x)
	velocity=(path_dir+side*0.25).normalized()*speed
	stuck_timer=0.0

func set_navigation_target(pos:Vector2) -> void:
	var travel_distance:=global_position.distance_to(pos)
	NavigationRouteHelper.tune_navigation_agent(nav,travel_distance,10.0,28.0,16.0,36.0,16.0,20.0)
	var map:RID=nav.get_navigation_map()
	if NavigationRouteHelper.should_use_direct_navigation(nav,global_position,pos,96.0):
		nav.target_position=pos
	elif map.is_valid():
		nav.target_position=NavigationServer2D.map_get_closest_point(map,pos)
	else:
		nav.target_position=pos

func get_target_navigation_point(target_node:Node2D,preferred_distance:float) -> Vector2:
	if target_node==null or not is_instance_valid(target_node):
		return global_position
	if NavigationRouteHelper.should_use_direct_navigation(nav,global_position,target_node.global_position,96.0):
		return target_node.global_position
	return NavigationRouteHelper.get_best_approach_point(nav,global_position,target_node.global_position,preferred_distance)

func get_closest_nav_point(pos:Vector2) -> Vector2:
	var map:RID=nav.get_navigation_map()
	if map.is_valid():
		return NavigationServer2D.map_get_closest_point(map,pos)
	return pos

func find_detour_target() -> Vector2:
	var base_dir:Vector2=last_mov_dir
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
		var score:float=nav_point.distance_to(current_target.global_position) if is_instance_valid(current_target) else 0.0
		if score<best_score:
			best_score=score
			best=nav_point
	return best

func add_goblin_collision_exceptions() -> void:
	for goblin in get_tree().get_nodes_in_group("goblin"):
		if goblin==self or not (goblin is PhysicsBody2D):
			continue
		add_collision_exception_with(goblin)
		goblin.add_collision_exception_with(self)
		avoid_cast.add_exception(goblin)

func die() -> void:
	if state==State.DEAD:
		return
	state=State.DEAD
	release_target()
	attack_in_progress=false
	if not death_audio.playing:
		death_audio.play()
	animation.play("death")

	shape.disabled=true
	hitbox.monitoring=false

	var skull:=SKULL_SCENE.instantiate()
	get_parent().add_child(skull)
	skull.global_position=global_position
	skull.scale=Vector2(0.9,0.9)
	skull.z_index=7

	var tween:=create_tween()
	tween.tween_property(self,"modulate:a",0.0,0.8)
	await tween.finished
	queue_free()
