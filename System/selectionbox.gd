extends Node2D

var dragging:=false
var drag_start:=Vector2.ZERO
var drag_end:=Vector2.ZERO

const CAMERA_MOVE_SPEED:float=620.0
const CAMERA_EDGE_MARGIN:float=20.0

@onready var camera: Camera2D = $Camera2D

var selection_rect:=Rect2()
#use to call a camera shake function from anywhere in the units scripts
func _ready() -> void:
	GlobalPlayer.camera_shake_func=camera_shake
	z_index=10
	camera.make_current()
	_snap_camera_to_start_position()

func _process(delta: float) -> void:
	_pan_camera(delta)

func _snap_camera_to_start_position() -> void:
	if GlobalPlayer.active_player and is_instance_valid(GlobalPlayer.active_player):
		camera.global_position=GlobalPlayer.active_player_position
	elif GlobalPlayer.castle_position:
		camera.global_position=GlobalPlayer.castle_position
	else:
		camera.global_position=global_position

func _pan_camera(delta: float) -> void:
	var direction:=Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x-=1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x+=1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y-=1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y+=1.0

	var viewport_size:Vector2=get_viewport_rect().size
	var mouse_position:Vector2=get_viewport().get_mouse_position()
	if mouse_position.x<=CAMERA_EDGE_MARGIN:
		direction.x-=1.0
	elif mouse_position.x>=viewport_size.x-CAMERA_EDGE_MARGIN:
		direction.x+=1.0
	if mouse_position.y<=CAMERA_EDGE_MARGIN:
		direction.y-=1.0
	elif mouse_position.y>=viewport_size.y-CAMERA_EDGE_MARGIN:
		direction.y+=1.0

	if direction==Vector2.ZERO:
		return

	camera.global_position+=direction.normalized()*CAMERA_MOVE_SPEED*delta

#------------------------------------------
#Inputs
#------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_drag()
		else:
			end_drag()
	elif event is InputEventMouseMotion and dragging:
		drag_end=get_global_mouse_position()
		update_selection_rect()
		queue_redraw()

#------------------------------------------
#Drag
#------------------------------------------
func start_drag():
	dragging=true
	drag_start=get_global_mouse_position()
	drag_end=drag_start
func end_drag():
	dragging=false
	update_selection_rect()
	select_units()
	queue_redraw()
#------------------------------------------
#Rect update
#------------------------------------------
func update_selection_rect():
	selection_rect=Rect2(
		drag_start,
		drag_end-drag_start
	).abs()

#------------------------------------------
#Draw
#------------------------------------------
func _draw():
	if not dragging:
		return
	var color=Color.WHITE
	draw_rect(selection_rect,color,false,2)
	draw_rect(selection_rect,Color(color.r,color.g,color.b,0.15),true)

#------------------------------------------
#GET color from the player menu
#------------------------------------------
#func get_selection_color()->Color:
#	match Global.choosed_colour:
#		"black":
#			return Color.BLACK
#		"blue":
#			return Color.BLUE
#		"red":
#			return Color.RED
#		"yellow":
#			return Color.YELLOW
#		"purple":
#			return Color.PURPLE
#		_:
#			return Color.WHITE

#------------------------------------------
#Unit selection box
#------------------------------------------
func select_units():
	for unit in get_tree().get_nodes_in_group("selectable"):
		unit.set_selected(false)
	for unit in get_tree().get_nodes_in_group("selectable"):
		if selection_rect.has_point(unit.global_position):
			unit.set_selected(true)

func camera_shake()-> void:
	for i in range(6):
		camera.offset=Vector2(randf_range(-6,6),randf_range(-6,6))
		await get_tree().create_timer(0.02).timeout
	camera.offset=Vector2.ZERO
		
