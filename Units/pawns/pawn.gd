extends CharacterBody2D

#----------------------------------
#Enums
#----------------------------------
enum tool{HAND,HAMMER,PICKAXE,AXE,KNIFE}
enum state {IDLE,RUN,USE,DEAD}

#-----------------------------------
#Exported variables
#-----------------------------------
@export var speed:=300.0
@export var max_life:=100
@export var knockback_force:=320.0
@export var use_duration:=0.5
@export var tool_cooldown:=0.5 # timpul de apasare la fiecare buton

@export var attack_effect_scene= preload("res://materials_effects/attackeffect/attackeffect.tscn")
@export var attack_repair_scene= preload("res://materials_effects/repaireffect/repaireffect.tscn")
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
@onready var hit_audio: AudioStreamPlayer2D = $soundfx/hit_audio

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
	"stone":0,
	"meat":0,
}

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
	
	toolbox_panel.z_index=7
	z_index=4
	scale=Vector2(0.7,0.7)
	life=max_life
	progress_bar.max_value=max_life
	progress_bar.value=life
	
	toolbox_panel.hide()
	use_timer.wait_time=use_duration
	use_timer.one_shot=true
	
	use_timer.timeout.connect(_on_use_timer_timeout)
	
	#connect detector zone signals
	if detector_zone!=null:
		detector_zone.area_entered.connect(_on_resource_entered)
		


#-------------------------------------
#pick up function (picking up resources)
#-------------------------------------
func pickup_resource(resource_node)->void:
	var resource_type=resource_node.resource_type
	if resource_type in collected:
		collected[resource_type]+=1
		#call the function
		if resource_node.has_methode("collect"):
			resource_node.collect()
		else:
			resource_node.queue_free()

#-------------------------------------
#auto pick up function
#-------------------------------------
func _on_resource_entered(area:Area2D)->void:
	#check if it's a resource
	if area.has_method("collect") and area.has_property("resource_type"):
		if not area.collected:
			var resource_type=area.resouce_type
			#check
			if(resource_type=="wood" and current_tool==tool.AXE) or \
			(resource_type=="stone" and current_tool==tool.PICKAXE) or \
			(resource_type=="meat" and current_tool==tool.KNIFE):
				pickup_resource(area)

#-------------------------------------
#Input UI
#-------------------------------------
func _input(event: InputEvent) ->void:
	if not active or Current_state==state.DEAD:
		return

	#toggle toolbox with input key "T"
	if event.is_action_pressed("tools"):
		toolbox_panel.visible=!toolbox_panel.visible
		get_viewport().set_input_as_handled()

#tool usage
	if event.is_action_pressed("use"):
		use_current_tool()
		#hide_toolbox_if_visible
		pass

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
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or \
		Input.is_action_pressed("move_down") or Input.is_action_pressed("move_up"):
			hide_toolbox_if_visible()
			
			
#handle combat UI auto hide
	if ui_visible:
		ui_timer=+delta
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
		#update_animation()
		return

	if active and not busy:
		handle_movement()
	else:
		velocity=Vector2.ZERO
		if not busy:
			Current_state=state.IDLE

	move_and_slide()
	#update_animation()
	
#-------------------------------------
#Movement logic manual input (arrow key)
#-------------------------------------
func handle_movement():
	if action_lock or is_guarding:
		velocity=Vector2.ZERO
		Current_state=state.IDLE
		return
	
	var input_vector:=Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_vector.x+=1
	if Input.is_action_pressed("move_left"):
		input_vector.x-=1
	if Input.is_action_pressed("move_down"):
		input_vector.y+=1
	if Input.is_action_pressed("move_up"):
		input_vector.y-=1

	if input_vector==Vector2.ZERO:
		velocity=Vector2.ZERO
		Current_state=state.IDLE
		return


# all the pawn movement comes from this block
	last_input_dir=input_vector.normalized()
	velocity=last_input_dir*speed
	Current_state=state.RUN
	flip_sprite(last_input_dir)
	
