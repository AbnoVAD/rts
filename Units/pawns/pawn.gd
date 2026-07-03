extends CharacterBody2D

#----------------------------------
#Enums
#----------------------------------
enum tool{HAND,HAMMER,PICKAXE,AXE,KNIFE}
enum state {IDLE,RUN,USE,DEAD}

#-----------------------------------
#Exported variables
#-----------------------------------
@export var speed:=400.0
@export var max_life:=120
@export var knockback_force:=320.0
@export var use_duration:=0.5
@export var tool_cooldown:=0.5 # timpul de apasare la fiecare buton
@export var auto_gather_enabled:=true
@export var carry_limit:=8
@export var gather_stop_distance:=48.0
@export var castle_deposit_distance:=72.0
@export var auto_work_drop_wait:=1.1

@export var attack_effect_scene= preload("res://materials_effects/attackeffect/attackeffect.tscn")
@export var attack_repair_scene= preload("res://Units/Monk/heal_effect.tscn")
@export var skull_scene= preload("res://materials_effects/skull/skull.tscn")


#-------------------------------------
#Inputs constants
#-------------------------------------
const INPUT_RIGHT:="move_right"
const INPUT_LEFT:="move_left"
const INPUT_DOWN:="move_down"
const INPUT_UP:="move_up"

#-------------------------------------
#node reference
#-------------------------------------
@onready var animations: AnimatedSprite2D = $animations
@onready var detector_zone: Area2D = $detector_zone
@onready var hitbox: Area2D = $hitbox
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var select_indicator: Label = $"select indicator"
@onready var marker_2d: Marker2D = $Marker2D
@onready var use_timer: Timer = $UseTimer
@onready var toolbox_panel: Control = $Control
var auto_work_button: Button
var nav: NavigationAgent2D = null

const AUTO_NAV_PATH_DISTANCE:=10.0
const AUTO_NAV_TARGET_DISTANCE:=26.0
const AUTO_NAV_RADIUS:=14.0

#-------------------------------------
#references for sound fx
#-------------------------------------
@onready var hammer_audio: AudioStreamPlayer2D = $soundfx/hammer_audio
@onready var knife_audio: AudioStreamPlayer2D = $soundfx/knife_audio
@onready var pickaxe_audio: AudioStreamPlayer2D = $soundfx/pickaxe_audio
@onready var axe_audio: AudioStreamPlayer2D = $soundfx/axe_audio
@onready var equip_audio: AudioStreamPlayer2D = $soundfx/equip_audio
@onready var click_audio: AudioStreamPlayer2D = $soundfx/click_audio
@onready var death_audio: AudioStreamPlayer2D = $soundfx/death_audio

#-------------------------------------
#State variables
#-------------------------------------
var Current_state:state=state.IDLE
var current_tool:tool=tool.HAND

var active:=false
var busy:=false
var action_lock:=false #blocheaza animatia in functie de actiune
var is_guarding:=false
var can_use_tool:=true

var life:int
var knockback_velocity:= Vector2.ZERO
var last_input_dir:=Vector2.DOWN

#Inventar
var collected:={
	"wood":0,
	"gold":0,
	"meat":0,
}

var worker_target:Node2D=null
var worker_target_type:String=""
var returning_to_castle:=false

#-------------------------------------
#UI (HP/Scut)
#-------------------------------------
var ui_visible:=false
var ui_hide_delay:=2.5
var ui_timer:=0.0

#-------------------------------------
#Ready functions
#-------------------------------------
func _ready() -> void:
	GlobalPlayer.register_pawn(self)
	progress_bar.visible=false
	set_process(true)
	set_physics_process(true)
	
	toolbox_panel.z_index=7
	z_index=4
	scale=Vector2(0.7,0.7)
	life=max_life
	progress_bar.max_value=max_life
	progress_bar.value=life
	
	toolbox_panel.hide()
	use_timer.wait_time=use_duration
	use_timer.one_shot=true
	
	if not use_timer.timeout.is_connected(_on_use_timer_timeout):
		use_timer.timeout.connect(_on_use_timer_timeout)
	
	#connect detector zone signals
	if detector_zone!=null:
		detector_zone.area_entered.connect(_on_resource_entered)

	_setup_navigation_agent()
	_setup_auto_work_button()
	_refresh_auto_work_button()



