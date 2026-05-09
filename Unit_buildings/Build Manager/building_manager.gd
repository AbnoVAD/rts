extends Node2D

@onready var ghost_parents:Node2D=_get_or_create_ghost_parent() #Este o functie
@export var ground_tilemap_group:="ground_tilemap"
@export var building_parent:Node2D

var moving_building:StaticBody2D=null
var moving_original_position:Vector2

#Ghosts scene
@export var ghost_scenes={
	"house1":preload("res://Unit_buildings/Build Manager/Ghosts/house1_ghost.tscn"),
	"house2":preload("res://Unit_buildings/Build Manager/Ghosts/house2_ghost.tscn"),
	"house3":preload("res://Unit_buildings/Build Manager/Ghosts/house3_ghost.tscn"),
	"archery_tower":preload("res://Unit_buildings/Build Manager/Ghosts/archery_ghost.tscn"),
	"barracks":preload("res://Unit_buildings/Build Manager/Ghosts/barrack_ghost.tscn"),
	"tower":preload("res://Unit_buildings/Build Manager/Ghosts/tower_ghost.tscn"),
	"monastery":preload("res://Unit_buildings/Build Manager/Ghosts/monastery_ghost.tscn"),
}

#Buildings scenes
@export var building_scenes:={
	"house1":preload("res://Unit_buildings/House1/house1.tscn"),
	"house2":preload("res://Unit_buildings/House2/house2.tscn"),
	"house3":preload("res://Unit_buildings/House3/house3.tscn"),
	"archery_tower":preload("res://Unit_buildings/Archery/archery.tscn"),
	"barracks":preload("res://Unit_buildings/Barrack/barrack.tscn"),
	"tower":preload("res://Unit_buildings/Tower/tower.tscn"),
	"monastery":preload("res://Unit_buildings/Monastery/monastery.tscn"),
	}

var ghost:Area2D=null
var current_id:=""
var can_place:=false

func _ready() -> void:
	if building_parent == null:
		building_parent = _resolve_building_parent()

#Cost mapping
var cost_map:={
	"house1":{"wood":1,"gold":1},
	"house2":{"wood":2,"gold":2},
	"house3":{"wood":3,"gold":3},
	"archery_tower":{"wood":10,"gold":6},
	"barracks":{"wood":10,"gold":5},
	"tower":{"wood":6,"gold":3},
	"monastery":{"wood":10,"gold":5},
}

#------------------------------------------
#Process
#------------------------------------------
func _process(delta: float) -> void:
	if ghost == null:
		return

	var ground:=_get_ground_under_mouse()
	if ground==null:
		can_place=false
		return

	var mouse_pos:=get_global_mouse_position()
	var tile_pos:=ground.local_to_map(ground.to_local(mouse_pos))
	var world_pos:=ground.map_to_local(tile_pos)

	ghost.global_position=ghost.global_position.lerp(ground.to_global(world_pos),0.35)
	_validate_placement()

#------------------------------------------
#Build selection
#------------------------------------------
func select_building(id:String) -> void:
	if not _has_enough_resources(id):
		if ghost:
			_feedback_insufficient_ghosts()
		return

	if ghost:
		ghost.queue_free()

	current_id=id
	ghost=ghost_scenes[id].instantiate()
	get_parent().add_child(ghost)

#------------------------------------------
#Placement validation
#------------------------------------------
func _validate_placement()->void:
	can_place=true

	if not _has_enough_resources(current_id):
		can_place=false

	for body in ghost.get_overlapping_bodies():
		if body.is_in_group("block_buildings"):
			can_place=false
			break

	var sprite:=ghost.get_node("animation")
	sprite.modulate=Color(0,1,0,0.6) if can_place else Color(1,0,0,0.6)

#------------------------------------------
#Input
#------------------------------------------
func _input(event: InputEvent) -> void:
	if ghost==null:
		return

	if event.is_action_pressed("confirm_building") and can_place:
		_place_building()
	if event.is_action_pressed("cancel_building"):
		_cancel_building()

#------------------------------------------
#Place building
#------------------------------------------
func _place_building()->void:
	if current_id!="":
		if not _substract_resources(current_id):
			return