#-------------------------------------
#Use current tool by pressing "SPACE"
#-------------------------------------
func use_current_tool():
	if busy or Current_state==state.DEAD or not active or not can_use_tool:
		return
	
	#start tool action based on the var current tool
	match current_tool:
		tool.HAMMER:
			repeat_tool_action(tool.HAMMER,"","hammer",3)
		tool.PICKAXE:
			repeat_tool_action(tool.PICKAXE,"stone","pickaxe",4)
		tool.AXE:
			repeat_tool_action(tool.AXE,"wood","axe",4)
		tool.KNIFE:
			repeat_tool_action(tool.KNIFE,"meat","knife",2)
		tool.HAND:
			repeat_tool_action(tool.HAMMER,"","hand",1)
			

#-------------------------------------
#func to use tool
#-------------------------------------
func repeat_tool_action(Tool:tool,collect_type:String,_tool_name:String,times:int)->void:
	busy=true
	can_use_tool=false
	Current_state=state.USE
	current_tool=Tool



#loop for animation effect
	for i in range(times):
		spawn_tool_effect() # spawn the right effect
		if collect_type!="" and detector_zone!=null:
			collect_nearby_resources(collect_type)

	update_animation()
	
	await get_tree().create_timber(tool_cooldown).timeout

	#reset after using x times
	can_use_tool=true
	busy=false
	Current_state=state.IDLE
	update_animation()

func spawn_tool_effect()->void:
	if current_tool==tool.HAMMER:
		pass
		#spawn_repari_effect()
	else:
		pass
		#spawn_attack_effect()


#-------------------------------------
#func to pick nearby resources
#-------------------------------------
func collect_nearby_resources(_resource_type:String)->void:
	if detector_zone==null:
		return
	
	var overlapping_area=detector_zone.get_overlapping_areas()
	for area in overlapping_area:
		if area in overlapping_area:
			if area.has_method("collect") and area.has_property("resource_type"):
				pickup_resource(area)
				return

#-------------------------------------
#pickup func
#-------------------------------------
func pick_nearby_items()->void:
	if detector_zone==null:
		return

	var overlapping_area=detector_zone.get_overlapping_areas()
	for area in overlapping_area:
		if area in overlapping_area:
			if area.has_method("collect") and area.has_property("resource_type"):
				if not area.collected:
					var resource_type=area.resouce_type
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
	if active:
		current_tool=Tool

func set_active()->void:
	active=true
	toolbox_panel.show()

#-------------------------------------
#Hitbox and damage
#-------------------------------------
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("explo"):
		take_damage(10,area.global_position)
		hit_audio.play()

#-------------------------------------
#Spawn attack effect
#-------------------------------------
func spawn_attack_effect()->void:
	var fx:=attack_effect_scene.instantiate()
	fx.global_position=marker_2d.global_position
	fx.scale=Vector2(0.2,0.2)
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
	var fx:=attack_effect_scene.instantiate()
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
	#Global.pawn_tool="hammer"
	equip_audio.play()
func _on_pickaxe_pressed() -> void:
	set_tool_and_activate(tool.PICKAXE)
	hide_toolbox_if_visible()
	#Global.pawn_tool="pickaxe"
	equip_audio.play()
func _on_axe_pressed() -> void:
	set_tool_and_activate(tool.AXE)
	hide_toolbox_if_visible()
	#Global.pawn_tool="axe"
	equip_audio.play()
func _on_knife_pressed() -> void:
	set_tool_and_activate(tool.KNIFE)
	hide_toolbox_if_visible()
	#Global.pawn_tool="knife"
	equip_audio.play()
func _on_hand_pressed() -> void:
	set_tool_and_activate(tool.HAND)
	hide_toolbox_if_visible()
	#Global.pawn_tool="hand"
	equip_audio.play()

#-------------------------------------
#Activate/deactivate the pawn
#-------------------------------------
func activate_this_pawn():
	if GlobalPlayer.active_player and GlobalPlayer.active_player!=self:
		if GlobalPlayer.is_active_player.has_method("deactivate"):
			GlobalPlayer.is_active_player.deactive()
	GlobalPlayer.active_player=self

	active=true
	GlobalPlayer.active_player_position=global_position
	set_process(true)
	toolbox_panel.show()
	update_selection_indicator()

func deactivate():
	active=false
	set_process(false)
	toolbox_panel.hide()
	update_selection_indicator()
	select_indicator.visible=active

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