#-------------------------------------
#pick up function (picking up resources)
#-------------------------------------
func pickup_resource(resource_node)->void:
	var resource_type=resource_node.resource_type
	if resource_type in collected:
		collected[resource_type]+=1
		resource_node.set("collected",true)
		_release_worker_target()
		#call the function
		if resource_node.has_method("collect"):
			resource_node.collect()
		else:
			resource_node.queue_free()

#-------------------------------------
#auto pick up function
#-------------------------------------
func _on_resource_entered(area:Area2D)->void:
	#check if it's a resource
	if area.has_method("collect") and "resource_type" in area:
		if not area.collected:
			var resource_type=area.resource_type
			#check
			if can_collect_resource(resource_type):
				pickup_resource(area)

func can_collect_resource(resource_type:String) -> bool:
	return (resource_type=="wood" and current_tool==tool.AXE) or \
		(resource_type=="gold" and current_tool==tool.PICKAXE) or \
		(resource_type=="meat" and current_tool==tool.KNIFE)

func _setup_auto_work_button() -> void:
	if toolbox_panel==null or auto_work_button!=null:
		return

	auto_work_button=Button.new()
	auto_work_button.name="AutoWorkToggle"
	auto_work_button.toggle_mode=true
	auto_work_button.focus_mode=Control.FOCUS_NONE
	auto_work_button.size=Vector2(160,32)
	auto_work_button.position=Vector2(16,-248)
	auto_work_button.toggled.connect(_on_auto_work_button_toggled)
	toolbox_panel.add_child(auto_work_button)

func _refresh_auto_work_button() -> void:
	if auto_work_button==null:
		return
	auto_work_button.set_pressed_no_signal(auto_gather_enabled)
	auto_work_button.text="Auto Work: On" if auto_gather_enabled else "Auto Work: Off"
	auto_work_button.modulate=Color(0.8,1.0,0.8) if auto_gather_enabled else Color(1.0,0.85,0.85)

func _on_auto_work_button_toggled(pressed:bool) -> void:
	auto_gather_enabled=pressed
	if not auto_gather_enabled:
		returning_to_castle=false
		_release_worker_target()
		velocity=Vector2.ZERO
		busy=false
		can_use_tool=true
		Current_state=state.IDLE
		update_animation()
	_refresh_auto_work_button()

#-------------------------------------
#Input UI
#-------------------------------------
func _unhandled_input(event: InputEvent) ->void:
	if not active or Current_state==state.DEAD:
		return

	#toggle toolbox with input key "T"
	if event.is_action_pressed("tools"):
		toolbox_panel.visible=!toolbox_panel.visible
		get_viewport().set_input_as_handled()

#tool usage
	if event.is_action_pressed("use"):
		use_current_tool()
		hide_toolbox_if_visible()

#Manual tool selection from keyboard 1/2/3/4/5
	if event.is_action_pressed("tool_hand"):
		set_tool_and_activate(tool.HAND)
		hide_toolbox_if_visible()
		Global.pawn_tool="hand"
		if not equip_audio.playing:
			equip_audio.play()
	if event.is_action_pressed("tool_hammer"):
		set_tool_and_activate(tool.HAMMER)
		hide_toolbox_if_visible()
		Global.pawn_tool="hammer"
		if not equip_audio.playing:
			equip_audio.play()
	if event.is_action_pressed("tool_axe"):
		set_tool_and_activate(tool.AXE)
		hide_toolbox_if_visible()
		Global.pawn_tool="axe"
		if not equip_audio.playing:
			equip_audio.play()
	if event.is_action_pressed("tool_pickaxe"):
		set_tool_and_activate(tool.PICKAXE)
		hide_toolbox_if_visible()
		Global.pawn_tool="pickaxe"
		if not equip_audio.playing:
			equip_audio.play()
	if event.is_action_pressed("tool_knife"):
		set_tool_and_activate(tool.KNIFE)
		hide_toolbox_if_visible()
		Global.pawn_tool="knife"
		if not equip_audio.playing:
			equip_audio.play()

