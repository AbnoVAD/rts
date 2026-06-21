extends CharacterBody2D

#-----------------------------------------------
#Nodes
#-----------------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var shape: CollisionShape2D = $shape
@onready var zone: Area2D = $zone
@onready var danger_zone: Area2D = $"danger zone"
@onready var marker_2d: Marker2D = $Marker2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

#Fx sound
@onready var sheep_audio: AudioStreamPlayer = $"sound fx/sheep_audio"
@onready var hit_audio: AudioStreamPlayer = $"sound fx/hit_audio"

#-----------------------------------------------
#Scenes
#-----------------------------------------------
@export var meat_scene:PackedScene=preload("res://Units/Materials/meat/meat.tscn") 
@export var baby_sheep_scene:PackedScene=preload("res://Units/Materials/sheep/sheep.tscn")
@export var source_type:="meat"
var reserved_by:Node2D=null

#-----------------------------------------------
#Genes
#-----------------------------------------------
@export_range(0.6,1.5) var body_size:=1.0
@export_range(0.6,1.5) var agility:=1.0
@export_range(0.6,1.5) var courage:=1.0
@export_range(0.6,1.5) var fertility:=1.0
@export_range(0.6,1.5) var growth_rate:=1.0

#-----------------------------------------------
#Stats
#-----------------------------------------------
const BASE_LIFE:=3
const BASE_WALK:=80.0
const BASE_FLEE:=120.0
const BASE_MEAT:=1

#-----------------------------------------------
#Final stats
#-----------------------------------------------
var life:int
var walk_speed:float
var flee_speed:float
var meat_amount:int

#-----------------------------------------------
#AI states
#-----------------------------------------------
enum {GRAZE,WANDER,FLEE,DEAD}
var state=GRAZE

var target_position:Vector2
var panic_time:=0.0
var flee_dir:=Vector2.ZERO

#-----------------------------------------------
#Graze and wander timers
#-----------------------------------------------
var graze_time:=0.0
var wander_time:=0.0
var sheep_sound_timer:=60.0
@export var sheep_sound_interval:=60.0
@export var sheep_sound_near_range:=320.0

#-----------------------------------------------
#Reproduction
#-----------------------------------------------
@export_range(30.0,180.0,1.0) var reproduction_interval:=75.0
@export_range(64.0,320.0,1.0) var reproduction_radius:=180.0
@export_range(2,10,1) var reproduction_max_nearby:=5
@export_range(1,20,1) var reproduction_population_cap:=20
@export_range(0.0,1.0,0.01) var reproduction_chance:=0.45
var reproduction_timer:=0.0

#-----------------------------------------------
#Growth
#-----------------------------------------------
var is_bady:=false
var age:=0.0
@export var adult_age:=60.0

#-----------------------------------------------
#Pack system
#-----------------------------------------------
var pack_id:=-1
var is_leader:=false
var pack_center:=Vector2.ZERO
var pack_members:Array=[]

@export var pack_radius:=120.0
@export var pack_pull_strength:=0.5

#-----------------------------------------------
#Ready func
#-----------------------------------------------
func _ready() -> void:
	z_index=4
	add_to_group("sheep")
	add_to_group("resource_source")
	if meat_scene==null:
		meat_scene=load("res://Units/Materials/meat/meat.tscn") as PackedScene
	if baby_sheep_scene==null:
		baby_sheep_scene=load("res://Units/Materials/sheep/sheep.tscn") as PackedScene
	sheep_sound_timer=sheep_sound_interval
	reproduction_timer=randf_range(reproduction_interval*0.75,reproduction_interval*1.25)
	_apply_genes()
	_assign_pack()
	
	if is_bady:
		scale*=0.5
		life=1
	target_position=global_position
	_enter_graze()

#-----------------------------------------------
#Pack assignment
#-----------------------------------------------
func _assign_pack():
	var nearby:=[]
	for sheep in get_tree().get_nodes_in_group("sheep"):
		if sheep!=self and is_instance_valid(sheep) and sheep.global_position.distance_to(global_position)<pack_radius:
			nearby.append(sheep)
		if nearby.is_empty():
			pack_id=get_instance_id()
			is_leader=true
			pack_members=[self]
		else:
			var leader=nearby[0]
			pack_id=leader.pack_id
			leader.pack_members.append(self)

