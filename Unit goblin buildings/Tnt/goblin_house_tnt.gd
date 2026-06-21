extends StaticBody2D

#-------------------------------------------
# Goblin tnt spawn house
#-------------------------------------------

#-------------------------------------------
# Nodes
#-------------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $hitbox
@onready var detection: Area2D = $detection
@onready var marker_1: Marker2D = $Marker1
@onready var marker_2: Marker2D = $Marker2
@onready var marker_3: Marker2D = $Marker3

# Sound fx
@onready var hit_with_sword_audio: AudioStreamPlayer = $"sound fx/hit_with_sword_audio"
@onready var hit_with_arrow_audio: AudioStreamPlayer = $"sound fx/hit_with_arrow_audio"
@onready var destroyed_audio: AudioStreamPlayer = $"sound fx/destroyed_audio"

#-------------------------------------------
# Scenes
#-------------------------------------------
const GOBLIN_SCENE: PackedScene = preload("res://Units Goblins/Goblin tnt/goblin_tnt.tscn")
const FIRE_SCENE: PackedScene = preload("res://Units/effect fx/fire/fire.tscn")
const MAX_SPAWN_NAV_DISTANCE: float = 6.0

#-------------------------------------------
# Life
#-------------------------------------------
@export var max_life: int = 180
var life: int = 0
var destroyed: bool = false
var registered_as_active: bool = false

#-------------------------------------------
# Spawn vars
#-------------------------------------------
@export var spawn_duration: float = 8.0
@export var wave_interval: float = 4.0
@export var spawn_radius: float = 24.0
@export var base_wave_size: int = 1
@export var max_wave_size: int = 1

var elapsed_time: float = 0.0
var spawning: bool = false

#-------------------------------------------
# Ready
#-------------------------------------------
func _ready() -> void:
	z_index = 4
	life = max_life
	
	if not Global.register_goblin_house():
		queue_free()
		return
	
	registered_as_active = true
	if not tree_exited.is_connected(_on_tree_exited):
		tree_exited.connect(_on_tree_exited)
	
	Global.connect("wave_started_signal", _on_wave_started)
	if Global.wave_active:
		_begin_wave_spawning()

#-------------------------------------------
# Damage handling
#-------------------------------------------
func _on_hitbox_area_entered(area: Area2D) -> void:
	if destroyed:
		return
	if not area.is_in_group("attackeffect") and not area.is_in_group("arrow"):
		return
	if area.is_in_group("attackeffect"):
		if not hit_with_sword_audio.playing:
			hit_with_sword_audio.play()

func _hit_flash() -> void:
	animation.modulate = Color(1, 0.2, 0.2)
	var tween: Tween = create_tween()
	tween.tween_property(animation, "modulate", Color.WHITE, 0.15)

#-------------------------------------------
# Global waves
#-------------------------------------------
func _on_wave_started(_wave_number: int) -> void:
	if destroyed:
		return
	_begin_wave_spawning()

func _begin_wave_spawning() -> void:
	if destroyed or spawning:
		return
	spawning = true
	Global.wave_start = true
	elapsed_time = 0.0
	Global.register_spawner()
	_spawn_waves_async()

#-------------------------------------------
# Spawn loop
#-------------------------------------------
func _spawn_waves_async() -> void:
	while elapsed_time < spawn_duration and spawning and not destroyed:
		_spawn_wave()
		await get_tree().create_timer(wave_interval).timeout
		elapsed_time += wave_interval
	spawning = false
	Global.wave_start = false
	Global.unregister_spawner()

#-------------------------------------------
# Spawn logic
#-------------------------------------------
func _spawn_wave() -> void:
	var progress: float = clamp(elapsed_time / spawn_duration, 0.0, 1.0)
	var wave_size: int = int(lerp(base_wave_size, max_wave_size, progress))
	for i in range(wave_size):
		_spawn_random_goblin()

func _spawn_random_goblin() -> void:
	var roll: float = randf()
	if roll < 0.6:
		_spawn_goblin(marker_1)
	elif roll < 0.9:
		_spawn_goblin(marker_2)
	else:
		_spawn_goblin(marker_3)

func _spawn_goblin(marker: Marker2D) -> void:
	var spawn_position := _get_valid_spawn_position_around_marker(marker.global_position)
	
	if spawn_position == Vector2.INF:
		return  # No valid spawn point found
	
	var goblin: Node2D = GOBLIN_SCENE.instantiate() as Node2D
	get_parent().add_child.call_deferred(goblin)
	goblin.scale = Vector2(0.7, 0.7)
	goblin.global_position = spawn_position

func _get_valid_spawn_position_around_marker(center: Vector2) -> Vector2:
	var world := get_world_2d()
	if world == null or not world.navigation_map.is_valid():
		return Vector2.INF
	
	for i in range(12):
		var angle := randf() * TAU
		var radius := randf() * spawn_radius
		var candidate := center + Vector2(cos(angle), sin(angle)) * radius
		
		var nav_point := NavigationServer2D.map_get_closest_point(world.navigation_map, candidate)
		
		if candidate.distance_to(nav_point) <= MAX_SPAWN_NAV_DISTANCE:
			return nav_point
	
	# Fallback
	var fallback := NavigationServer2D.map_get_closest_point(world.navigation_map, center)
	if center.distance_to(fallback) <= MAX_SPAWN_NAV_DISTANCE:
		return fallback
	
	return Vector2.INF  # No valid position

#-------------------------------------------
# Destroy
#-------------------------------------------
func destroy_house() -> void:
	if destroyed:
		return
	destroyed = true
	spawning = false
	animation.play("destroyed")
	if not destroyed_audio.playing:
		destroyed_audio.play()
	
	collision_shape_2d.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	Global.unregister_spawner()
	
	await get_tree().create_timer(0.5).timeout
	
	for i in range(3):
		var fire: Node2D = FIRE_SCENE.instantiate() as Node2D
		fire.global_position = global_position + Vector2(
			randf_range(-32, 32),
			randf_range(-32, 32)
		)
		get_parent().add_child.call_deferred(fire)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	await tween.finished
	
	Global.Goblin_house += 1
	queue_free()

func _on_tree_exited() -> void:
	if not registered_as_active:
		return
	registered_as_active = false
	Global.unregister_goblin_house()

func take_damage(damage: int) -> void:
	if destroyed:
		return
	life -= damage
	_hit_flash()
	if life <= 0:
		destroy_house()