#-------------------------------------
#Hide toolbox in case of any input
#-------------------------------------
func hide_toolbox_if_visible():
	if toolbox_panel.visible:
		toolbox_panel.hide()
		
#-------------------------------------
#physics process
#-------------------------------------
func _physics_process(delta: float) -> void:
	if active==true:
		GlobalPlayer.active_player_position=global_position
	if active and not busy:
		if _is_any_move_pressed():
			hide_toolbox_if_visible()

#handle combat UI auto hide
	if ui_visible:
		ui_timer+=delta
		if ui_timer>=ui_hide_delay:
			ui_visible=false
			var tween:=create_tween()
			tween.tween_property(progress_bar,"modulate:a",0.0,0.3)
		
	if Current_state==state.DEAD:
		return


#knockback system
	if knockback_velocity.length()>1:
		velocity=knockback_velocity
		knockback_velocity=knockback_velocity.move_toward(Vector2.ZERO,delta*900)
		move_and_slide()
		update_animation()
		return

	var manual_controlled:=false
	if active and not busy:
		manual_controlled=handle_manual_movement()

	if not manual_controlled and not busy:
		if auto_gather_enabled:
			_handle_auto_gather(delta)
		else:
			velocity=Vector2.ZERO
			Current_state=state.IDLE

	move_and_slide()
	update_animation()
	
#-------------------------------------
#Movement logic manual input (arrow key/WASD)
#-------------------------------------
func handle_manual_movement() -> bool:
	if action_lock or is_guarding:
		velocity=Vector2.ZERO
		Current_state=state.IDLE
		return true
	
	var input_vector:=Vector2.ZERO
	
	if _is_move_right_pressed():
		input_vector.x+=1
	if _is_move_left_pressed():
		input_vector.x-=1
	if _is_move_down_pressed():
		input_vector.y+=1
	if _is_move_up_pressed():
		input_vector.y-=1

	if input_vector==Vector2.ZERO:
		return false

	last_input_dir=input_vector.normalized()
	velocity=last_input_dir*speed
	Current_state=state.RUN
	flip_sprite(last_input_dir)
	returning_to_castle=false
	_release_worker_target()
	return true

func _handle_auto_gather(delta:float) -> void:
	if action_lock or is_guarding or Current_state==state.DEAD:
		return

	var desired_resource_type:=_resource_type_for_tool(current_tool)
	if desired_resource_type=="":
		_release_worker_target()
		returning_to_castle=false
		velocity=Vector2.ZERO
		Current_state=state.IDLE
		return

	if returning_to_castle:
		if _deposit_if_needed():
			return

	if _get_total_carry_amount()>0 and _deposit_if_needed():
		return

	var pending_drop:=_find_closest_gatherable_drop(desired_resource_type)
	if pending_drop!=null:
		if worker_target==null or not is_instance_valid(worker_target) or worker_target!=pending_drop:
			_release_worker_target()
			worker_target=pending_drop
			worker_target_type=desired_resource_type

	if worker_target!=null and is_instance_valid(worker_target):
		var target_type:=_get_source_type(worker_target)
		if target_type!=desired_resource_type:
			_release_worker_target()
		elif worker_target.has_method("is_available_for_gathering") and not worker_target.is_available_for_gathering():
			_release_worker_target()
	else:
		_release_worker_target()

	if worker_target==null or not is_instance_valid(worker_target):
		worker_target=_find_closest_resource_source(desired_resource_type)
		worker_target_type=_get_source_type(worker_target)

	if worker_target==null:
		velocity=Vector2.ZERO
		Current_state=state.IDLE
		return

	var target_pos:=worker_target.global_position
	if worker_target.has_method("get_worker_target_position"):
		target_pos=worker_target.get_worker_target_position()
	var distance:=global_position.distance_to(target_pos)

	if distance>gather_stop_distance:
		_move_toward(target_pos, gather_stop_distance)
		return

	velocity=Vector2.ZERO
	Current_state=state.IDLE
	if not busy and can_use_tool:
		_start_auto_work_burst(worker_target, desired_resource_type)

