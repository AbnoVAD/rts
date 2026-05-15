extends CharacterBody2D

#---------------------------------------
#Export
#---------------------------------------
@export var tnt_scene=preload("res://Units Goblins/Tower/Goblin Tower/tnt.tscn")
@export var tnt_speed:float=500.0
@export var tracking_interval:float=0.1

#---------------------------------------
#Nodes
#---------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var shape: CollisionShape2D = $shape
@onready var marker_2d: Marker2D = $Marker2D
@onready var attack_zone: Area2D = $"attack zone"
@onready var cooldown: Timer = $cooldown

#fx sound
@onready var throw_audio: AudioStreamPlayer = $"sound fx/throw_audio"
@onready var hit_attack_audio: AudioStreamPlayer = $"sound fx/hit_attack_audio"

#---------------------------------------
#Internal State
#---------------------------------------
var target:Node2D=null
var tracking_timer:float=0.0

var player_is_dead:=false

#---------------------------------------
#Ready
#---------------------------------------
func _ready() -> void:
	z_index=4
	animation.play("idle")

#---------------------------------------
#Signals
#---------------------------------------
func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target=body
func _on_attack_zone_body_exited(body: Node2D) -> void:
	if body==target:
		target=null
		cooldown.stop()
		animation.play("idle")

#---------------------------------------
#Cooldown
#---------------------------------------
func _on_cooldown_timeout() -> void:
	if target:
		shoot()
		cooldown.start()

#---------------------------------------
#Process
#---------------------------------------
func _physics_process(delta: float) -> void:
	if target==null:
		if animation.animation!="idle":
			animation.play("idle")
		return

	update_facing()

	tracking_timer-=delta
	if tracking_timer<=0.0:
		tracking_timer=tracking_interval
		if cooldown.is_stopped():
			shoot()
			cooldown.start()

func shoot():
	if target==null:
		return
	animation.play("shoot")
	var tnt:Node2D=tnt_scene.instantiate()
	add_child(tnt)
	tnt.global_position=marker_2d.global_position
	tnt.z_index=4
	
	if tnt.has_method("launch"):
		if not throw_audio.playing:
			throw_audio.play()
		tnt.launch(target.global_position,tnt_speed)

func update_facing()->void:
		if target==null:
			return
		animation.flip_h=target.global_position.x<global_position.x