#Moving exiting building
	if moving_building:
		moving_building.global_position=ghost.global_position
		moving_building.visible=true
		moving_building.set_physics_process(true)

		var tween = moving_building.create_tween()
		tween.tween_property(
			moving_building,
			"global_building",
			ghost.global_position,
			0.25
		).set_trans(tween.TRANS_SINE).set_ease(tween.EASE_OUT)

		moving_building=null
	else:
		var building=building_scenes[current_id].instantiate()
		building.global_position=ghost.global_position
		building_parent.add_child(building)

		if building.has_method("play_building_animation"):
			building.play_building_animation()

	ghost.queue_free()
	ghost=null
	current_id=""

#------------------------------------------
#Cancel building
#------------------------------------------
func _cancel_building()->void:
	if moving_building:
		moving_building.global_position=moving_original_position
		moving_building.set_physics_process(true)
		moving_building=null
	if ghost:
		ghost.queue_free()
	ghost=null
	current_id=""

#------------------------------------------
#Ground Tile detection for placement
#------------------------------------------
func _get_ground_under_mouse() -> TileMapLayer:
	var mouse_pos:Vector2=get_global_mouse_position()

	for Node in get_tree().get_nodes_in_group(ground_tilemap_group):
		if not Node is TileMapLayer:
			continue

		var local_pos:Vector2=Node.to_local(mouse_pos)
		var cell:Vector2i=Node.local_to_map(local_pos)

		if Node.get_cell_source_id(cell)!=-1:
			return Node
	return null

#------------------------------------------
#Moves
#------------------------------------------
func request_move(building:StaticBody2D)->void:
	building.set_physics_process(false)
	building.visible=false
	
	moving_building=building
	moving_original_position=building.global_position
	
	var id := _get_building_id_from_scene(building)
	current_id=id
	
	ghost=ghost_scenes[id].instantiate()
	ghost.global_position=building.global_position
	ghost_parents.add_child(ghost)

func _get_building_id_from_scene(building:Node)->String:
	for id in building_scenes.keys():
		if building.scene_file_path==building_scenes[id].resource_path:
			return id
	return ""

func _get_or_create_ghost_parent() -> Node2D:
	var current_scene=get_tree().current_scene
	if not current_scene:
		push_error("no scene")
		var new_node=Node2D.new()
		new_node.name="Ghosts"
		get_tree().root.add_child(new_node)
		return new_node
	var node=current_scene.get_node_or_null("Ghosts")
	if node:
		return node as Node2D
	var new_node=Node2D.new()
	new_node.name="Ghosts"
	current_scene.add_child(new_node)
	return new_node

func _resolve_building_parent() -> Node2D:
	var current_scene := get_tree().current_scene
	if current_scene is Node2D:
		return current_scene as Node2D

	var parent_node := get_parent()
	if parent_node is Node2D:
		return parent_node as Node2D

	var tree := get_tree()
	if tree == null or tree.root == null:
		push_error("Building Manager: scene tree unavailable, using manager node as building parent fallback")
		return self

	var existing_fallback := tree.root.get_node_or_null("Buildings")
	if existing_fallback is Node2D:
		return existing_fallback as Node2D

	push_error("Building Manager: neither scene root nor parent is Node2D, creating fallback Buildings node")
	var fallback_node := Node2D.new()
	fallback_node.name = "Buildings"
	tree.root.add_child(fallback_node)
	return fallback_node

func _has_enough_resources(id:String)->bool:
	var cost = cost_map.get(id)
	if not cost:
		return false

	return Global.gold >= cost.gold and Global.wood >= cost.wood

func _substract_resources(id:String)->bool:
	var cost=cost_map.get(id)
	if not cost:
		return false
	if Global.gold<cost.gold or Global.wood<cost.wood:
		return false
	Global.consume_gold(cost.gold)
	Global.consume_wood(cost.wood)
	return true

func _feedback_insufficient_ghosts()->void:
	if not ghost:
		return
	var sprite=ghost.get_node("animation") if ghost.has_node("animation") else ghost
	var original_position=ghost.position
	var original_modulate=sprite.modulate
	
	sprite.modulate=Color(1,0,0,0.8)
	
	var tween=ghost.create_tween()
	tween.tween_property(ghost,"position:x",original_position.x + 5,0.05)
	tween.tween_property(ghost,"position:x",original_position.x - 5,0.1)
	tween.tween_property(ghost,"position:x",original_position.x, 0.05)

	tween.tween_callback(func():
		sprite.modulate=original_modulate)