func _move_toward(target_pos:Vector2, preferred_distance:float=AUTO_NAV_TARGET_DISTANCE) -> void:
	if nav!=null and is_instance_valid(nav):
		var map:RID=nav.get_navigation_map()
		if map.is_valid():
			var route_target:=NavigationRouteHelper.get_best_approach_point(nav,global_position,target_pos,preferred_distance)
			set_navigation_target(route_target)
			var next_pos:=nav.get_next_path_position()
			var dir:=next_pos-global_position
			if dir.length()<=0.001:
				velocity=Vector2.ZERO
				Current_state=state.IDLE
				return
			dir=dir.normalized()
			velocity=dir*speed
			Current_state=state.RUN
			flip_sprite(dir)
			returning_to_castle=false
			return

	var dir:=target_pos-global_position
	if dir.length()<=0.001:
		velocity=Vector2.ZERO
		Current_state=state.IDLE
		return

	dir=dir.normalized()
	velocity=dir*speed
	Current_state=state.RUN
	flip_sprite(dir)
	returning_to_castle=false

func _deposit_if_needed() -> bool:
	var carry_amount:=_get_total_carry_amount()
	if carry_amount<=0:
		returning_to_castle=false
		return false

	var deposit_target:=_find_deposit_target()
	if deposit_target==null:
		if GlobalPlayer.castle_position!=Vector2.ZERO:
			_move_toward(GlobalPlayer.castle_position, castle_deposit_distance)
			return true
		velocity=Vector2.ZERO
		Current_state=state.IDLE
		return false

	var deposit_pos:=deposit_target.global_position
	if deposit_target.has_method("get_worker_deposit_position"):
		deposit_pos=deposit_target.get_worker_deposit_position()

	var distance:=global_position.distance_to(deposit_pos)
	if distance>castle_deposit_distance:
		_move_toward(deposit_pos, castle_deposit_distance)
		return true

	if deposit_target.has_method("deposit_worker_resources"):
		var deposited:bool=deposit_target.deposit_worker_resources(collected)
		if deposited:
			for key in collected.keys():
				collected[key]=0
		else:
			velocity=Vector2.ZERO
			Current_state=state.IDLE
			return true
	else:
		Global.add_wood(int(collected.get("wood",0)))
		Global.add_gold(int(collected.get("gold",0)))
		Global.add_meat(int(collected.get("meat",0)))
		for key in collected.keys():
			collected[key]=0

	velocity=Vector2.ZERO
	Current_state=state.IDLE
	returning_to_castle=false
	_release_worker_target()
	return true

func _find_deposit_target() -> Node2D:
	var best_target:Node2D=null
	var best_distance:=INF

	for group_name in ["castle","warehouse"]:
		for node in get_tree().get_nodes_in_group(group_name):
			if not (node is Node2D):
				continue
			if not is_instance_valid(node):
				continue
			if node.has_method("can_accept_deposit") and not node.can_accept_deposit():
				continue
			if not node.has_method("deposit_worker_resources"):
				continue

			var candidate:=node as Node2D
			var deposit_pos:=candidate.global_position
			if candidate.has_method("get_worker_deposit_position"):
				deposit_pos=candidate.get_worker_deposit_position()

			var distance:=global_position.distance_to(deposit_pos)
			if distance<best_distance:
				best_distance=distance
				best_target=candidate

	return best_target

func _get_total_carry_amount() -> int:
	var total:=0
	for amount in collected.values():
		total+=int(amount)
	return total

func _find_closest_gatherable_drop(resource_type:String) -> Node2D:
	var best:Node2D=null
	var best_distance:=INF
	for node in get_tree().get_nodes_in_group("gatherable_resource"):
		if not (node is Node2D):
			continue
		if not is_instance_valid(node):
			continue
		if not ("resource_type" in node):
			continue
		if str(node.resource_type)!=resource_type:
			continue
		if "collected" in node and node.collected:
			continue
		var dist:=global_position.distance_to(node.global_position)
		if dist<best_distance:
			best_distance=dist
			best=node
	return best