#-----------------------------------------------
#Apply genes
#-----------------------------------------------
func _apply_genes():
	_refresh_stats()
	scale*=body_size

#-----------------------------------------------
#Physics process
#-----------------------------------------------
func _physics_process(delta: float) -> void:
	if state==DEAD:
		return
	if is_bady:
		_grow(delta)
	else:
		_update_reproduction_timer(delta)
	_update_sheep_sound_timer(delta)
	_update_pack_center()
	
	match state:
		GRAZE:
			graze_time-=delta
			velocity=Vector2.ZERO
			if graze_time<=0:
				_enter_wander()
		WANDER:
			wander_time-=delta
			var dir = target_position-global_position
			if dir.length()<6 or wander_time<=0:
				_enter_graze()
			else:
				dir=dir.normalized()
				dir+=_pack_pull()
				velocity=dir.normalized()*walk_speed
		FLEE:
			panic_time-=delta
			if panic_time<=0:
				_enter_graze()
			else:
				velocity=flee_dir*flee_speed
	move_and_slide()
	_update_flip_direction()

func _update_sheep_sound_timer(delta:float):
	sheep_sound_timer-=delta
	if sheep_sound_timer>0:
		return
	sheep_sound_timer=sheep_sound_interval
	if _is_player_nearby() and not sheep_audio.playing:
		sheep_audio.play()

func _is_player_nearby()->bool:
	for player in get_tree().get_nodes_in_group("player"):
		if is_instance_valid(player) and player is Node2D and player.global_position.distance_to(global_position) <= sheep_sound_near_range:
			return true
	return false

#-----------------------------------------------
#Pack logic
#-----------------------------------------------
func _update_pack_center():
	if not is_leader:
		return
	pack_members = pack_members.filter(func(s): return is_instance_valid(s))
	if pack_members.is_empty():
		return
	var sum:=Vector2.ZERO
	for s in pack_members:
		sum+=s.global_position
	pack_center=sum/pack_members.size()

func _pack_pull()->Vector2:
	if pack_center==Vector2.ZERO:
		return Vector2.ZERO
	var d=global_position.distance_to(pack_center)
	if d>pack_radius*0.5:
		return (pack_center-global_position).normalized()*pack_pull_strength
	return Vector2.ZERO

#-----------------------------------------------
#Growth
#-----------------------------------------------
func _grow(delta):
	age+=delta*growth_rate
	var t = clamp(age/adult_age,0,1)
	scale=Vector2.ONE*lerp(0.5,body_size,t)
	if age>=adult_age:
		_mature()

func _mature() -> void:
	if not is_bady:
		return
	is_bady=false
	_apply_maturation_bonuses()
	_refresh_stats()
	scale=Vector2.ONE*body_size

func _apply_maturation_bonuses() -> void:
	body_size=clamp(body_size+randf_range(0.00,0.08),0.7,1.5)
	agility=clamp(agility+randf_range(0.00,0.10),0.5,1.5)
	courage=clamp(courage+randf_range(0.00,0.08),0.6,1.5)
	fertility=clamp(fertility+randf_range(0.00,0.06),0.6,1.5)
	growth_rate=clamp(growth_rate+randf_range(0.00,0.04),0.7,1.5)

func _refresh_stats() -> void:
	life=int(BASE_LIFE*body_size)
	walk_speed=BASE_WALK*agility/body_size
	flee_speed=BASE_FLEE*agility
	meat_amount=max(1,int(BASE_MEAT*body_size*2))

#-----------------------------------------------
#Reproduction
#-----------------------------------------------
func _update_reproduction_timer(delta:float) -> void:
	if baby_sheep_scene==null:
		return
	if is_bady:
		return

	reproduction_timer-=delta
	if reproduction_timer>0:
		return

	if not _can_reproduce():
		reproduction_timer=5.0
		return
	if randf()>clamp(reproduction_chance*fertility,0.15,0.85):
		reproduction_timer=12.0
		return

	_spawn_baby()
	var fertility_bonus:float=clamp(fertility,0.6,1.5)
	reproduction_timer=reproduction_interval/fertility_bonus

