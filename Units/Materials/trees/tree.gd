extends StaticBody2D

#----------------------------------------
#States
#----------------------------------------
enum TreeState{
	IDLE,
	CHOPPING,
	CHOPPED,
	GROWING
}

var state:TreeState=TreeState.IDLE
const DEFAULT_LIFE:=4
@export var life=DEFAULT_LIFE
var reserved_by:Node2D=null

#----------------------------------------
#Nodes
#----------------------------------------
@onready var animation: AnimatedSprite2D = $animation
@onready var shape: CollisionShape2D = $shape
@onready var chopped: CollisionShape2D = $chopped
@onready var tree_trunk: Area2D = $tree_trunk
@onready var cut_audio: AudioStreamPlayer = $"sound fx/cut_audio"

#----------------------------------------
#Constants
#----------------------------------------
const CHOP_TIME:=1.0
const REGROW_TIME:=10.0
const GROW_TIME:=1.5
const WOOD_SCENE:=preload("res://Units/Materials/wood/wood.tscn")
@export var source_type:="wood"

#----------------------------------------
#Ready
#----------------------------------------
func _ready() -> void:
	if life == null:
		life = DEFAULT_LIFE
	scale=Vector2(1.5,1.5)
	z_index=7
	add_to_group("trees")
	add_to_group("resource_source")
	randomize()
	set_state(TreeState.IDLE)

#----------------------------------------
#Pawn interaction
#----------------------------------------
func _on_tree_trunk_area_entered(area: Area2D) -> void:
	if area.is_in_group("attackeffect"):
		var effect:=area.get_parent()
		if effect==null or str(effect.get("tool_type"))!="axe":
			return
		life-=1
		red_flash()
		if life<=0:
			try_chop()
			release_reservation()
		area.queue_free()
		cut_audio.play()
		await get_tree().create_timer(1.95).timeout
		cut_audio.stop()

func is_available_for_gathering() -> bool:
	return state==TreeState.IDLE

func get_worker_target_position() -> Vector2:
	if is_instance_valid(tree_trunk):
		return tree_trunk.global_position
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
	if tool_name!="axe":
		return false
	if not is_available_for_gathering():
		return false
	if reserved_by!=null and reserved_by!=worker:
		return false

	life-=1
	red_flash()
	if life<=0:
		try_chop()
		release_reservation(worker)
	return true

func set_state(new_state:TreeState)->void:
	state=new_state
	match state:
		TreeState.IDLE:
			animation.play("idle")
			scale=Vector2(1.5,1.5)
			modulate.a=1.0
			shape.set_deferred("disabled", false)
			chopped.set_deferred("disabled", true)
		TreeState.CHOPPING:
			animation.play("chop")
			shape.set_deferred("disabled", false)
			chopped.set_deferred("disabled", true)
		TreeState.CHOPPED:
			animation.play("chopped")
			shape.set_deferred("disabled", true)
			chopped.set_deferred("disabled", false)
		TreeState.GROWING:
			animation.play("idle")
			scale=Vector2(1.5,1.5)
			modulate.a=1.0
			shape.set_deferred("disabled", true)
			chopped.set_deferred("disabled", true)

func try_chop()->void:
	if life<=0:
		if state!=TreeState.IDLE:
			return
		
		
		set_state(TreeState.CHOPPING)
		release_reservation()
		await get_tree().create_timer(CHOP_TIME).timeout
		set_state(TreeState.CHOPPED)
		
		spawn_wood()
		start_regrow_timer()

#----------------------------------------
#Spawn wood
#----------------------------------------
func spawn_wood()->void:
	var wood_count:=randi_range(3,6)
	
	for i in range(wood_count):
		var wood=WOOD_SCENE.instantiate()
		wood.scale=Vector2(0.6,0.6)
		get_parent().add_child(wood)

		var x_offset:=randf_range(-35,35)
		var y_offset:=randf_range(-75,55)
		
		wood.global_position=global_position+Vector2(x_offset,y_offset)
		wood.rotation=randf_range(-PI,PI)
		wood.z_index=5

func start_regrow_timer()->void:
	await get_tree().create_timer(REGROW_TIME).timeout
	start_growing()

func start_growing()->void:
	set_state(TreeState.GROWING)
	
	scale=Vector2(0.2,0.2)
	modulate.a=0.0
	
	var tween:=create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(self,"scale",Vector2(1.5,1.5),GROW_TIME)
	tween.parallel().tween_property(self,"modulate:a",1.0,GROW_TIME)

	await tween.finished
	set_state(TreeState.IDLE)

func red_flash()->void:
	if animation.animation=="chop":
		animation.modulate=Color.RED
		await get_tree().create_timer(0.12).timeout
		animation.modulate=Color.WHITE