func _find_closest_resource_source(resource_type:String) -> Node2D:
	var best:Node2D=null
	var best_distance:=INF
	for node in get_tree().get_nodes_in_group("resource_source"):
		if not (node is Node2D):
			continue
		if not is_instance_valid(node):
			continue
		var source_type:=_get_source_type(node)
		if source_type=="" or source_type!=resource_type:
			continue
		if node.has_method("is_available_for_gathering") and not node.is_available_for_gathering():
			continue
		if node.has_method("can_be_reserved_by") and not node.can_be_reserved_by(self):
			continue
		var source_tool:=_tool_for_resource(source_type)
		if source_tool==tool.HAND:
			continue
		var dist:=global_position.distance_to(node.global_position)
		if dist<best_distance:
			best_distance=dist
			best=node
	if best!=null and best.has_method("reserve_for") and not best.reserve_for(self):
		return null
	return best

func _resource_type_for_tool(value:tool) -> String:
	match value:
		tool.AXE:
			return "wood"
		tool.PICKAXE:
			return "gold"
		tool.KNIFE:
			return "meat"
		_:
			return ""

func _get_source_type(node:Node) -> String:
	if node==null or not is_instance_valid(node):
		return ""
	if "source_type" in node:
		return str(node.source_type)
	if "resource_type" in node:
		return str(node.resource_type)
	return ""

func _tool_for_resource(resource_type:String) -> tool:
	match resource_type:
		"wood":
			return tool.AXE
		"gold":
			return tool.PICKAXE
		"meat":
			return tool.KNIFE
		_:
			return tool.HAND

func _auto_work_hits_for_tool() -> int:
	match current_tool:
		tool.AXE:
			return 8
		tool.PICKAXE:
			return 8
		tool.KNIFE:
			return 8
		_:
			return 0

func _auto_drop_wait_for_resource(resource_type:String) -> float:
	match resource_type:
		"wood":
			return max(auto_work_drop_wait, 1.0)
		"gold":
			return max(auto_work_drop_wait, 0.6)
		"meat":
			return max(auto_work_drop_wait * 0.25, 0.2)
		_:
			return 0.0

func _start_auto_work_burst(target:Node2D, resource_type:String) -> void:
	if busy or target==null or not is_instance_valid(target):
		return
	if target.has_method("is_available_for_gathering") and not target.is_available_for_gathering():
		return

	busy=true
	can_use_tool=false
	Current_state=state.USE
	update_animation()

	var max_hits:=_auto_work_hits_for_tool()
	if max_hits<=0:
		busy=false
		can_use_tool=true
		Current_state=state.IDLE
		return

	for i in range(max_hits):
		if not auto_gather_enabled:
			break
		if target==null or not is_instance_valid(target):
			break
		if target.has_method("is_available_for_gathering") and not target.is_available_for_gathering():
			break
		if not target.has_method("perform_auto_work"):
			break
		if not target.perform_auto_work(_tool_name_for_tool(current_tool), self):
			break

		await _collect_nearby_drops(resource_type)
		if returning_to_castle:
			break
		if _get_total_carry_amount()>=carry_limit:
			break

		if target.has_method("is_available_for_gathering") and not target.is_available_for_gathering():
			var wait_time:=_auto_drop_wait_for_resource(resource_type)
			if wait_time>0.0:
				var elapsed:=0.0
				while elapsed<wait_time and is_instance_valid(self) and auto_gather_enabled:
					pick_nearby_items()
					await get_tree().create_timer(0.1).timeout
					elapsed+=0.1
			break

		if i<max_hits-1:
			await get_tree().create_timer(tool_cooldown).timeout

	await _collect_nearby_drops(resource_type)
	if not auto_gather_enabled:
		_release_worker_target()
		velocity=Vector2.ZERO
		busy=false
		can_use_tool=true
		Current_state=state.IDLE
		update_animation()
		return
	if _get_total_carry_amount()>0:
		returning_to_castle=true
	else:
		returning_to_castle=false
	_release_worker_target()
	velocity=Vector2.ZERO
	busy=false
	can_use_tool=true
	Current_state=state.IDLE
	update_animation()

func _collect_nearby_drops(resource_type:String) -> void:
	if detector_zone==null:
		return

	while auto_gather_enabled and _get_total_carry_amount()<carry_limit:
		var picked_any:=false
		var overlapping_area=detector_zone.get_overlapping_areas().duplicate()
		for area in overlapping_area:
			if area==null or not is_instance_valid(area):
				continue
			if not area.has_method("collect") or not ("resource_type" in area):
				continue
			if str(area.resource_type)!=resource_type:
				continue
			if area.collected:
				continue
			if can_collect_resource(resource_type):
				pickup_resource(area)
				picked_any=true
				if _get_total_carry_amount()>=carry_limit:
					return

		if not picked_any:
			return
		await get_tree().process_frame