func _can_reproduce() -> bool:
	if get_tree().get_nodes_in_group("sheep").size()>=reproduction_population_cap:
		return false

	var nearby_adults:=0
	for sheep in get_tree().get_nodes_in_group("sheep"):
		if sheep==self or not is_instance_valid(sheep):
			continue
		if sheep.is_bady:
			continue
		if sheep.global_position.distance_to(global_position)<=reproduction_radius:
			nearby_adults+=1
			if nearby_adults>=reproduction_max_nearby:
				return false
	return nearby_adults>0

func _spawn_baby() -> void:
	var baby=baby_sheep_scene.instantiate()
	baby.global_position=global_position+Vector2(randf_range(-10,10),randf_range(-10,10))

	baby.body_size=clamp(body_size+randf_range(-0.1,0.1),0.7,1.5)
	baby.agility=clamp(agility+randf_range(-0.1,0.1),0.5,1.5)
	baby.courage=clamp(courage+randf_range(-0.1,0.1),0.6,1.5)
	baby.fertility=clamp(fertility+randf_range(-0.1,0.1),0.6,1.5)
	baby.growth_rate=clamp(growth_rate+randf_range(-0.1,0.1),0.7,1.5)
	baby.is_bady=true
	get_parent().add_child(baby)

#-----------------------------------------------
#Damage and panic
#-----------------------------------------------
func _on_zone_area_entered(area: Area2D) -> void:
	if state==DEAD:
		return

	if area.is_in_group("explosion") or area.is_in_group("arrow"):
		take_damage(area.global_position)
	if area.is_in_group("attackeffect"):
		var effect:=area.get_parent()
		if effect!=null and str(effect.get("tool_type"))=="knife":
			take_damage(area.global_position)

func is_available_for_gathering() -> bool:
	return state!=DEAD

func get_worker_target_position() -> Vector2:
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
	if tool_name!="knife":
		return false
	if not is_available_for_gathering():
		return false
	if reserved_by!=null and reserved_by!=worker:
		return false

	take_damage(global_position)
	return true

func take_damage(attack_pos:Vector2):
	life-=1
	if not hit_audio.playing:
		hit_audio.play()
	_flash_red()
	_panic(attack_pos)
	
	if life<=0:
		die()

func _panic(threat_pos:Vector2):
	state=FLEE
	animation.play("move")
	panic_time=2.5/courage
	flee_dir=(global_position-threat_pos).normalized()

#-----------------------------------------------
#Death
#-----------------------------------------------
func die():
	state=DEAD
	release_reservation()
	animation.play("idle")
	await get_tree().create_timer(0.2).timeout
	for i in meat_amount:
		spawn_meat()
	queue_free()

#-----------------------------------------------
#Spawn meat
#-----------------------------------------------
func spawn_meat():
	if meat_scene==null:
		return
	var meat=meat_scene.instantiate()
	meat.global_position=global_position+Vector2(randf_range(-3,3),randf_range(-3,3))
	get_parent().add_child(meat)

func _update_flip_direction():
	if velocity.x<-0.2:
		animation.flip_h=true
	elif velocity.x>0.2:
		animation.flip_h=false

#-----------------------------------------------
#Visual
#-----------------------------------------------
func _flash_red():
	modulate=Color.RED
	await get_tree().create_timer(0.10).timeout
	modulate=Color.WHITE

#-----------------------------------------------
#AI state entering
#-----------------------------------------------
func _enter_graze():
	state=GRAZE
	animation.play("grass")
	graze_time=randf_range(1.5,3.5)

func _enter_wander():
	state=WANDER
	animation.play("move")
	
	var radius:=randf_range(50,100)
	var angle:=randf()*TAU
	target_position=global_position+Vector2(cos(angle),sin(angle))*radius
	wander_time=randf_range(1.5,3.5)
