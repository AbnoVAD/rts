extends StaticBody2D

#-------------------------------------------
#Goblin torch spawn house
#-------------------------------------------

#-------------------------------------------
#Nodes
#-------------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $hitbox
@onready var detection: Area2D = $detection

@onready var marker_1: Marker2D = $Marker1
@onready var marker_2: Marker2D = $Marker2
@onready var marker_3: Marker2D = $Marker3

#sound fx
@onready var hit_with_sword_audio: AudioStreamPlayer = $"sound fx/hit_with_sword_audio"
@onready var hit_with_arrow_audio: AudioStreamPlayer = $"sound fx/hit_with_arrow_audio"
@onready var destroyed_audio: AudioStreamPlayer = $"sound fx/destroyed_audio"

#-------------------------------------------
#Scenes
#-------------------------------------------
const GOBLIN_SCENE:PackedScene=preload("res://Units Goblins/Goblin torch/goblin_torch.tscn")
const FIRE_SCENE:PackedScene=preload("res://Units/effect fx/fire/fire.tscn")

#-------------------------------------------
#Life
#-------------------------------------------
@export var max_life:int=180
var life:int=0
var destroyed:bool=false

#-------------------------------------------
#Spawn vars
#-------------------------------------------
@export var spawn_duration:float=20.0
@export var wave_interval:float=2.5
@export var spawn_radius:float=24.0
@export var base_wave_size:int=1
@export var max_wave_size:int=2

var elapsed_time:float=0.0
var spawning:bool=false

#-------------------------------------------
#Func ready
#-------------------------------------------
func _ready() -> void:
	z_index=4
	life=max_life
	Global.connect("wave_started_signal",_on_wave_started)

#-------------------------------------------
#Damage handling
#-------------------------------------------
func _on_hitbox_area_entered(area: Area2D) -> void:
	if destroyed:
		return
	if not area.is_in_group("attackeffect") and not area.is_in_group("arrow"):
		return
	if area.is_in_group("attackeffect"):
		if not hit_with_sword_audio.playing:
			hit_with_sword_audio.play()

func _hit_flash()->void:
	animation.modulate=Color(1,0.2,0.2)
	var tween:Tween=create_tween()
	tween.tween_property(animation,"modulate",Color.WHITE,0.15)

#-------------------------------------------
#Global waves
#-------------------------------------------
func _on_wave_started(_wave_number:int)->void:
	if destroyed:return
	spawning=true
	Global.wave_start=true
	elapsed_time=0.0
	Global.register_spawner()
	_spawn_waves_async()

#-------------------------------------------
#Spawn loop
#-------------------------------------------
func _spawn_waves_async()->void:
	while elapsed_time<spawn_duration and spawning and not destroyed:
		_spawn_wave()
		await get_tree().create_timer(wave_interval).timeout
		elapsed_time+=wave_interval
	spawning=false
	Global.wave_start=false
	Global.unregister_spawner()

#-------------------------------------------
#Spawn logic
#-------------------------------------------
func _spawn_wave():
	var progress:float=clamp(elapsed_time/spawn_duration,0.0,1.0)
	var wave_size:int=int(lerp(base_wave_size,max_wave_size,progress))
	for i in range(wave_size):
		_spawn_random_goblin()

func _spawn_random_goblin():
	var roll:float=randf()
	if roll<0.6:
		_spawn_goblin(marker_1)
	elif roll<0.9:
		_spawn_goblin(marker_2)
	else:
		_spawn_goblin(marker_3)

func _spawn_goblin(marker:Marker2D)->void:
	var goblin:Node2D=GOBLIN_SCENE.instantiate() as Node2D
	var offset:Vector2=Vector2(
		randf_range(-spawn_radius,spawn_radius),
		randf_range(-spawn_radius,spawn_radius)
	)
	get_parent().add_child.call_deferred(goblin)
	goblin.scale=Vector2(0.7,0.7)
	goblin.global_position=marker.global_position+offset

#-------------------------------------------
#Destroy
#-------------------------------------------
func destroy_house():
	if destroyed:
		return
	destroyed=true
	spawning=false
	
	animation.play("destroyed")
	if not destroyed_audio.playing:
		destroyed_audio.play()
	collision_shape_2d.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	
	Global.unregister_spawner()
	
	await get_tree().create_timer(0.5).timeout
	
	for i in range(5):
		var fire=FIRE_SCENE.instantiate() as Node2D
		fire.global_position=global_position+Vector2(
			randf_range(-32,32),
			randf_range(-32,32)
		)
		get_parent().add_child.call_deferred(fire)
	var tween:Tween=create_tween()
	tween.tween_property(self,"modulate:a",0.0,1.5)
	await tween.finished
	Global.Goblin_house+=1
	queue_free()

func take_damage(damage:int):
	if destroyed:
		return
	life-=damage
	_hit_flash()
	if life<=0:
		destroy_house()