func _release_worker_target() -> void:
	if worker_target!=null and is_instance_valid(worker_target) and worker_target.has_method("release_reservation"):
		worker_target.release_reservation(self)
	worker_target=null
	worker_target_type=""

func _setup_navigation_agent() -> void:
	nav=get_node_or_null("NavigationAgent2D") as NavigationAgent2D
	if nav==null:
		nav=NavigationAgent2D.new()
		nav.name="NavigationAgent2D"
		add_child(nav)
	nav.path_desired_distance=AUTO_NAV_PATH_DISTANCE
	nav.target_desired_distance=AUTO_NAV_TARGET_DISTANCE
	nav.radius=AUTO_NAV_RADIUS
	nav.neighbor_distance=48.0
	nav.max_neighbors=12
	nav.max_speed=speed

func set_navigation_target(pos:Vector2) -> void:
	if nav==null or not is_instance_valid(nav):
		return
	var travel_distance:=global_position.distance_to(pos)
	NavigationRouteHelper.tune_navigation_agent(nav,travel_distance,10.0,28.0,26.0,40.0,14.0,18.0)
	var map:RID=nav.get_navigation_map()
	if NavigationRouteHelper.should_use_direct_navigation(nav,global_position,pos,96.0):
		nav.target_position=pos
	elif map.is_valid():
		nav.target_position=NavigationServer2D.map_get_closest_point(map,pos)
	else:
		nav.target_position=pos

func _tool_name_for_tool(value:tool) -> String:
	match value:
		tool.HAMMER:
			return "hammer"
		tool.PICKAXE:
			return "pickaxe"
		tool.AXE:
			return "axe"
		tool.KNIFE:
			return "knife"
		_:
			return "hand"

func _is_move_right_pressed() -> bool:
	return Input.is_action_pressed(INPUT_RIGHT) or \
		Input.is_physical_key_pressed(KEY_D) or \
		Input.is_physical_key_pressed(KEY_RIGHT)

func _is_move_left_pressed() -> bool:
	return Input.is_action_pressed(INPUT_LEFT) or \
		Input.is_physical_key_pressed(KEY_A) or \
		Input.is_physical_key_pressed(KEY_LEFT)

func _is_move_down_pressed() -> bool:
	return Input.is_action_pressed(INPUT_DOWN) or \
		Input.is_physical_key_pressed(KEY_S) or \
		Input.is_physical_key_pressed(KEY_DOWN)

func _is_move_up_pressed() -> bool:
	return Input.is_action_pressed(INPUT_UP) or \
		Input.is_physical_key_pressed(KEY_W) or \
		Input.is_physical_key_pressed(KEY_UP)

func _is_any_move_pressed() -> bool:
	return _is_move_right_pressed() or \
		_is_move_left_pressed() or \
		_is_move_down_pressed() or \
		_is_move_up_pressed()
	
#-------------------------------------
#Use current tool by pressing "SPACE"
#-------------------------------------
func use_current_tool():
	if busy or Current_state==state.DEAD or not can_use_tool:
		return
	
	#start tool action based on the var current tool
	match current_tool:
		tool.HAMMER:
			repeat_tool_action(tool.HAMMER,"","hammer",3)
		tool.PICKAXE:
			repeat_tool_action(tool.PICKAXE,"gold","pickaxe",4)
		tool.AXE:
			repeat_tool_action(tool.AXE,"wood","axe",4)
		tool.KNIFE:
			repeat_tool_action(tool.KNIFE,"meat","knife",2)
		tool.HAND:
			repeat_tool_action(tool.HAND,"","hand",1)
			

