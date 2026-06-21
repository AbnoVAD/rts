extends Area2D

@onready var animation: AnimatedSprite2D = $animation
@onready var impact_audio: AudioStreamPlayer = $impact_audio

const FIRE_SHEET:Texture2D = preload("res://assets/Tiny Swords old/Tiny Swords (Update 010)/Effects/Fire/Fire.png")
const FIREBALL_AUDIO:AudioStream = preload("res://Audio/Explosion/Fireball 2.wav")

@export var speed:float=420.0
@export var damage:int=20
@export var lifespan:float=3.0

var velocity:Vector2=Vector2.ZERO
var source_body:CollisionObject2D=null
var impacted:bool=false

func _ready() -> void:
	z_index=12
	monitoring=true
	monitorable=true
	animation.sprite_frames=_build_frames()
	animation.play("fly")
	impact_audio.stream=FIREBALL_AUDIO
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	_start_life_timer()

func _build_frames() -> SpriteFrames:
	var frames:=SpriteFrames.new()
	frames.add_animation("fly")
	frames.set_animation_loop("fly",true)
	frames.set_animation_speed("fly",12.0)
	for i in range(7):
		var atlas:=AtlasTexture.new()
		atlas.atlas=FIRE_SHEET
		atlas.region=Rect2(i*128,0,128,128)
		frames.add_frame("fly",atlas)
	return frames

func launch(from_pos:Vector2,to_pos:Vector2,projectile_speed:float=0.0,projectile_damage:int=0,source:CollisionObject2D=null) -> void:
	global_position=from_pos
	source_body=source
	if projectile_speed>0.0:
		speed=projectile_speed
	if projectile_damage>0:
		damage=projectile_damage
	var dir:=to_pos-from_pos
	if dir!=Vector2.ZERO:
		velocity=dir.normalized()*speed
		rotation=velocity.angle()

func _physics_process(delta: float) -> void:
	if impacted:
		return
	global_position+=velocity*delta
	if velocity!=Vector2.ZERO:
		rotation=velocity.angle()

func _on_body_entered(body: Node2D) -> void:
	_apply_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_apply_hit(area)

func _apply_hit(target:Node) -> void:
	if impacted:
		return
	if target==null or not is_instance_valid(target):
		return
	if target==source_body:
		return
	if is_goblin_side_target(target):
		return
	if not target.has_method("take_damage"):
		return
	impacted=true
	if target.is_in_group("building") or target.is_in_group("castle") or target.is_in_group("goblinbuildings") or target.is_in_group("damaged_buildings"):
		target.call("take_damage",damage)
	elif is_direction_damage_target(target):
		target.call("take_damage",damage,target.global_position-global_position)
	else:
		target.call("take_damage",damage,global_position)
	queue_free()

func is_goblin_side_target(target:Node) -> bool:
	return target.is_in_group("goblin") or target.is_in_group("goblinbuildings")

func is_direction_damage_target(target:Node) -> bool:
	var target_name:=String(target.name).to_lower()
	return target_name=="archer" or target_name=="knight" or target_name=="lancer" or target_name=="pawn"

func _start_life_timer() -> void:
	await get_tree().create_timer(lifespan).timeout
	if not impacted:
		queue_free()