#-------------------------------------
#func to use tool
#-------------------------------------
func repeat_tool_action(Tool:tool,collect_type:String,_tool_name:String,times:int)->void:
	busy=true
	can_use_tool=false
	Current_state=state.USE
	current_tool=Tool
	Global.pawn_tool=_tool_name



	for i in range(times):
		spawn_tool_effect() # spawn the right effect
		if collect_type!="" and detector_zone!=null:
			collect_nearby_resources(collect_type)
		if i<times-1:
			await get_tree().create_timer(tool_cooldown).timeout

	update_animation()

	#reset after using x times
	can_use_tool=true
	busy=false
	Current_state=state.IDLE
	update_animation()

func spawn_tool_effect()->void:
	if current_tool==tool.HAMMER:
		spawn_repair_effect()
	else:
		spawn_attack_effect()

#-------------------------------------
#func to pick nearby resources
#-------------------------------------
func collect_nearby_resources(_resource_type:String)->void:
	if detector_zone==null:
		return
	
	var overlapping_area=detector_zone.get_overlapping_areas().duplicate()
	for area in overlapping_area:
		if area.has_method("collect") and "resource_type" in area:
			if can_collect_resource(str(area.resource_type)):
				pickup_resource(area)

#-------------------------------------
#pickup func
#-------------------------------------
func pick_nearby_items()->void:
	if detector_zone==null:
		return

	var overlapping_area=detector_zone.get_overlapping_areas().duplicate()
	for area in overlapping_area:
		if area.has_method("collect") and "resource_type" in area:
			if not area.collected:
				var resource_type=area.resource_type
				if resource_type in collected:
					pickup_resource(area)

#-------------------------------------
#flip the anim
#-------------------------------------
func flip_sprite(dir:Vector2)->void:
	if dir.x!=0:
		animations.flip_h=dir.x<0

#-------------------------------------
#Tool selection/activation
#-------------------------------------
func set_tool_and_activate(Tool:tool)->void:
	if busy:
		return
	current_tool=Tool
	if active:
		Global.pawn_tool=_tool_name_for_tool(Tool)

func set_active()->void:
	active=true
	toolbox_panel.show()

#-------------------------------------
#Hitbox and damage
#-------------------------------------
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosion"):
		take_damage(10,area.global_position)

#-------------------------------------
#Spawn attack effect
#-------------------------------------
func spawn_attack_effect()->void:
	var fx:=attack_effect_scene.instantiate()
	fx.global_position=marker_2d.global_position
	fx.scale=Vector2(0.2,0.2)
	fx.tool_type=_tool_name_for_tool(current_tool)
	get_parent().add_child(fx)
	match current_tool:
		tool.HAMMER:
			fx.scale=Vector2(0.2,0.2)
			hammer_audio.play()
			await get_tree().create_timer(0.6).timeout
			hammer_audio.stop()
		tool.KNIFE:
			fx.scale=Vector2(0.2,0.2)
			knife_audio.play()
		tool.AXE:
			fx.scale=Vector2(0.2,0.2)
			axe_audio.play()
		tool.PICKAXE:
			fx.scale=Vector2(0.2,0.2)
			pickaxe_audio.play()
		tool.HAND:
			fx.scale=Vector2(0.2,0.2)

func spawn_repair_effect()->void:
	var fx:=attack_repair_scene.instantiate()
	fx.remove_from_group("heal")
	fx.add_to_group("repair_effect")
	fx.global_position=marker_2d.global_position
	fx.scale=Vector2(0.2,0.2)
	get_parent().add_child(fx)
	match current_tool:
		tool.HAMMER:
			fx.scale=Vector2(0.2,0.2)
			hammer_audio.play()
			await get_tree().create_timer(0.6).timeout
			hammer_audio.stop()

#-------------------------------------
#Damage/feedback
#-------------------------------------
func take_damage(amount:int,from_pos:Vector2)->void:
	show_combat_ui()
	life-=amount
	if GlobalPlayer.camera_shake_func.is_valid():
		GlobalPlayer.camera_shake_func.call()
	progress_bar.value=life
	knockback_velocity=(global_position-from_pos).normalized()*knockback_force

	red_flash()

	if life<=0:
		die()

func red_flash():
	animations.modulate=Color.RED
	await get_tree().create_timer(0.12).timeout
	animations.modulate=Color.WHITE

#-------------------------------------
#Death
#-------------------------------------
signal died(pawn)

func die():
	if Current_state==state.DEAD:
		return
	emit_signal("died",self)
	_release_worker_target()

	Current_state=state.DEAD
	active=false
	busy=true

	if not death_audio.playing:
		death_audio.play()
		spawn_skull()
		await fade_out()
		queue_free()

func spawn_skull():
	var skull=skull_scene.instantiate()
	skull.global_position=global_position
	get_parent().add_child(skull)
	skull.scale=Vector2(0.5,0.5)

func fade_out():
	var tween:=create_tween()
	tween.tween_property(animations,"modulate:a",0.0,0.6)
	await tween.finished

#-------------------------------------
#Animation handler
#-------------------------------------
func update_animation()->void:
	var suffix:=""
	match current_tool:
		tool.HAMMER:suffix="hammer"
		tool.PICKAXE:suffix="pickaxe"
		tool.AXE:suffix="axe"
		tool.KNIFE:suffix="knife"
		tool.HAND:suffix=""

	if Current_state==state.USE:
		if suffix=="":
			animations.play('use')
		else:
			animations.play("use_"+suffix)
	if Current_state==state.IDLE:
		if suffix=="":
			animations.play('idle')
		else:
			animations.play("idle_"+suffix)
	if Current_state==state.RUN:
		if suffix=="":
			animations.play('run')
		else:
			animations.play("run_"+suffix)
	if Current_state==state.DEAD:
		animations.play("idle")

#-------------------------------------
#buttons tools selections
#-------------------------------------

func _on_hammer_pressed() -> void:
	set_tool_and_activate(tool.HAMMER)
	hide_toolbox_if_visible()
	Global.pawn_tool="hammer"
	equip_audio.play()
func _on_pickaxe_pressed() -> void:
	set_tool_and_activate(tool.PICKAXE)
	hide_toolbox_if_visible()
	Global.pawn_tool="pickaxe"
	equip_audio.play()
func _on_axe_pressed() -> void:
	set_tool_and_activate(tool.AXE)
	hide_toolbox_if_visible()
	Global.pawn_tool="axe"
	equip_audio.play()
func _on_knife_pressed() -> void:
	set_tool_and_activate(tool.KNIFE)
	hide_toolbox_if_visible()
	Global.pawn_tool="knife"
	equip_audio.play()
func _on_hand_pressed() -> void:
	set_tool_and_activate(tool.HAND)
	hide_toolbox_if_visible()
	Global.pawn_tool="hand"
	equip_audio.play()

#-------------------------------------
#Activate/deactivate the pawn
#-------------------------------------
func activate_this_pawn():
	if GlobalPlayer.active_player and GlobalPlayer.active_player!=self:
		if GlobalPlayer.active_player.has_method("deactivate"):
			GlobalPlayer.active_player.deactivate()
	GlobalPlayer.active_player=self

	active=true
	GlobalPlayer.active_player_position=global_position
	set_process(true)
	toolbox_panel.show()
	update_selection_indicator()
	_refresh_auto_work_button()

func deactivate():
	active=false
	toolbox_panel.hide()
	update_selection_indicator()
	select_indicator.visible=active
	_refresh_auto_work_button()

func update_selection_indicator():
	select_indicator.visible=active

#-------------------------------------
# Detector zone signals
#-------------------------------------
func _on_detector_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("heal"): # folosit pentru monk heal
		show_combat_ui()
		life=max_life

#-------------------------------------
#Button signal
#-------------------------------------
func _on_button_pressed() -> void:
	GlobalPlayer.set_active_pawn(self)
	click_audio.play()

func _on_use_timer_timeout() -> void:
	busy=false
	can_use_tool=true
	Current_state=state.IDLE
	update_animation()

#-------------------------------------
#healing detector
#-------------------------------------
func get_health_percentage()->float:
	return float(life)/float(max_life)

func get_health()->int:
	return life

func get_max_health()->int:
	return max_life

func show_combat_ui():
	ui_visible=true
	ui_timer=0.0
	progress_bar.visible=true
	progress_bar.modulate.a=1.0

func activate_from_global():
	active=true
	set_process(true)
	toolbox_panel.show()
	select_indicator.visible=true
	GlobalPlayer.active_player_position=global_position
	_refresh_auto_work_button()
